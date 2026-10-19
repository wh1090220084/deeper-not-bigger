#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test -f "$ROOT/SKILL.md"
test -f "$ROOT/manifest.json"
test -f "$ROOT/agents/openai.yaml"
grep -q 'name: ambitious-task-upgrader' "$ROOT/SKILL.md"
grep -q 'L1' "$ROOT/SKILL.md"
grep -q 'L2' "$ROOT/SKILL.md"
grep -q 'L3' "$ROOT/SKILL.md"
grep -q 'validation-markers: prompt-rewrite,external-review' "$ROOT/SKILL.md"
python3 - "$ROOT" <<'PY'
import json, pathlib, sys
root = pathlib.Path(sys.argv[1])
data = json.loads((root / 'manifest.json').read_text(encoding='utf-8'))
assert data['name'] == 'ambitious-task-upgrader'
assert all((root / item).is_file() for item in data['files'])
print(f"OK: {data['name']} v{data['version']}")
PY
