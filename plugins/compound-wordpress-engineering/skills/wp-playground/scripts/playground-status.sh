#!/usr/bin/env bash
set -euo pipefail

# playground-status.sh — Check WordPress Playground health
#
# Usage: ./playground-status.sh [--port PORT]

PORT="${1:-9400}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --port) PORT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

echo "WordPress Playground Status"
echo "==========================="
echo ""

# Check if running
PIDS=$(lsof -ti:"$PORT" 2>/dev/null || true)
if [ -z "$PIDS" ]; then
  echo "Status: NOT RUNNING"
  echo "Port:   $PORT (available)"
  exit 1
fi

echo "Status: RUNNING"
echo "Port:   $PORT"
echo "PID:    $PIDS"
echo ""

# Check HTTP response
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT" 2>/dev/null || echo "000")
echo "HTTP:   $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
  echo "URL:    http://localhost:$PORT"
  echo "Admin:  http://localhost:$PORT/wp-admin/"
  echo ""

  # Try to get WP version via REST API
  WP_VERSION=$(curl -s "http://localhost:$PORT/wp-json/" 2>/dev/null | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "unknown")
  echo "WordPress Version: $WP_VERSION"

  # Check active plugins
  echo ""
  echo "Active Plugins:"
  curl -s "http://localhost:$PORT/wp-json/wp/v2/plugins" \
    -H "Authorization: Basic $(echo -n 'admin:password' | base64)" 2>/dev/null \
    | grep -o '"plugin":"[^"]*"' | cut -d'"' -f4 || echo "  (unable to query — authentication may be required)"
else
  echo "Warning: Server on port $PORT is not returning HTTP 200"
fi
