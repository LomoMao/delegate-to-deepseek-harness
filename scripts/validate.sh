#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

for f in "$repo_dir"/scripts/*.sh; do
  bash -n "$f"
done

python3 "$repo_dir/scripts/validate_skill.py" "$repo_dir"

echo "validation: ok"
