#!/usr/bin/env bash
set -euo pipefail

# run-eslint.sh — Run ESLint on changed JS/TS files
#
# Usage: ./run-eslint.sh [--all] [--json] [--fix]

MODE="changed"
FORMAT=""
FIX=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --all) MODE="all"; shift ;;
    --json) FORMAT="--format=json"; shift ;;
    --fix) FIX="--fix"; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Find ESLint
if [ -f node_modules/.bin/eslint ]; then
  ESLINT="npx eslint"
elif command -v eslint &>/dev/null; then
  ESLINT="eslint"
else
  echo "Error: ESLint not found."
  echo "Install: npm install --save-dev @wordpress/scripts"
  echo "  or:    npm install --save-dev eslint @wordpress/eslint-plugin"
  exit 1
fi

case $MODE in
  all)
    echo "Running ESLint on all JS/TS files..."
    $ESLINT $FIX $FORMAT . || true
    ;;
  changed)
    BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    FILES=$(git diff --name-only --diff-filter=d "$BASE"...HEAD -- '*.js' '*.jsx' '*.ts' '*.tsx' 2>/dev/null || git diff --name-only --diff-filter=d HEAD -- '*.js' '*.jsx' '*.ts' '*.tsx' 2>/dev/null || true)
    if [ -z "$FILES" ]; then
      echo "No changed JS/TS files to check."
      exit 0
    fi
    echo "Running ESLint on changed files (vs $BASE)..."
    git diff -z --name-only --diff-filter=d "$BASE"...HEAD -- '*.js' '*.jsx' '*.ts' '*.tsx' 2>/dev/null | xargs -0 $ESLINT $FIX $FORMAT || true
    ;;
esac
