#!/usr/bin/env bash
set -u

mcp_url=${DEEPSEEK_HARNESS_MCP_URL:-http://127.0.0.1:8090/mcp}
failed=0

check_cmd() {
  local name=$1
  if command -v "$name" >/dev/null 2>&1; then
    printf 'ok   %-22s %s\n' "$name" "$(command -v "$name")"
  else
    printf 'miss %-22s not found\n' "$name"
    failed=1
  fi
}

check_cmd dsh

if command -v codex >/dev/null 2>&1; then
  printf 'ok   %-22s %s\n' codex "$(command -v codex)"
else
  printf 'note %-22s not found (only needed on the host running Codex)\n' codex
fi

if [[ -n "${DEEPSEEK_API_KEY:-}" ]]; then
  printf 'ok   %-22s set (value not printed)\n' DEEPSEEK_API_KEY
else
  printf 'note %-22s not set in this shell\n' DEEPSEEK_API_KEY
fi

# A Streamable HTTP MCP endpoint answers a bare GET with 4xx/405, which curl
# (no -f) still counts as success. This check therefore claims only "some
# HTTP server is listening here", not "MCP is fully working".
if command -v curl >/dev/null 2>&1; then
  if curl --silent --show-error --max-time 2 --output /dev/null "$mcp_url" 2>/dev/null; then
    printf 'ok   %-22s reachable: %s\n' MCP "$mcp_url"
  else
    printf 'note %-22s not reachable: %s (headless fallback may still work)\n' MCP "$mcp_url"
  fi
else
  printf 'note %-22s curl not installed; skipped endpoint check\n' MCP
fi

exit "$failed"
