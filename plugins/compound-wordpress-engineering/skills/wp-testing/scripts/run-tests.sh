#!/usr/bin/env bash
set -euo pipefail

# run-tests.sh — Auto-detect and run WordPress test suites
#
# Usage: ./run-tests.sh [--unit|--integration|--browser|--all]

SUITE="all"

while [[ $# -gt 0 ]]; do
  case $1 in
    --unit) SUITE="unit"; shift ;;
    --integration) SUITE="integration"; shift ;;
    --browser) SUITE="browser"; shift ;;
    --all) SUITE="all"; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

PASS=0
FAIL=0
SKIP=0

run_phpunit() {
  local testsuite="$1"
  local label="$2"

  echo "=== $label ==="

  # Find PHPUnit binary
  if [ -f vendor/bin/phpunit ]; then
    PHPUNIT="vendor/bin/phpunit"
  elif command -v phpunit &>/dev/null; then
    PHPUNIT="phpunit"
  else
    echo "PHPUnit not found. Run: composer require --dev phpunit/phpunit"
    SKIP=$((SKIP + 1))
    return
  fi

  if [ -f phpunit.xml.dist ] || [ -f phpunit.xml ]; then
    if $PHPUNIT --testsuite "$testsuite" 2>/dev/null; then
      PASS=$((PASS + 1))
      echo "PASSED: $label"
    else
      FAIL=$((FAIL + 1))
      echo "FAILED: $label"
    fi
  else
    echo "No phpunit.xml.dist found. Run scaffold-tests.sh first."
    SKIP=$((SKIP + 1))
  fi

  echo ""
}

# Run requested suites
case $SUITE in
  unit)
    run_phpunit "unit" "Unit Tests"
    ;;
  integration)
    run_phpunit "integration" "Integration Tests"
    ;;
  browser)
    echo "=== Browser Tests ==="
    echo "Run: /test-browser"
    echo "Browser tests are executed via the test-browser command or Playwright MCP."
    SKIP=$((SKIP + 1))
    echo ""
    ;;
  all)
    run_phpunit "unit" "Unit Tests"
    run_phpunit "integration" "Integration Tests"
    echo "=== Browser Tests ==="
    echo "Run /test-browser separately for browser tests."
    echo ""
    ;;
esac

# Summary
echo "=== Test Summary ==="
echo "  Passed:  $PASS"
echo "  Failed:  $FAIL"
echo "  Skipped: $SKIP"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "RESULT: FAIL"
  exit 1
else
  echo "RESULT: PASS"
fi
