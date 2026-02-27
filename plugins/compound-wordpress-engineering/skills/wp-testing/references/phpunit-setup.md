# PHPUnit Setup for WordPress

Complete setup guide for PHPUnit testing in WordPress plugins and themes.

## Composer Dependencies

```json
{
  "require-dev": {
    "phpunit/phpunit": "^9.0 || ^10.0",
    "yoast/phpunit-polyfills": "^2.0 || ^3.0",
    "wp-phpunit/wp-phpunit": "^6.0"
  }
}
```

Install:

```bash
composer require --dev phpunit/phpunit yoast/phpunit-polyfills wp-phpunit/wp-phpunit
```

## Directory Structure

```
my-plugin/
├── phpunit.xml.dist
├── tests/
│   ├── bootstrap.php
│   ├── unit/
│   │   └── SampleTest.php
│   └── integration/
│       └── SampleIntegrationTest.php
├── composer.json
└── my-plugin.php
```

## phpunit.xml.dist

```xml
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
```

## tests/bootstrap.php

```php
<?php
/**
 * PHPUnit bootstrap file.
 */

// Composer autoloader.
require_once dirname( __DIR__ ) . '/vendor/autoload.php';

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
    require dirname( __DIR__ ) . '/my-plugin.php';
  }
);

// Start up the WP testing environment.
require $_tests_dir . '/includes/bootstrap.php';
```

## Running with wp-env

If using `@wordpress/env`:

```bash
# Start wp-env
npx wp-env start

# Run PHPUnit inside the container
npx wp-env run tests-cli --env-cwd=wp-content/plugins/my-plugin phpunit

# Run specific test suite
npx wp-env run tests-cli --env-cwd=wp-content/plugins/my-plugin phpunit -- --testsuite unit
```

## Running Standalone

```bash
# Set up WordPress test library (first time only)
bash bin/install-wp-tests.sh wordpress_test root '' localhost latest

# Run tests
vendor/bin/phpunit

# Run specific suite
vendor/bin/phpunit --testsuite unit
vendor/bin/phpunit --testsuite integration

# Run with filter
vendor/bin/phpunit --filter test_method_name
```

## PHPUnit Version Compatibility

| WordPress | PHPUnit | PHP |
|-----------|---------|-----|
| 6.5+ | 9.x or 10.x | 7.2+ |
| 6.7+ | 9.x or 10.x | 7.4+ |

Use `yoast/phpunit-polyfills` to maintain compatibility across PHPUnit versions.
