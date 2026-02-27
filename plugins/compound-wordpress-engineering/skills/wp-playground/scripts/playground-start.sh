#!/usr/bin/env bash
set -euo pipefail

validate_port() {
  if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt 65535 ]; then
    echo "Error: Invalid port number: $1 (must be 1-65535)"
    exit 1
  fi
}

# playground-start.sh — Start WordPress Playground with project-aware mounting
#
# Usage: ./playground-start.sh [--port PORT] [--wp VERSION] [--blueprint FILE]

PORT="${1:-9400}"
WP_VERSION=""
BLUEPRINT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --port) PORT="$2"; shift 2 ;;
    --wp) WP_VERSION="$2"; shift 2 ;;
    --blueprint) BLUEPRINT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

validate_port "$PORT"

# Check prerequisites
if ! command -v node &>/dev/null; then
  echo "Error: Node.js is required but not installed."
  exit 1
fi

NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
  echo "Error: Node.js 20+ required, found $(node -v)"
  exit 1
fi

# Check if port is already in use
if lsof -ti:"$PORT" &>/dev/null; then
  echo "Warning: Port $PORT is already in use."
  echo "Run: lsof -ti:$PORT | xargs kill"
  exit 1
fi

# Detect project type and build mount flags
MOUNT_FLAGS=""
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr -cd 'a-zA-Z0-9_-')
if [ -z "$PROJECT_NAME" ]; then
  echo "Error: Could not determine safe project name from directory."
  exit 1
fi

if grep -ql "Plugin Name:" ./*.php 2>/dev/null; then
  echo "Detected: WordPress plugin"
  MOUNT_FLAGS="--mount=.:/wordpress/wp-content/plugins/$PROJECT_NAME"
elif [ -f style.css ] && grep -q "Theme Name:" style.css 2>/dev/null; then
  echo "Detected: WordPress theme"
  MOUNT_FLAGS="--mount=.:/wordpress/wp-content/themes/$PROJECT_NAME"
elif [ -f block.json ]; then
  echo "Detected: WordPress block (mounting as plugin)"
  MOUNT_FLAGS="--mount=.:/wordpress/wp-content/plugins/$PROJECT_NAME"
else
  echo "No WordPress project detected — using --auto-mount"
  MOUNT_FLAGS="--auto-mount"
fi

# Build command as array (prevents word splitting/injection)
CMD=(npx --yes @wp-playground/cli@latest server)

# Add mount flags (may contain spaces in paths)
if [ "$MOUNT_FLAGS" = "--auto-mount" ]; then
  CMD+=(--auto-mount)
else
  CMD+=("$MOUNT_FLAGS")
fi

CMD+=("--port=$PORT")

if [ -n "$WP_VERSION" ]; then
  CMD+=("--wp=$WP_VERSION")
fi

if [ -n "$BLUEPRINT" ]; then
  CMD+=("--blueprint=$BLUEPRINT")
fi

echo "Starting WordPress Playground..."
echo "Command: ${CMD[*]}"
echo ""

# Start in background
"${CMD[@]}" &
PG_PID=$!

# Wait for ready
echo "Waiting for Playground to be ready..."
for i in $(seq 1 30); do
  if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT" 2>/dev/null | grep -q "200"; then
    echo ""
    echo "WordPress Playground is ready!"
    echo "  URL:   http://localhost:$PORT"
    echo "  Admin: http://localhost:$PORT/wp-admin/"
    echo "  Login: admin / password"
    echo "  PID:   $PG_PID"
    exit 0
  fi
  printf "."
  sleep 1
done

echo ""
echo "Warning: Playground started but not responding after 30s."
echo "PID: $PG_PID — check logs or try: curl http://localhost:$PORT"
