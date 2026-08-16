#!/usr/bin/env bash
# verify_workspace.sh — non-LLM verification for delegated coding work.
# Runs deterministic checks against the verification contract and prints a
# small JSON receipt. It does NOT judge code quality; it only checks whether
# the result violates the boundaries agreed at planning time.
#
# Usage:
#   verify_workspace.sh [--cwd DIR] [--baseline DIR]
#     --allowed-paths GLOB[,GLOB...]      changed files must match one of these
#     --checks 'CMD' [--checks 'CMD'...]  commands to run (tests/lint/build)
#     --invariants LIST                   comma list: no-new-deps,no-public-api-change,no-untracked
#     --max-changed-files N
#     --max-diff-lines N
#
# Exit code: 0 = receipt generated (status may still be "fail"); 1 = usage/config error.

usage() {
  sed -n '2,14p' "$0" >&2
  exit 1
}

cwd=$PWD
baseline=
allowed=()
checks=()
invariants=
max_files=
max_lines=

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cwd) cwd=$2; shift 2 ;;
    --baseline) baseline=$2; shift 2 ;;
    --allowed-paths) IFS=',' read -ra parts <<< "$2"; allowed+=("${parts[@]}"); shift 2 ;;
    --checks) checks+=("$2"); shift 2 ;;
    --invariants) invariants=$2; shift 2 ;;
    --max-changed-files) max_files=$2; shift 2 ;;
    --max-diff-lines) max_lines=$2; shift 2 ;;
    *) echo "error: unknown option: $1" >&2; usage ;;
  esac
done

