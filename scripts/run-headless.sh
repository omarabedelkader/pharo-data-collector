#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PHARO_DIR="${PHARO_DIR:-$ROOT_DIR/.pharo}"
PHARO="$PHARO_DIR/pharo"
IMAGE="$PHARO_DIR/Pharo.image"
MODE="${1:-}"

usage() {
  cat <<'USAGE'
Usage:
  scripts/run-headless.sh server
  scripts/run-headless.sh dispatcher
  scripts/run-headless.sh client [smalltalk-file.st]
  scripts/run-headless.sh stop-server
  scripts/run-headless.sh stop-dispatcher

Environment:
  PX_PORT                  Server port, default 8008.
  PX_DATA_DIR              Server data directory, default ./var/data.
  PX_ENDPOINT              Client endpoint, default http://localhost:8008/events.
  PX_RUN_DIR               PID directory, default ./var/run.
  PX_PID_FILE              Server PID file override.
  PHEX_DISPATCHER_PORT     Dispatcher port, default 8080.
  PHEX_REDIRECTIONS_FILE   Dispatcher JSON file, default ./redirections.json.
  PHEX_PID_FILE            Dispatcher PID file override.
  PX_CLIENT_EXPRESSION     Optional Smalltalk code evaluated by client mode.
USAGE
}

if [[ -z "$MODE" || "$MODE" == "-h" || "$MODE" == "--help" ]]; then
  usage
  exit 0
fi

st_escape() {
  printf '%s' "$1" | sed "s/'/''/g"
}

ensure_image() {
  if [[ ! -x "$PHARO" || ! -f "$IMAGE" ]]; then
    "$ROOT_DIR/scripts/bootstrap-local.sh"
  fi
}

absolute_path() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s\n' "$PWD/$path"
  fi
}

validate_port() {
  local name="$1"
  local value="$2"
  if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value < 1 || value > 65535 )); then
    echo "$name must be an integer between 1 and 65535" >&2
    exit 2
  fi
}

pid_is_running() {
  local pid="$1"
  [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null
}

server_pid_file_for_port() {
  local port="$1"
  printf '%s\n' "${PX_PID_FILE:-${PX_RUN_DIR:-$ROOT_DIR/var/run}/pharo-xp-event-recorder-$port.pid}"
}

dispatcher_pid_file_for_port() {
  local port="$1"
  printf '%s\n' "${PHEX_PID_FILE:-${PX_RUN_DIR:-$ROOT_DIR/var/run}/phex-data-dispatcher-$port.pid}"
}

listener_pids_for_port() {
  local port="$1"
  command -v lsof >/dev/null 2>&1 || return 0
  lsof -ti TCP:"$port" -sTCP:LISTEN 2>/dev/null || true
}

ensure_port_available() {
  local port="$1"
  local pids
  pids="$(listener_pids_for_port "$port")"
  if [[ -n "$pids" ]]; then
    echo "Port $port is already in use by PID(s): ${pids//$'\n'/ }" >&2
    exit 1
  fi
}

ensure_pid_available() {
  local label="$1"
  local pid_file="$2"
  local pid
  mkdir -p "$(dirname "$pid_file")"
  if [[ ! -f "$pid_file" ]]; then
    return 0
  fi

  pid="$(tr -d '[:space:]' < "$pid_file")"
  if pid_is_running "$pid"; then
    echo "$label already appears to be running as PID $pid." >&2
    echo "Use the matching stop mode first, or choose another port." >&2
    exit 1
  fi
  rm -f "$pid_file"
}

add_pid() {
  local pid="$1"

  [[ "$pid" =~ ^[0-9]+$ ]] || return 0
  case " $PIDS " in
    *" $pid "*) return 0 ;;
  esac
  PIDS="${PIDS:+$PIDS }$pid"
}

stop_by_port_and_pid_file() {
  local label="$1"
  local port="$2"
  local pid_file="$3"
  local pid
  local still_running
  local after_kill
  PIDS=""

  if [[ -f "$pid_file" ]]; then
    pid="$(tr -d '[:space:]' < "$pid_file")"
    if pid_is_running "$pid"; then
      add_pid "$pid"
    else
      rm -f "$pid_file"
    fi
  fi

  if command -v lsof >/dev/null 2>&1; then
    while IFS= read -r pid; do
      add_pid "$pid"
    done < <(lsof -ti TCP:"$port" -sTCP:LISTEN 2>/dev/null || true)
  fi

  if [[ -z "$PIDS" ]]; then
    echo "No running $label found on port $port."
    return 0
  fi

  echo "Stopping $label on port $port: $PIDS"
  for pid in $PIDS; do
    kill "$pid" 2>/dev/null || true
  done

  for _ in {1..50}; do
    still_running=""
    for pid in $PIDS; do
      if pid_is_running "$pid"; then
        still_running="${still_running:+$still_running }$pid"
      fi
    done

    if [[ -z "$still_running" ]]; then
      rm -f "$pid_file"
      echo "Stopped."
      return 0
    fi

    sleep 0.1
  done

  echo "Process(es) still running after SIGTERM, sending SIGKILL: $still_running" >&2
  for pid in $still_running; do
    kill -KILL "$pid" 2>/dev/null || true
  done

  for _ in {1..20}; do
    after_kill=""
    for pid in $still_running; do
      if pid_is_running "$pid"; then
        after_kill="${after_kill:+$after_kill }$pid"
      fi
    done

    if [[ -z "$after_kill" ]]; then
      rm -f "$pid_file"
      echo "Stopped."
      return 0
    fi

    sleep 0.1
  done

  echo "Process(es) still running after SIGKILL: $after_kill" >&2
  return 1
}

