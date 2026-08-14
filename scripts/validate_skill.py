#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
required = [
    "SKILL.md",
    "README.md",
    "README.zh-CN.md",
    "LICENSE",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "CHANGELOG.md",
    ".env.example",
    "agents/openai.yaml",
    "references/setup.md",
    "references/delegation-policy.md",
]

missing = [p for p in required if not (root / p).is_file()]
if missing:
    raise SystemExit("missing required files: " + ", ".join(missing))

text = (root / "SKILL.md").read_text(encoding="utf-8")
if not text.startswith("---\n"):
    raise SystemExit("SKILL.md must start with YAML frontmatter")

frontmatter = text.split("---", 2)[1]
for key in ("name", "description"):
    if not re.search(rf"(?m)^{key}:\s*.+$", frontmatter):
        raise SystemExit(f"SKILL.md frontmatter missing {key}")

if "name: delegate-to-deepseek-harness" not in frontmatter:
    raise SystemExit("unexpected skill name")

for readme in ("README.md", "README.zh-CN.md"):
    body = (root / readme).read_text(encoding="utf-8")
    if "delegate-to-deepseek-harness" not in body:
        raise SystemExit(f"{readme} is missing the project name")

# The installer deletes its destination before copying; the destructive-path
# guard and the official Codex skills directory must not be silently dropped.
install = (root / "scripts" / "install_skill.sh").read_text(encoding="utf-8")
if "refusing to install" not in install:
    raise SystemExit("install_skill.sh is missing the destructive-path guard")
if ".codex" not in install:
    raise SystemExit("install_skill.sh must default to the Codex skills directory")

print("skill structure: ok")
