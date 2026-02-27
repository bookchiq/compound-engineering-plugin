# PHPStan Configuration for WordPress

Templates and configuration guide for `phpstan.neon`.

## Plugin Template

```neon
includes:
  - vendor/szepeviktor/phpstan-wordpress/extension.neon

parameters:
  level: 5
  paths:
    - .
  excludePaths:
    - vendor
    - node_modules
    - tests
    - build
    - assets
  bootstrapFiles:
    - vendor/autoload.php
  scanDirectories:
    - vendor/wp-phpunit/wp-phpunit
```

## Theme Template

```neon
includes:
  - vendor/szepeviktor/phpstan-wordpress/extension.neon

parameters:
  level: 5
  paths:
    - .
  excludePaths:
    - vendor
    - node_modules
    - build
  scanDirectories:
    - vendor/wp-phpunit/wp-phpunit
```

## Level Guide

| Level | Recommended For | Notes |
|-------|----------------|-------|
| 0-2 | Legacy projects, first adoption | Low noise, catches obvious bugs |
| 3-4 | Active development | Good balance of strictness and usability |
| **5** | **Most WordPress projects** | **Catches argument type mismatches** |
| 6-7 | Modern PHP (strict types) | May be noisy with WordPress core patterns |
| 8-9 | Type-strict projects | Requires extensive PHPDoc annotations |

## Baseline Workflow

For existing projects with many errors:

```bash
# Step 1: Generate baseline (records all current errors)
vendor/bin/phpstan analyse --generate-baseline

# Step 2: Commit the baseline
git add phpstan-baseline.neon
git commit -m "Add PHPStan baseline"

# Step 3: Future runs only report NEW errors
vendor/bin/phpstan analyse
```

Include baseline in config:

```neon
includes:
  - vendor/szepeviktor/phpstan-wordpress/extension.neon
  - phpstan-baseline.neon
```

## Ignoring Specific Errors

```neon
parameters:
  ignoreErrors:
    # WordPress dynamic return types
    - '#Function get_option\(\) should return#'

    # Specific file/line ignores
    -
      message: '#Parameter \$args of function wp_remote_get expects#'
      path: includes/class-api-client.php
```

## Custom Type Extensions

For plugin-specific types:

```neon
parameters:
  typeAliases:
    PluginSettings: 'array{api_key: string, enabled: bool, limit: int}'
```

## WordPress-Specific Configuration

The `szepeviktor/phpstan-wordpress` extension handles:

- WordPress global functions (`get_option`, `add_action`, etc.)
- `WP_Error` type narrowing after `is_wp_error()` checks
- `WP_Post`, `WP_Query`, `WP_User` property types
- Hook callback parameter types
- `$wpdb` method return types
