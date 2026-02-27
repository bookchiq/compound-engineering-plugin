---
name: wp-testing
description: Scaffold and run WordPress test suites (PHPUnit, wp-browser, Playwright). Use when setting up testing infrastructure, writing tests, or executing test runs for WordPress plugins and themes.
---

# WordPress Testing

Scaffold and run WordPress test suites for plugins, themes, and blocks.

## Testing Pyramid

| Layer | Tool | When to Use |
|-------|------|-------------|
| **Unit** | PHPUnit | Pure PHP logic, no WordPress dependencies |
| **Integration** | WP_UnitTestCase / wp-browser | Hook callbacks, DB operations, WordPress APIs |
| **REST API** | WP_REST_Controller tests | Endpoint responses, auth, validation |
| **WP-CLI** | WP-CLI test framework | Custom command behavior |
| **Browser** | Playwright MCP | Visual regression, JS integration, user workflows |

## Setup Detection

Check if the project already has testing infrastructure:

```bash
# PHPUnit config
test -f phpunit.xml.dist && echo "PHPUnit: configured" || echo "PHPUnit: not found"

# Test directory
test -d tests && echo "Tests dir: exists" || echo "Tests dir: missing"

# Composer dependencies
grep -q "phpunit" composer.json 2>/dev/null && echo "PHPUnit: in composer.json" || echo "PHPUnit: not in composer.json"
grep -q "wp-phpunit" composer.json 2>/dev/null && echo "wp-phpunit: in composer.json" || echo "wp-phpunit: not in composer.json"
```

## Scaffolding

Use the scaffold script to set up testing infrastructure:

```bash
# Scaffold for a plugin
./scripts/scaffold-tests.sh --type plugin

# Scaffold for a theme
./scripts/scaffold-tests.sh --type theme

# Scaffold for a block
./scripts/scaffold-tests.sh --type block
```

See [scaffold-tests.sh](./scripts/scaffold-tests.sh) for details. Safe to re-run — does not overwrite existing files.

For detailed PHPUnit setup instructions, see [phpunit-setup.md](./references/phpunit-setup.md).

## Test Categories

### Unit Tests (`tests/unit/`)

Test pure PHP logic without WordPress loaded:

- Utility functions, data transformers, validators
- Class methods that don't call WordPress APIs
- Run fast, no database needed

### Integration Tests (`tests/integration/`)

Test code that interacts with WordPress:

- Hook callbacks with real WordPress environment
- Database operations with real `$wpdb`
- REST API endpoints with real request/response cycle
- Options, meta, transients, taxonomies, CPTs

### Browser Tests

Test UI behavior in a real browser:

- Block editor rendering and interactions
- Frontend JavaScript and Interactivity API
- Admin page functionality
- Visual regression testing

Use `/test-browser` command or Playwright MCP tools.

## TDD Workflow

Follow test-driven development for WordPress code:

1. **Red** — Write a failing test that describes the desired behavior
2. **Green** — Write the minimum code to make the test pass
3. **Refactor** — Clean up while keeping tests green

See [red-green-tdd.md](./references/red-green-tdd.md) for WordPress-specific TDD examples.

## Running Tests

```bash
# Run all tests
./scripts/run-tests.sh --all

# Run only unit tests
./scripts/run-tests.sh --unit

# Run only integration tests
./scripts/run-tests.sh --integration

# Run specific test file
vendor/bin/phpunit tests/integration/test-rest-endpoint.php

# Run with filter
vendor/bin/phpunit --filter test_create_post_requires_auth
```

See [run-tests.sh](./scripts/run-tests.sh) for auto-detection of test runners.

## Test Patterns

For WordPress-specific testing patterns (hooks, REST endpoints, CPTs, blocks, mocking), see [test-patterns.md](./references/test-patterns.md).

## Fixture Patterns

For test data management (factories, custom factories, database transactions, JSON fixtures), see [fixture-patterns.md](./references/fixture-patterns.md).

## Helper Scripts

- [scaffold-tests.sh](./scripts/scaffold-tests.sh) — Set up test directories, config files, and Composer dependencies
- [run-tests.sh](./scripts/run-tests.sh) — Auto-detect and run test suites
