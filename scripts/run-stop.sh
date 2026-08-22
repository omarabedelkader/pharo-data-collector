#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${PX_PORT:-8008}"

if [[ ! "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
  echo "PX_PORT must be an integer between 1 and 65535" >&2
  exit 2
fi

RUN_DIR="${PX_RUN_DIR:-$ROOT_DIR/var/run}"
PID_FILE="${PX_PID_FILE:-$RUN_DIR/pharo-xp-event-recorder-$PORT.pid}"
PIDS=""

pid_is_running() {
  local pid="$1"
  [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null
}

add_pid() {
  local pid="$1"

  [[ "$pid" =~ ^[0-9]+$ ]] || return 0
  case " $PIDS " in
    *" $pid "*) return 0 ;;
  esac
  PIDS="${PIDS:+$PIDS }$pid"
}

if [[ -f "$PID_FILE" ]]; then
  PID="$(tr -d '[:space:]' < "$PID_FILE")"
  if pid_is_running "$PID"; then
    add_pid "$PID"
  else
    rm -f "$PID_FILE"
  fi
fi

if command -v lsof >/dev/null 2>&1; then
  while IFS= read -r PID; do
    add_pid "$PID"
  done < <(lsof -ti TCP:"$PORT" -sTCP:LISTEN 2>/dev/null || true)
fi

if [[ -z "$PIDS" ]]; then
  echo "No running Pharo-XP EventRecorder found on port $PORT."
  exit 0
fi

echo "Stopping Pharo-XP EventRecorder on port $PORT: $PIDS"
for PID in $PIDS; do
  kill "$PID" 2>/dev/null || true
done

for _ in {1..50}; do
  STILL_RUNNING=""
  for PID in $PIDS; do
    if pid_is_running "$PID"; then
      STILL_RUNNING="${STILL_RUNNING:+$STILL_RUNNING }$PID"
    fi
  done

  if [[ -z "$STILL_RUNNING" ]]; then
    rm -f "$PID_FILE"
    echo "Stopped."
    exit 0
  fi

  sleep 0.1
done

echo "Process(es) still running after SIGTERM, sending SIGKILL: $STILL_RUNNING" >&2
for PID in $STILL_RUNNING; do
  kill -KILL "$PID" 2>/dev/null || true
done

for _ in {1..20}; do
  AFTER_KILL=""
  for PID in $STILL_RUNNING; do
    if pid_is_running "$PID"; then
      AFTER_KILL="${AFTER_KILL:+$AFTER_KILL }$PID"
    fi
  done

  if [[ -z "$AFTER_KILL" ]]; then
    rm -f "$PID_FILE"
    echo "Stopped."
    exit 0
  fi

  sleep 0.1
done

echo "Process(es) still running after SIGKILL: $AFTER_KILL" >&2
exit 1
