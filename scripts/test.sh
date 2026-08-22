#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PHARO_DIR="${PHARO_DIR:-$ROOT_DIR/.pharo}"
PHARO="$PHARO_DIR/pharo"
IMAGE="$PHARO_DIR/Pharo.image"

if [[ ! -x "$PHARO" || ! -f "$IMAGE" ]]; then
  "$ROOT_DIR/scripts/bootstrap-local.sh"
fi

LOAD_EXPRESSION="Metacello new baseline: 'PharoXPEventRecorder'; repository: 'tonel://./src'; load: 'Tests'. Smalltalk snapshot: true andQuit: true"
(
  cd "$ROOT_DIR"
  "$PHARO" "$IMAGE" eval "$LOAD_EXPRESSION"
)

cd "$ROOT_DIR"
"$PHARO" "$IMAGE" test 'EventRecorder-.*'
"$PHARO" "$IMAGE" test 'Pharo-XP-EventRecorder-.*'
