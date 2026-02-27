---
name: wp-phpstan
description: Run PHPStan static analysis with WordPress extensions for type safety. Use when checking PHP code for type errors, undefined methods, or setting up PHPStan for a WordPress project.
---

# WordPress PHPStan

Run PHPStan static analysis with WordPress-specific type extensions for type safety and bug detection.

## Setup Check

```bash
# Check PHPStan
vendor/bin/phpstan --version 2>/dev/null || echo "PHPStan not installed"

# Check for config
test -f phpstan.neon && echo "Config: found" || test -f phpstan.neon.dist && echo "Config: found" || echo "Config: not found"
```

If not installed, use the setup script: [setup-phpstan.sh](./scripts/setup-phpstan.sh)

## Quick Start

```bash
# Analyze entire project at level 5
vendor/bin/phpstan analyse --level=5

# Analyze specific files
vendor/bin/phpstan analyse includes/ my-plugin.php

# Analyze with JSON output
vendor/bin/phpstan analyse --error-format=json
```

## Running on Changed Files

```bash
# Changed files vs main branch
git diff --name-only main...HEAD -- '*.php' | xargs vendor/bin/phpstan analyse --level=5

# Or use the run script
./scripts/run-phpstan.sh
```

See [run-phpstan.sh](./scripts/run-phpstan.sh) for auto-detection.

## Analysis Levels

| Level | What It Checks |
|-------|---------------|
| 0 | Basic checks (unknown classes, functions, methods) |
| 1 | Possibly undefined variables |
| 2 | Unknown methods on `mixed` |
| 3 | Return types |
| 4 | Basic dead code |
| 5 | Argument types (**recommended for WordPress**) |
| 6 | Strict union types |
| 7 | Missing typehints on methods |
| 8 | No `mixed` allowed |
| 9 | Maximum strictness |

**Recommendation:** Start at level 5 for WordPress projects. WordPress core uses many dynamic patterns that make levels 6+ noisy without significant benefit.

## WordPress Extensions

The `szepeviktor/phpstan-wordpress` extension provides:

- Type stubs for WordPress core functions
- `apply_filters()` return type inference
- `get_option()` / `get_post_meta()` type narrowing
- `WP_Error` / `WP_Post` / `WP_Query` type definitions
- Hook callback type checking

## Configuration

Use `phpstan.neon` for project configuration. See [phpstan-config.md](./references/phpstan-config.md) for templates.

## Baseline Management

When adopting PHPStan on an existing project, use a baseline to ignore existing errors:

```bash
# Generate baseline (records all current errors)
vendor/bin/phpstan analyse --generate-baseline

# Run with baseline (only reports new errors)
vendor/bin/phpstan analyse
```

The baseline file (`phpstan-baseline.neon`) is included automatically when present.

## Interpreting Results

| PHPStan Finding | Review Priority |
|----------------|-----------------|
| Undefined method/function call | P1 — likely bug |
| Wrong argument type | P1/P2 — type mismatch |
| Unused variable/parameter | P3 — cleanup |
| Missing return type | P3 — documentation |
| PHPDoc type mismatch | P2 — misleading docs |

## Helper Scripts

- [setup-phpstan.sh](./scripts/setup-phpstan.sh) — Install PHPStan with WordPress extensions
- [run-phpstan.sh](./scripts/run-phpstan.sh) — Run PHPStan on changed PHP files
