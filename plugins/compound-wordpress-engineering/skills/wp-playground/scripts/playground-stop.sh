#!/usr/bin/env bash
set -euo pipefail

validate_port() {
  if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt 65535 ]; then
    echo "Error: Invalid port number: $1 (must be 1-65535)"
    exit 1
  fi
}

# playground-stop.sh — Stop running WordPress Playground instances
#
# Usage: ./playground-stop.sh [--port PORT]

PORT="${1:-9400}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --port) PORT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

validate_port "$PORT"

# Find and validate processes on the port
PIDS_RAW=$(lsof -ti:"$PORT" 2>/dev/null || true)

if [ -z "$PIDS_RAW" ]; then
  echo "No process found on port $PORT"
  exit 0
fi

# Validate PIDs are numeric
PIDS=""
for pid in $PIDS_RAW; do
  if [[ "$pid" =~ ^[0-9]+$ ]]; then
    PIDS="$PIDS $pid"
  fi
done
PIDS=$(echo "$PIDS" | xargs)  # trim whitespace

if [ -z "$PIDS" ]; then
  echo "No valid process found on port $PORT"
  exit 0
fi

echo "Stopping Playground on port $PORT (PIDs: $PIDS)..."
kill $PIDS 2>/dev/null || true

# Wait for process to stop
for i in $(seq 1 5); do
  if ! lsof -ti:"$PORT" &>/dev/null; then
    echo "Playground stopped."
    exit 0
  fi
  sleep 1
done

# Force kill if still running
echo "Force stopping..."
FORCE_PIDS=$(lsof -ti:"$PORT" 2>/dev/null || true)
for pid in $FORCE_PIDS; do
  if [[ "$pid" =~ ^[0-9]+$ ]]; then
    kill -9 "$pid" 2>/dev/null || true
  fi
done
echo "Playground stopped."