if [[ ! -d "$cwd" ]]; then echo "error: cwd does not exist: $cwd" >&2; exit 1; fi
if [[ -n "$baseline" && ! -d "$baseline" ]]; then echo "error: baseline does not exist: $baseline" >&2; exit 1; fi
if [[ ${#allowed[@]} -eq 0 && -z "$baseline" ]]; then :; fi

cd "$cwd"

# --- 1. changed files ---------------------------------------------------------
use_git=0
if git rev-parse --git-dir >/dev/null 2>&1; then use_git=1; fi

changed=()
if [[ $use_git -eq 1 ]]; then
  # include staged + unstaged + untracked
  while IFS= read -r line; do
    f=${line:3}
    [[ -n "$f" ]] && changed+=("$f")
  done < <(git status --porcelain 2>/dev/null || true)
else
  if [[ -z "$baseline" ]]; then
    echo '{"error":"not a git repo and no --baseline given; cannot compute changed files"}' >&2
    exit 1
  fi
  while IFS= read -r f; do
    f=${f#/}
    changed+=("$f")
  done < <(diff -rq "$baseline" . 2>/dev/null | sed -n 's/^Files .* and \.\(.*\) differ$/\1/p; s/^Only in \.\(.*\): \(.*\)$/\1\/\2/p')
fi

# --- 2. scope check -----------------------------------------------------------
scope_ok=true
unexpected=()
for f in "${changed[@]}"; do
  matched=0
  for g in "${allowed[@]}"; do
    # glob match: convert glob to case pattern via bash [[ ]]
    if [[ "$f" == $g ]]; then matched=1; break; fi
  done
  if [[ $matched -eq 0 ]]; then unexpected+=("$f"); scope_ok=false; fi
done

# --- 3. diff size -------------------------------------------------------------
diff_lines=0
if [[ $use_git -eq 1 ]]; then
  diff_lines=$(git diff --numstat 2>/dev/null | awk '{a+=$1+$2} END {print a+0}')
else
  diff_lines=$(diff -r -U0 "$baseline" . 2>/dev/null | grep -cE '^[+-][^+-]')
fi

# --- 4. invariants ------------------------------------------------------------
new_deps=false
public_api_change=false
untracked=false
IFS=',' read -ra inv_list <<< "${invariants:-}"

for inv in "${inv_list[@]}"; do
  case "$inv" in
    no-new-deps)
      if [[ $use_git -eq 1 ]]; then
        if git diff -- package.json 2>/dev/null | grep -qE '^\+[^+].*"(dependencies|devDependencies)"' ; then
          new_deps=true
        fi
      else
        if [[ -f "$baseline/package.json" ]] && diff -q "$baseline/package.json" package.json >/dev/null 2>&1; then :; else
          new_deps=true  # package.json changed at all — flag for review
        fi
      fi
      ;;
    no-public-api-change)
      if [[ $use_git -eq 1 ]]; then
        if git diff 2>/dev/null | grep -qE '^[+-].*export ' ; then public_api_change=true; fi
      else
        if diff -r "$baseline" . 2>/dev/null | grep -qE '^[<>].*export '; then public_api_change=true; fi
      fi
      ;;
    no-untracked)
      if [[ $use_git -eq 1 ]]; then
        git status --porcelain 2>/dev/null | grep -q '^??' && untracked=true
      else
        diff -rq "$baseline" . 2>/dev/null | grep -q 'Only in \.' && untracked=true
      fi
      ;;
  esac
done

# --- 5. checks ----------------------------------------------------------------
tests_json="[]"
if [[ ${#checks[@]} -gt 0 ]]; then
  parts=()
  for cmd in "${checks[@]}"; do
    out=$(bash -c "$cmd" 2>&1); rc=$?
    passed=$(printf '%s' "$out" | grep -oE '[0-9]+ passing|[0-9]+ passed' | tail -1 | grep -oE '[0-9]+' || true)
    failed=$(printf '%s' "$out" | grep -oE '[0-9]+ failing|[0-9]+ failed' | tail -1 | grep -oE '[0-9]+' || true)
    tail3=$(printf '%s' "$out" | tail -3 | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')
    cmd_json=$(printf '%s' "$cmd" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read().rstrip("\n")))')
    parts+=("{\"command\":$cmd_json,\"exit_code\":$rc,\"passed\":${passed:-null},\"failed\":${failed:-null},\"tail\":$tail3}")
  done
  tests_json="[$(IFS=,; echo "${parts[*]}")]"
fi

# --- 6. limits ------------------------------------------------------------------
limits_ok=true
risk_flags=()
if [[ -n "$max_files" && ${#changed[@]} -gt "$max_files" ]]; then
  limits_ok=false
  risk_flags+=("changed_files_${#changed[@]}_over_max_${max_files}")
fi
if [[ -n "$max_lines" && $diff_lines -gt "$max_lines" ]]; then
  limits_ok=false
  risk_flags+=("diff_lines_${diff_lines}_over_max_${max_lines}")
fi
$new_deps && risk_flags+=("new_dependencies_detected")
$public_api_change && risk_flags+=("public_api_changed")
$untracked && risk_flags+=("untracked_files_present")

overall_pass=true
$scope_ok || overall_pass=false
$limits_ok || overall_pass=false
# invariant violations are contract failures, not just flags
$new_deps && overall_pass=false
$public_api_change && overall_pass=false
$untracked && overall_pass=false
if [[ ${#checks[@]} -gt 0 ]]; then
  # any failed test or nonzero exit makes overall fail
  printf '%s' "$tests_json" | grep -q '"failed":[1-9]' && overall_pass=false
  printf '%s' "$tests_json" | grep -qE '"exit_code":[1-9]' && overall_pass=false
fi

# --- 7. receipt ----------------------------------------------------------------
VW_STATUS=$overall_pass VW_SCOPE=$scope_ok VW_DIFFLINES=$diff_lines \
VW_CHANGED_COUNT=${#changed[@]} VW_TESTS=$tests_json \
VW_CHANGED_LIST="${changed[*]}" VW_UNEXPECTED="${unexpected[*]}" \
VW_FLAGS="${risk_flags[*]}" python3 <<'PYEOF'
import json, os
status = "pass" if os.environ["VW_STATUS"] == "true" else "fail"
receipt = {
    "status": status,
    "changed_files": int(os.environ["VW_CHANGED_COUNT"]),
    "changed_file_list": os.environ["VW_CHANGED_LIST"].split() if os.environ["VW_CHANGED_LIST"] else [],
    "diff_lines": int(os.environ["VW_DIFFLINES"]),
    "scope_ok": os.environ["VW_SCOPE"] == "true",
    "unexpected_files": os.environ["VW_UNEXPECTED"].split() if os.environ["VW_UNEXPECTED"] else [],
    "tests": json.loads(os.environ["VW_TESTS"]),
    "risk_flags": os.environ["VW_FLAGS"].split() if os.environ["VW_FLAGS"] else [],
}
print(json.dumps(receipt, ensure_ascii=False))
PYEOF
