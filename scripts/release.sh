#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$ROOT/scripts/validate_skill.sh"
VERSION="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["version"])' "$ROOT/manifest.json")"
NAME="ambitious-task-upgrader"
DIST="$ROOT/dist"
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
mkdir -p "$DIST" "$STAGING/$NAME"
python3 - "$ROOT" "$STAGING/$NAME" <<'PY'
import json, pathlib, shutil, sys
root, dest = map(pathlib.Path, sys.argv[1:])
data = json.loads((root / 'manifest.json').read_text(encoding='utf-8'))
for item in data['files']:
    source, target = root / item, dest / item
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)
PY
(cd "$STAGING" && zip -qr "$DIST/$NAME-v$VERSION.zip" "$NAME")
echo "Created: $DIST/$NAME-v$VERSION.zip"
