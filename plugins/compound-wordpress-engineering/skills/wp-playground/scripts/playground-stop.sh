#!/usr/bin/env bash
set -euo pipefail

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

# Find processes on the port
PIDS=$(lsof -ti:"$PORT" 2>/dev/null || true)

if [ -z "$PIDS" ]; then
  echo "No process found on port $PORT"
  exit 0
fi

echo "Stopping Playground on port $PORT..."
echo "$PIDS" | xargs kill 2>/dev/null

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
lsof -ti:"$PORT" 2>/dev/null | xargs kill -9 2>/dev/null || true
echo "Playground stopped."
