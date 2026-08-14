---
name: delegate-to-deepseek-harness
description: Delegate bounded, implementation-heavy, repetitive, read-heavy, or independently verifiable coding work from Codex to DeepSeek Harness, preferably through a local Harness MCP worker and otherwise through the official headless CLI. Keep Codex responsible for scope, risky judgment, review, integration, and final verification. Do not use for trivial edits, secrets, deployments, destructive operations, or work that cannot be independently checked.
---

# Delegate to DeepSeek Harness

Use DeepSeek Harness as a worker. Keep Codex as orchestrator, reviewer, and final authority.

## Core rule

Delegate execution, not responsibility. A worker report is a claim, not proof. Review the workspace and independently verify relevant acceptance criteria before reporting success.

## Decide whether to delegate

Delegate when the task is self-contained and at least one of these is true:

- implementation is mechanical, repetitive, or context-heavy;
- the task has clear acceptance criteria and a practical verification path;
- repository exploration can be framed as a concrete question;
- an isolated second implementation or diagnosis would be useful;
- independent tasks can run in separate worktrees.

Keep the task in Codex when it is trivial, primarily architecture/product judgment, dependent on rich unsummarized conversation context, privileged or irreversible, or not independently verifiable.

## Choose the worker path

Use this order:

1. **Harness MCP** if a configured server exposes `agent_run` and, when needed, `task_inbox` / `task_result`.
2. **Headless fallback** with `scripts/dsh_headless.sh` when MCP is unavailable and `dsh` exists.
3. If neither path is available, stop delegation and state the missing prerequisite.

Read `references/setup.md` only when setup or connectivity matters.

## Write the worker brief

Give the worker a self-contained contract:

```text
Objective:
<one concrete outcome>

Scope:
<allowed files/modules and explicit non-goals>

Constraints:
<compatibility, API, style, dependency, or user constraints>

Acceptance criteria:
- <observable condition>
- <observable condition>

Verification:
- <focused command/check if known>

Rules:
- Work only inside the supplied cwd.
- Inspect before editing.
- Preserve unrelated changes.
- Do not commit, push, publish, deploy, rotate credentials, or perform destructive external actions.
- If blocked, report the blocker instead of guessing.
```

Put durable context in MCP `context`; put the actionable assignment in `task`. Do not dump the entire host conversation into the worker prompt.

## Run the worker

For one bounded task, prefer synchronous `agent_run` with `task`, relevant `context`, and an absolute `cwd`.

Use queued tools only when multiple independent tasks benefit from overlap. Never run concurrent mutating workers against the same checkout. Use separate worktrees/cwds, then review and integrate in Codex.

For headless fallback, resolve this Skill directory and run:

```bash
scripts/dsh_headless.sh "<worker brief>" "<absolute cwd>"
```

## Review the result

If the MCP returns structured fields, inspect `changes`, `verification`, `leftovers`, and the final assistant text. Inspect tool traces when the summary is unclear.

After any mutating worker:

1. inspect `git status` and `git diff`;
2. confirm changes stayed in scope and preserve unrelated work;
3. look for generated junk, secrets, broad formatting churn, and unexpected dependencies;
4. run the narrowest meaningful tests/lint/typecheck/build;
5. review risky logic yourself;
6. check each acceptance criterion against repository state or command output.

Never say tests passed unless Codex observed a reliable test result.

If the worker is blocked or wrong, either fix the issue directly or send one focused follow-up. Avoid open-ended retry loops; after two failed delegated attempts on the same failure mode, take over or report the blocker.

## Final response

Keep the user-facing answer about the task, not the plumbing. Distinguish what the worker attempted from what Codex independently verified, and mention any remaining uncertainty.

Read `references/delegation-policy.md` when routing boundaries are unclear.
