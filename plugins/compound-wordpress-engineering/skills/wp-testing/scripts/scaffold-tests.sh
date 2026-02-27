#!/usr/bin/env bash
set -euo pipefail

# scaffold-tests.sh — Scaffold WordPress test infrastructure
#
# Usage: ./scaffold-tests.sh --type plugin|theme|block
#
# Safe to re-run: never overwrites existing files.

TYPE="plugin"

while [[ $# -gt 0 ]]; do
  case $1 in
    --type) TYPE="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

echo "Scaffolding $TYPE test infrastructure for: $PROJECT_NAME"
echo ""

# Create test directories
for dir in tests tests/unit tests/integration; do
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    echo "Created: $dir/"
  else
    echo "Exists:  $dir/"
  fi
done

# Create phpunit.xml.dist
if [ ! -f phpunit.xml.dist ]; then
  cat > phpunit.xml.dist << 'XMLEOF'
<?xml version="1.0"?>
<phpunit
  bootstrap="tests/bootstrap.php"
  backupGlobals="false"
  colors="true"
  convertErrorsToExceptions="true"
  convertNoticesToExceptions="true"
  convertWarningsToExceptions="true"
>
  <testsuites>
    <testsuite name="unit">
      <directory suffix="Test.php">./tests/unit</directory>
    </testsuite>
    <testsuite name="integration">
      <directory suffix="Test.php">./tests/integration</directory>
    </testsuite>
  </testsuites>
  <php>
    <env name="WP_PHPUNIT__TESTS_CONFIG" value="tests/wp-tests-config.php"/>
  </php>
</phpunit>
XMLEOF
  echo "Created: phpunit.xml.dist"
else
  echo "Exists:  phpunit.xml.dist"
fi

# Create tests/bootstrap.php
if [ ! -f tests/bootstrap.php ]; then
  cat > tests/bootstrap.php << 'PHPEOF'
<?php
/**
 * PHPUnit bootstrap file.
 */

// Composer autoloader.
require_once dirname( __DIR__ ) . '/vendor/autoload.php';

// Determine test type from PHPUnit args or default to integration.
$is_unit = defined( 'WP_PHPUNIT__UNIT_TESTS' ) || getenv( 'WP_PHPUNIT__UNIT_TESTS' );

if ( ! $is_unit ) {
	// Load WordPress test environment for integration tests.
	$_tests_dir = getenv( 'WP_TESTS_DIR' );

	if ( ! $_tests_dir ) {
		$_tests_dir = rtrim( sys_get_temp_dir(), '/\\' ) . '/wordpress-tests-lib';
	}

	// Give access to tests_add_filter() function.
	require_once $_tests_dir . '/includes/functions.php';

	/**
	 * Manually load the plugin being tested.
	 */
	tests_add_filter(
		'muplugins_loaded',
		function () {
			require dirname( __DIR__ ) . '/PLUGIN_FILE_HERE.php';
		}
	);

	// Start up the WP testing environment.
	require $_tests_dir . '/includes/bootstrap.php';
}
PHPEOF
  echo "Created: tests/bootstrap.php"
  echo "  NOTE: Edit tests/bootstrap.php to set your main plugin file path"
else
  echo "Exists:  tests/bootstrap.php"
fi

# Create sample unit test
if [ ! -f tests/unit/SampleTest.php ]; then
  cat > tests/unit/SampleTest.php << 'PHPEOF'
<?php
/**
 * Sample unit test.
 *
 * Unit tests do not load WordPress — test pure PHP logic only.
 */

use PHPUnit\Framework\TestCase;

class SampleTest extends TestCase {

	public function test_example() {
		$this->assertTrue( true, 'Sample test should pass' );
	}
}
PHPEOF
  echo "Created: tests/unit/SampleTest.php"
else
  echo "Exists:  tests/unit/SampleTest.php"
fi

# Create sample integration test
if [ ! -f tests/integration/SampleIntegrationTest.php ]; then
  cat > tests/integration/SampleIntegrationTest.php << 'PHPEOF'
<?php
/**
 * Sample integration test.
 *
 * Integration tests load WordPress — test hooks, DB, REST API, etc.
 */

class SampleIntegrationTest extends WP_UnitTestCase {

	public function test_wordpress_loaded() {
		$this->assertTrue( function_exists( 'do_action' ), 'WordPress should be loaded' );
	}

	public function test_plugin_activated() {
		// Replace with your plugin's activation check.
		$this->assertTrue( true, 'Plugin should be active' );
	}
}
PHPEOF
  echo "Created: tests/integration/SampleIntegrationTest.php"
else
  echo "Exists:  tests/integration/SampleIntegrationTest.php"
fi

# Add Composer dependencies if composer.json exists
if [ -f composer.json ]; then
  echo ""
  echo "Checking Composer dependencies..."

  NEEDS_INSTALL=false

  if ! grep -q '"phpunit/phpunit"' composer.json; then
    echo "  Adding phpunit/phpunit..."
    composer require --dev phpunit/phpunit:"^9.0 || ^10.0" --no-interaction 2>/dev/null || echo "  Run: composer require --dev phpunit/phpunit"
    NEEDS_INSTALL=true
  fi

  if ! grep -q '"yoast/phpunit-polyfills"' composer.json; then
    echo "  Adding yoast/phpunit-polyfills..."
    composer require --dev yoast/phpunit-polyfills --no-interaction 2>/dev/null || echo "  Run: composer require --dev yoast/phpunit-polyfills"
    NEEDS_INSTALL=true
  fi

  if ! grep -q '"wp-phpunit/wp-phpunit"' composer.json; then
    echo "  Adding wp-phpunit/wp-phpunit..."
    composer require --dev wp-phpunit/wp-phpunit --no-interaction 2>/dev/null || echo "  Run: composer require --dev wp-phpunit/wp-phpunit"
    NEEDS_INSTALL=true
  fi

  if [ "$NEEDS_INSTALL" = false ]; then
    echo "  All dependencies present."
  fi
else
  echo ""
  echo "No composer.json found. To add test dependencies:"
  echo "  composer init"
  echo "  composer require --dev phpunit/phpunit yoast/phpunit-polyfills wp-phpunit/wp-phpunit"
fi

echo ""
echo "Scaffolding complete!"
echo ""
echo "Next steps:"
echo "  1. Edit tests/bootstrap.php — set your main plugin file path"
echo "  2. Run: composer install"
echo "  3. Run: vendor/bin/phpunit --testsuite unit"
