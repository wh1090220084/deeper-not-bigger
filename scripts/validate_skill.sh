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
grep -q 'awaiting_confirmation' "$ROOT/SKILL.md"
grep -q '多轮状态协议' "$ROOT/SKILL.md"
grep -q '沉默不等于同意' "$ROOT/SKILL.md"
python3 - "$ROOT" <<'PY'
import json, pathlib, sys
root = pathlib.Path(sys.argv[1])
data = json.loads((root / 'manifest.json').read_text(encoding='utf-8'))
assert data['name'] == 'ambitious-task-upgrader'
assert all((root / item).is_file() for item in data['files'])
cases = json.loads((root / 'evals/behavioral_cases.json').read_text(encoding='utf-8'))
assert len(cases) >= 5 and all(c.get('id') and c.get('prompt') and c.get('must') for c in cases)
print(f"OK: {data['name']} v{data['version']}")
PY
