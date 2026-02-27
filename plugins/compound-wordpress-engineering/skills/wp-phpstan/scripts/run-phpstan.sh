#!/usr/bin/env bash
set -euo pipefail

# run-phpstan.sh — Run PHPStan on changed PHP files
#
# Usage: ./run-phpstan.sh [--all] [--json] [--level LEVEL]

MODE="changed"
FORMAT=""
LEVEL=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --all) MODE="all"; shift ;;
    --json) FORMAT="--error-format=json"; shift ;;
    --level) LEVEL="--level=$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Find PHPStan
if [ -f vendor/bin/phpstan ]; then
  PHPSTAN="vendor/bin/phpstan"
elif command -v phpstan &>/dev/null; then
  PHPSTAN="phpstan"
else
  echo "Error: PHPStan not found. Run setup-phpstan.sh first."
  exit 1
fi

case $MODE in
  all)
    echo "Running PHPStan on entire project..."
    $PHPSTAN analyse $LEVEL $FORMAT || true
    ;;
  changed)
    BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    FILES=$(git diff --name-only --diff-filter=d "$BASE"...HEAD -- '*.php' 2>/dev/null || git diff --name-only --diff-filter=d HEAD -- '*.php' 2>/dev/null || true)
    if [ -z "$FILES" ]; then
      echo "No changed PHP files to analyze."
      exit 0
    fi
    echo "Running PHPStan on changed files (vs $BASE)..."
    echo "$FILES" | xargs $PHPSTAN analyse $LEVEL $FORMAT || true
    ;;
esac
