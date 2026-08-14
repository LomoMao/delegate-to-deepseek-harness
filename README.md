# delegate-to-deepseek-harness

[简体中文](README.zh-CN.md)

> Codex keeps the judgment. DeepSeek Harness does the bounded work.

`delegate-to-deepseek-harness` is a small Agent Skill for handing well-scoped coding work from Codex to DeepSeek Harness, then bringing the result back for review and verification.

It is intentionally not a full orchestration framework. The skill defines the handoff contract and quality gate; the actual worker can run through a DeepSeek Harness MCP bridge or the official headless CLI.

## Why

Sometimes the expensive part of a coding task is not the final decision — it is reading a large repo, making repetitive edits, repairing tests, or implementing a clearly specified slice of work.

This skill keeps that split simple:

```text
You → Codex → DeepSeek Harness → workspace changes
              ↓
         Codex reviews
         diff + tests
```

Codex stays responsible for scope, risky judgment, integration, and the final answer.

**Methodology first, backend-agnostic.** The reusable part of this skill is the delegation contract and the review gate, not any particular worker path. If the MCP bridge changes or disappears, the headless CLI fallback (or any future Harness interface) keeps the same workflow intact.

## Good fits

- bounded implementation work
- mechanical refactors and migrations
- test repair and test generation
- repository exploration with a concrete question
- independent second attempts
- parallel work in separate worktrees

Not a good fit for architecture decisions, secrets, deployments, destructive operations, or work with no meaningful verification path.

## Install

Codex loads user skills from `$CODEX_HOME/skills` (default `~/.codex/skills/`).

**Option A — this repo's installer:**

```bash
git clone https://github.com/LomoMao/delegate-to-deepseek-harness.git
cd delegate-to-deepseek-harness
./scripts/install_skill.sh   # installs to $CODEX_HOME/skills (default ~/.codex/skills)
```

**Option B — manual copy:** copy `SKILL.md`, `agents/`, `references/`, and `scripts/` into `$CODEX_HOME/skills/delegate-to-deepseek-harness/`.

**Option C — Codex's built-in skill installer** (once this repo is public):

```text
$skill-installer install https://github.com/LomoMao/delegate-to-deepseek-harness
```

Then invoke it in Codex:

```text
$delegate-to-deepseek-harness
```

Example:

```text
Use $delegate-to-deepseek-harness to fix the failing parser tests.
Keep the public API unchanged, then review the diff and rerun the focused tests yourself.
```

## Worker backends

**Preferred:** a local DeepSeek Harness MCP server exposing `agent_run`, `task_inbox`, and `task_result`.

**Fallback:** the official one-shot CLI:

```bash
dsh --profile headless "run the tests"
```

See [setup](references/setup.md) for the current MCP example and the safer defaults.

## One rule that matters

A worker saying “done” is not evidence that the task is done.

After delegation, Codex should inspect the workspace, review the diff, and run the relevant tests/lint/typecheck/build before reporting success.

## Status

Early and intentionally small. The workflow is useful today, but the DeepSeek Harness ecosystem is moving quickly, so MCP names and setup details may change. MCP tool names documented in this repo reflect `@chushixixin/dsh-harness-mcp-server` v0.1.x; see [setup](references/setup.md).

Issues and small PRs are welcome.

## Security

A Harness worker may be able to edit files and run shell commands. Treat third-party Harness plugins as trusted local code, keep MCP endpoints on loopback, and scope writable workspaces as narrowly as practical. See [SECURITY.md](SECURITY.md).

## Acknowledgements

Inspired by the broader agent-delegation pattern used by projects such as `delegate-skills`, `delegate-to-pi`, and other reviewer/worker workflows.

This project is independent and is not affiliated with OpenAI or DeepSeek.

## License

MIT
