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

case "$TYPE" in
  plugin|theme|block) ;;
  *) echo "Error: --type must be plugin, theme, or block (got: $TYPE)"; exit 1 ;;
esac

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

# Create tests/bootstrap.php (type-aware)
if [ ! -f tests/bootstrap.php ]; then
  # Common header for all types.
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

PHPEOF

  # Type-specific loading logic.
  case "$TYPE" in
    plugin)
      cat >> tests/bootstrap.php << 'PHPEOF'
	/**
	 * Manually load the plugin being tested.
	 */
	tests_add_filter(
		'muplugins_loaded',
		function () {
			require dirname( __DIR__ ) . '/PLUGIN_FILE_HERE.php';
		}
	);

PHPEOF
      ;;
    theme)
      cat >> tests/bootstrap.php << 'PHPEOF'
	/**
	 * Register and activate the theme being tested.
	 */
	tests_add_filter(
		'setup_theme',
		function () {
			register_theme_directory( dirname( __DIR__ ) . '/..' );
			switch_theme( basename( dirname( __DIR__ ) ) );
		}
	);

PHPEOF
      ;;
    block)
      cat >> tests/bootstrap.php << 'PHPEOF'
	/**
	 * Manually load the plugin being tested.
	 */
	tests_add_filter(
		'muplugins_loaded',
		function () {
			require dirname( __DIR__ ) . '/PLUGIN_FILE_HERE.php';
		}
	);

	/**
	 * Register the block after WordPress initialises.
	 */
	tests_add_filter(
		'init',
		function () {
			if ( file_exists( dirname( __DIR__ ) . '/build/block.json' ) ) {
				register_block_type( dirname( __DIR__ ) . '/build' );
			} elseif ( file_exists( dirname( __DIR__ ) . '/block.json' ) ) {
				register_block_type( dirname( __DIR__ ) );
			}
		}
	);

PHPEOF
      ;;
  esac

  # Common footer for all types.
  cat >> tests/bootstrap.php << 'PHPEOF'
	// Start up the WP testing environment.
	require $_tests_dir . '/includes/bootstrap.php';
}
PHPEOF
  echo "Created: tests/bootstrap.php"
  if [ "$TYPE" != "theme" ]; then
    echo "  NOTE: Edit tests/bootstrap.php to set your main plugin file path"
  fi
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

# Create sample integration test (type-aware)
if [ ! -f tests/integration/SampleIntegrationTest.php ]; then
  case "$TYPE" in
    plugin)
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
      ;;
    theme)
      cat > tests/integration/SampleIntegrationTest.php << 'PHPEOF'
<?php
/**
 * Sample integration test for a theme.
 *
 * Integration tests load WordPress — test hooks, templates, theme features, etc.
 */

class SampleIntegrationTest extends WP_UnitTestCase {

	public function test_wordpress_loaded() {
		$this->assertTrue( function_exists( 'do_action' ), 'WordPress should be loaded' );
	}

	public function test_theme_setup_fires() {
		$this->assertGreaterThan(
			0,
			did_action( 'after_setup_theme' ),
			'after_setup_theme should have fired'
		);
	}

	public function test_active_theme_matches() {
		$this->assertSame(
			basename( dirname( __DIR__ ) ),
			get_stylesheet(),
			'Active theme should match the project directory name'
		);
	}
}
PHPEOF
      ;;
    block)
      cat > tests/integration/SampleIntegrationTest.php << 'PHPEOF'
<?php
/**
 * Sample integration test for a block plugin.
 *
 * Integration tests load WordPress — test hooks, DB, REST API, block registration, etc.
 */

class SampleIntegrationTest extends WP_UnitTestCase {

	public function test_wordpress_loaded() {
		$this->assertTrue( function_exists( 'do_action' ), 'WordPress should be loaded' );
	}

	public function test_plugin_activated() {
		// Replace with your plugin's activation check.
		$this->assertTrue( true, 'Plugin should be active' );
	}

	public function test_block_is_registered() {
		// Replace 'your-namespace/block-name' with your block's registered name.
		$this->assertTrue(
			WP_Block_Type_Registry::get_instance()->is_registered( 'your-namespace/block-name' ),
			'Block should be registered'
		);
	}
}
PHPEOF
      ;;
  esac
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
if [ "$TYPE" = "theme" ]; then
  echo "  1. Review tests/bootstrap.php — theme directory is auto-detected"
else
  echo "  1. Edit tests/bootstrap.php — set your main plugin file path"
fi
if [ "$TYPE" = "block" ]; then
  echo "  2. Edit tests/integration/SampleIntegrationTest.php — set your block name"
  echo "  3. Run: composer install"
  echo "  4. Run: vendor/bin/phpunit --testsuite unit"
else
  echo "  2. Run: composer install"
  echo "  3. Run: vendor/bin/phpunit --testsuite unit"
fi
