#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$script_dir/.." && pwd)

# Codex loads user skills from $CODEX_HOME/skills (~/.codex/skills by default).
skill_name=delegate-to-deepseek-harness
dest=${1:-"${CODEX_HOME:-$HOME/.codex}/skills/$skill_name"}

# Safety: refuse destinations where rm -rf would be catastrophic.
case "$dest" in
  ""|"/"|/bin|/sbin|/etc|/etc/*|/usr|/usr/*|/var|/var/*|/home|/root|"$HOME"|"$HOME/")
    echo "error: refusing to install over '$dest'" >&2
    exit 1
    ;;
esac

if [[ "$dest" != /* ]]; then
  echo "error: destination must be an absolute path: $dest" >&2
  exit 1
fi

if [[ -e "$dest" && ! -d "$dest" ]]; then
  echo "error: destination exists and is not a directory: $dest" >&2
  exit 1
fi

mkdir -p "$(dirname -- "$dest")"
rm -rf "$dest"
mkdir -p "$dest"

for path in SKILL.md agents references scripts; do
  cp -R "$repo_dir/$path" "$dest/"
done

chmod +x "$dest"/scripts/*.sh

echo "Installed to: $dest"
echo 'Invoke with: $delegate-to-deepseek-harness'