load_group() {
  local group="$1"
  local escaped_group
  escaped_group="$(st_escape "$group")"
  (
    cd "$ROOT_DIR"
    "$PHARO" "$IMAGE" eval \
      "(Smalltalk globals at: #BaselineOfPharoXPEventRecorder ifAbsent: [ nil ]) ifNotNil: [ :baseline | baseline package removeFromSystem ]. Metacello new baseline: 'PharoXPEventRecorder'; repository: 'tonel://./src'; load: '$escaped_group'. Smalltalk snapshot: true andQuit: true"
  )
}

run_server() {
  local port="${PX_PORT:-8008}"
  local data_dir
  local escaped_data_dir
  local pid_file
  data_dir="$(absolute_path "${PX_DATA_DIR:-$ROOT_DIR/var/data}")"
  validate_port "PX_PORT" "$port"
  pid_file="$(server_pid_file_for_port "$port")"
  ensure_pid_available "Pharo-XP EventRecorder" "$pid_file"
  ensure_port_available "$port"
  ensure_image
  escaped_data_dir="$(st_escape "$data_dir")"
  load_group "Server"
  mkdir -p "$data_dir"
  cd "$ROOT_DIR"
  echo "Starting Pharo-XP EventRecorder on http://localhost:$port"
  echo "Data directory: $data_dir"
  echo "PID file: $pid_file"
  printf '%s\n' "$$" > "$pid_file"
  exec "$PHARO" "$IMAGE" eval --no-quit \
    "PXServer port: $port. PXServer dataDirectory: '$escaped_data_dir'. PXServer start"
}

run_dispatcher() {
  local port="${PHEX_DISPATCHER_PORT:-8080}"
  local redirections_file
  local escaped_redirections_file
  local pid_file
  redirections_file="$(absolute_path "${PHEX_REDIRECTIONS_FILE:-$ROOT_DIR/redirections.json}")"
  validate_port "PHEX_DISPATCHER_PORT" "$port"
  pid_file="$(dispatcher_pid_file_for_port "$port")"
  ensure_pid_available "Phex Data Dispatcher" "$pid_file"
  ensure_port_available "$port"
  if [[ ! -f "$redirections_file" ]]; then
    echo "Missing dispatcher redirections file: $redirections_file" >&2
    exit 1
  fi
  ensure_image
  escaped_redirections_file="$(st_escape "$redirections_file")"
  load_group "Dispatcher"
  cd "$ROOT_DIR"
  echo "Starting Phex Data Dispatcher on http://localhost:$port"
  echo "Redirections file: $redirections_file"
  echo "PID file: $pid_file"
  printf '%s\n' "$$" > "$pid_file"
  exec "$PHARO" "$IMAGE" eval --no-quit \
    "PhexDataDispatcher start: $port redirectionsFile: '$escaped_redirections_file'"
}

run_client() {
  local endpoint="${PX_ENDPOINT:-http://localhost:8008/events}"
  local escaped_endpoint
  local expression=""
  escaped_endpoint="$(st_escape "$endpoint")"
  ensure_image
  load_group "Client"

  if [[ $# -gt 0 ]]; then
    local client_file="$1"
    if [[ ! -f "$client_file" ]]; then
      echo "Missing client Smalltalk file: $client_file" >&2
      exit 1
    fi
    client_file="$(absolute_path "$client_file")"
    expression="FileStream fileIn: '$(st_escape "$client_file")'."
  elif [[ -n "${PX_CLIENT_EXPRESSION:-}" ]]; then
    expression="$PX_CLIENT_EXPRESSION"
  else
    echo "Client mode needs a Smalltalk file argument or PX_CLIENT_EXPRESSION." >&2
    exit 1
  fi

  cd "$ROOT_DIR"
  echo "Running client against $endpoint"
  "$PHARO" "$IMAGE" eval \
    "PXEventRecorder endpoint: '$escaped_endpoint'. ERPrivacy sendDiagnosticsAndUsageData: true. $expression Smalltalk snapshot: false andQuit: true"
}

stop_server() {
  local port="${PX_PORT:-8008}"
  validate_port "PX_PORT" "$port"
  stop_by_port_and_pid_file \
    "Pharo-XP EventRecorder" \
    "$port" \
    "$(server_pid_file_for_port "$port")"
}

stop_dispatcher() {
  local port="${PHEX_DISPATCHER_PORT:-8080}"
  validate_port "PHEX_DISPATCHER_PORT" "$port"
  stop_by_port_and_pid_file \
    "Phex Data Dispatcher" \
    "$port" \
    "$(dispatcher_pid_file_for_port "$port")"
}

case "$MODE" in
  server)
    shift
    run_server "$@"
    ;;
  dispatcher)
    shift
    run_dispatcher "$@"
    ;;
  client)
    shift
    run_client "$@"
    ;;
  stop-server)
    shift
    stop_server "$@"
    ;;
  stop-dispatcher)
    shift
    stop_dispatcher "$@"
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
