# Repository notes for coding agents

Keep this project small and boring in a good way.

- `SKILL.md` is the product. Prefer improving its instructions over adding framework code.
- Shell scripts should stay dependency-light, quote variables, and fail loudly.
- Do not weaken the rule that the host agent independently reviews and verifies delegated changes.
- Do not silently broaden delegated authority to commits, pushes, deployments, credentials, or destructive operations.
- Keep README setup examples aligned with `references/setup.md`.
- `install_skill.sh` deletes its destination before copying. Keep the destructive-path guard in place; `validate_skill.py` checks for it.
- Run `./scripts/validate.sh` before finishing a change.
