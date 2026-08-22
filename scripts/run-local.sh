#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PHARO_DIR="${PHARO_DIR:-$ROOT_DIR/.pharo}"
PHARO="$PHARO_DIR/pharo"
IMAGE="$PHARO_DIR/Pharo.image"
DATA_DIR="${PX_DATA_DIR:-$ROOT_DIR/var/data}"
PORT="${PX_PORT:-8008}"

if [[ ! "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
  echo "PX_PORT must be an integer between 1 and 65535" >&2
  exit 2
fi

# Always reload the local Tonel sources so a restarted development server
# cannot accidentally run a stale image.
"$ROOT_DIR/scripts/bootstrap-local.sh"
mkdir -p "$DATA_DIR"

# Escape single quotes for a Smalltalk string literal.
st_escape() {
  printf '%s' "$1" | sed "s/'/''/g"
}

DATA_DIR_ST="$(st_escape "$DATA_DIR")"
START_EXPRESSION="PXServer port: $PORT. PXServer dataDirectory: '$DATA_DIR_ST'. PXServer start"

echo "Starting Pharo-XP EventRecorder on http://localhost:$PORT"
echo "Data directory: $DATA_DIR"
cd "$ROOT_DIR"
exec "$PHARO" "$IMAGE" eval --no-quit "$START_EXPRESSION"
