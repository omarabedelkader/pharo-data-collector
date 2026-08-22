#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PHARO_DIR="${PHARO_DIR:-$ROOT_DIR/.pharo}"
PHARO="$PHARO_DIR/pharo"
IMAGE="$PHARO_DIR/Pharo.image"

mkdir -p "$PHARO_DIR"

if [[ ! -x "$PHARO" || ! -f "$IMAGE" ]]; then
  echo "Installing Pharo 13 into $PHARO_DIR"
  (
    cd "$PHARO_DIR"
    curl -fsSL https://get.pharo.org/130+vm | bash
  )
fi

LOAD_EXPRESSION="(Smalltalk globals at: #BaselineOfPharoXPEventRecorder ifAbsent: [ nil ]) ifNotNil: [ :baseline | baseline package removeFromSystem ]. Metacello new baseline: 'PharoXPEventRecorder'; repository: 'tonel://./src'; load: 'Server'. Smalltalk snapshot: true andQuit: true"

(
  cd "$ROOT_DIR"
  "$PHARO" "$IMAGE" eval "$LOAD_EXPRESSION"
)
echo "Local image prepared: $IMAGE"
