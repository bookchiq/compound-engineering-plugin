#!/usr/bin/env bash
set -euo pipefail

# run-phpcs.sh — Run PHPCS on changed PHP files
#
# Usage: ./run-phpcs.sh [--all] [--staged] [--json]

MODE="changed"
FORMAT="full"

while [[ $# -gt 0 ]]; do
  case $1 in
    --all) MODE="all"; shift ;;
    --staged) MODE="staged"; shift ;;
    --json) FORMAT="json"; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Find PHPCS
if [ -f vendor/bin/phpcs ]; then
  PHPCS="vendor/bin/phpcs"
elif command -v phpcs &>/dev/null; then
  PHPCS="phpcs"
else
  echo "Error: PHPCS not found. Run setup-phpcs.sh first."
  exit 1
fi

# Determine standard
if [ -f phpcs.xml.dist ] || [ -f phpcs.xml ]; then
  STANDARD=""  # Uses project config
else
  STANDARD="--standard=WordPress"
fi

# Determine files to check
case $MODE in
  all)
    echo "Running PHPCS on all PHP files..."
    $PHPCS $STANDARD --report="$FORMAT" . || true
    ;;
  staged)
    FILES=$(git diff --cached --name-only --diff-filter=d -- '*.php' 2>/dev/null || true)
    if [ -z "$FILES" ]; then
      echo "No staged PHP files to check."
      exit 0
    fi
    echo "Running PHPCS on staged files..."
    git diff --cached -z --name-only --diff-filter=d -- '*.php' 2>/dev/null | xargs -0 $PHPCS $STANDARD --report="$FORMAT" || true
    ;;
  changed)
    # Try to find the base branch
    BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    FILES=$(git diff --name-only --diff-filter=d "$BASE"...HEAD -- '*.php' 2>/dev/null || git diff --name-only --diff-filter=d HEAD -- '*.php' 2>/dev/null || true)
    if [ -z "$FILES" ]; then
      echo "No changed PHP files to check."
      exit 0
    fi
    echo "Running PHPCS on changed files (vs $BASE)..."
    git diff -z --name-only --diff-filter=d "$BASE"...HEAD -- '*.php' 2>/dev/null | xargs -0 $PHPCS $STANDARD --report="$FORMAT" || true
    ;;
esac
