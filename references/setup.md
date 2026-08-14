# Setup

The skill supports two worker paths.

## Prerequisites

DeepSeek Harness runs on Node.js `^22.19 || >=24` (npm `engines`). Install the CLI globally and make sure `dsh` is on `PATH`:

```bash
npm install -g @deepseek-ai/dsh
```

The `web` and `headless` profiles auto-initialize on first use from templates shipped with the CLI.

## 1. Official headless fallback

The one-shot worker runs in the invoking directory:

```bash
cd /path/to/project
dsh --profile headless "run the focused tests and fix the failure"
```

The helper script wraps the same behavior:

```bash
scripts/dsh_headless.sh "run the focused tests and fix the failure" /path/to/project
```

`DEEPSEEK_API_KEY` must be available to the Harness process. Do not put the key in this repository.

## 2. MCP path

A current community option is `@chushixixin/dsh-harness-mcp-server`, which exposes synchronous and queued Harness tasks over Streamable HTTP.

Install it into the `web` profile:

```bash
dsh plugin --profile web add @chushixixin/dsh-harness-mcp-server
```

Start Harness:

```bash
dsh web
```

Note the two ports: `dsh web` serves its own web UI on port `3080` by default; the MCP bridge plugin listens separately on its default MCP endpoint:

```text
http://127.0.0.1:8090/mcp
```

The Skill metadata in `agents/openai.yaml` declares that endpoint as `deepseekHarness`.

The MCP tool names used in this Skill (`agent_run`, `task_inbox`, `task_result`) and the structured result fields (`changes`, `verification`, `leftovers`) reflect `@chushixixin/dsh-harness-mcp-server` v0.1.x. The package is a third-party community project and may rename them; check `dsh plugin --profile web list` and the package's README after upgrading, and update `SKILL.md` if the tool surface changed.

### Recommended hardening

The MCP bridge is a third-party community project and can expose powerful local tools. Keep it on loopback. If you configure it manually, use `workspaceRoots` to restrict allowed `cwd` values and add authentication before any non-loopback exposure.

## Preflight

```bash
./scripts/preflight.sh
```

A failed MCP check is not fatal if `dsh` headless works; the Skill will use the fallback path.
