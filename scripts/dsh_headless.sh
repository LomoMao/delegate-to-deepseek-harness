#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "usage: $0 <task> [cwd]" >&2
  exit 64
fi

task=$1
cwd=${2:-$PWD}

if ! command -v dsh >/dev/null 2>&1; then
  echo "error: dsh is not installed or not on PATH" >&2
  exit 127
fi

if [[ ! -d "$cwd" ]]; then
  echo "error: cwd does not exist: $cwd" >&2
  exit 66
fi

if [[ -z "${task//[[:space:]]/}" ]]; then
  echo "error: task must not be empty" >&2
  exit 64
fi

cd "$cwd"

# Keep a full transcript outside the workspace so the host agent can review
# the run without polluting the worker's checkout.
log=$(mktemp "${TMPDIR:-/tmp}/dsh-headless-XXXXXX.log")
echo "worker log: $log" >&2
dsh --profile headless "$task" 2>&1 | tee "$log"
