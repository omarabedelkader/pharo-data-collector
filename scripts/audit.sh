#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$ROOT_DIR"/scripts/*.sh

if grep -RqsE 'github://Pharo-XP-Tools/EventRecorder|gitlocal://' "$ROOT_DIR/src"; then
  echo "Found a removed cross-repository dependency" >&2
  exit 1
fi

ROOT_DIR="$ROOT_DIR" python3 - <<'PY'
import os
import re
from collections import Counter
from pathlib import Path

root = Path(os.environ['ROOT_DIR']) / 'src'

for package in (path for path in root.iterdir() if path.is_dir()):
    if not (package / 'package.st').is_file():
        raise SystemExit(f'Missing package.st: {package}')

classes = []
for path in root.rglob('*.class.st'):
    match = re.search(r'#name\s*:\s*#([A-Za-z0-9_]+)', path.read_text(errors='replace'))
    if match is None:
        raise SystemExit(f'Cannot read class name: {path}')
    classes.append(match.group(1))

duplicates = [name for name, count in Counter(classes).items() if count > 1]
if duplicates:
    raise SystemExit('Duplicate classes: ' + ', '.join(sorted(duplicates)))

pairs = {')': '(', ']': '[', '}': '{'}
openers = set(pairs.values())

for path in root.rglob('*.st'):
    source = path.read_text(errors='replace')
    stack = []
    state = 'code'
    index = 0
    line = 1
    while index < len(source):
        char = source[index]
        if char == '\n':
            line += 1
        if state == 'code':
            if char == '"':
                state = 'comment'
            elif char == "'":
                state = 'string'
            elif char in openers:
                stack.append((char, line))
            elif char in pairs:
                if not stack or stack[-1][0] != pairs[char]:
                    raise SystemExit(f'Unbalanced {char} in {path}:{line}')
                stack.pop()
        elif state == 'comment':
            if char == '"':
                state = 'code'
        elif char == "'":
            if index + 1 < len(source) and source[index + 1] == "'":
                index += 1
            else:
                state = 'code'
        index += 1

    if state != 'code':
        raise SystemExit(f'Unclosed {state} in {path}')
    if stack:
        raise SystemExit(f'Unclosed delimiter in {path}:{stack[-1][1]}')

print(f'Audit passed: {len(classes)} classes, {len(list(root.rglob("*.st")))} Tonel/ST files')
PY
