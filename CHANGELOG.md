# Changelog

## 0.2.0 - 2026-08-15

- Add the **verification contract + stop rule**: after a worker finishes, the manager verifies machine-checkable boundaries and stops when they pass — no re-implementation drift.
- Add `scripts/verify_workspace.sh`: a non-LLM verifier (changed files, scope, diff size, dependency/public-API/untracked invariants, test commands) that prints a small JSON receipt.
- SKILL.md review flow is now risk-tiered: `receipt` / `targeted` / `full`.
- Core rule extended: "Delegate the work. Verify the evidence. Don't redo the work."
- Motivated by measured data: in one real run the manager review consumed 80% of tokens after the worker had already passed 16/16 tests.

## 0.1.2 - 2026-08-15

- Fix the default user-skill install path to the official Codex location `$HOME/.agents/skills` (the previous `$CODEX_HOME/skills` path was never read by Codex).
- Update installer validation, bilingual README examples, and the integration docs accordingly.

## 0.1.1 - 2026-08-15

- Fix install path to the official Codex skills directory (`$CODEX_HOME/skills`, default `~/.codex/skills`).
- Harden `install_skill.sh` against catastrophic `rm -rf` destinations.
- Clarify ports in setup: `dsh web` UI defaults to 3080; the MCP bridge listens on 8090.
- Document the Node.js `^22.19 || >=24` requirement and the `npm install -g @deepseek-ai/dsh` install command.
- Pin documented MCP tool names to `@chushixixin/dsh-harness-mcp-server` v0.1.x.
- `dsh_headless.sh` now keeps a full worker transcript in a temp log outside the workspace.
- Add `.env.example` template.
- Add install-script safety checks to `validate_skill.py`.

## 0.1.0 - 2026-08-15

- Initial public release.
- MCP-first delegation with official DeepSeek Harness headless fallback.
- Reviewer/worker task contract and independent verification rules.
- Separate-worktree guidance for parallel mutating tasks.
- English and Simplified Chinese documentation.
