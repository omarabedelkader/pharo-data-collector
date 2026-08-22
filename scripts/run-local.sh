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

RUN_DIR="${PX_RUN_DIR:-$ROOT_DIR/var/run}"
PID_FILE="${PX_PID_FILE:-$RUN_DIR/pharo-xp-event-recorder-$PORT.pid}"

pid_is_running() {
  local pid="$1"
  [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null
}

listener_pids_for_port() {
  command -v lsof >/dev/null 2>&1 || return 0
  lsof -ti TCP:"$PORT" -sTCP:LISTEN 2>/dev/null || true
}

mkdir -p "$RUN_DIR"

if [[ -f "$PID_FILE" ]]; then
  EXISTING_PID="$(tr -d '[:space:]' < "$PID_FILE")"
  if pid_is_running "$EXISTING_PID"; then
    echo "Pharo-XP EventRecorder already appears to be running as PID $EXISTING_PID on port $PORT." >&2
    echo "Run ./scripts/run-stop.sh first, or set PX_PORT to use another port." >&2
    exit 1
  fi
  rm -f "$PID_FILE"
fi

LISTENER_PIDS="$(listener_pids_for_port)"
if [[ -n "$LISTENER_PIDS" ]]; then
  LISTENER_PIDS_INLINE="${LISTENER_PIDS//$'\n'/ }"
  echo "Port $PORT is already in use by PID(s): $LISTENER_PIDS_INLINE" >&2
  echo "Run ./scripts/run-stop.sh first, or set PX_PORT to use another port." >&2
  exit 1
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
echo "PID file: $PID_FILE"
printf '%s\n' "$$" > "$PID_FILE"
cd "$ROOT_DIR"
exec "$PHARO" "$IMAGE" eval --no-quit "$START_EXPRESSION"
