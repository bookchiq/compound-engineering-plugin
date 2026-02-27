---
name: wp-phpcs
description: Run PHP_CodeSniffer with WordPress Coding Standards on changed files. Use when checking PHP code against WPCS, auto-fixing style issues, or setting up PHPCS for a WordPress project.
---

# WordPress PHP_CodeSniffer (PHPCS)

Run PHPCS with WordPress Coding Standards to enforce consistent code style and catch common issues.

## Setup Check

Verify PHPCS and WordPress standards are installed:

```bash
# Check PHPCS
vendor/bin/phpcs --version 2>/dev/null || echo "PHPCS not installed"

# Check WordPress standard is registered
vendor/bin/phpcs -i 2>/dev/null | grep -q "WordPress" && echo "WPCS: registered" || echo "WPCS: not registered"
```

If not installed, use the setup script: [setup-phpcs.sh](./scripts/setup-phpcs.sh)

## Quick Start

```bash
# Run on changed files
git diff --name-only --diff-filter=d HEAD | grep '\.php$' | xargs vendor/bin/phpcs --standard=WordPress

# Run on a specific file
vendor/bin/phpcs --standard=WordPress path/to/file.php

# Run on entire project
vendor/bin/phpcs --standard=WordPress .
```

## Running on Changed Files

Check only files changed in the current branch:

```bash
# Changed files vs main branch
git diff --name-only main...HEAD -- '*.php' | xargs vendor/bin/phpcs --standard=WordPress

# Staged files only
git diff --cached --name-only -- '*.php' | xargs vendor/bin/phpcs --standard=WordPress
```

Or use the run script: [run-phpcs.sh](./scripts/run-phpcs.sh)

## Auto-Fixing with PHPCBF

Fix auto-fixable issues:

```bash
# Fix a specific file
vendor/bin/phpcbf --standard=WordPress path/to/file.php

# Fix all changed files
git diff --name-only main...HEAD -- '*.php' | xargs vendor/bin/phpcbf --standard=WordPress
```

## JSON Output

For structured results:

```bash
vendor/bin/phpcs --standard=WordPress --report=json path/to/file.php
```

## Configuration

Use a `phpcs.xml.dist` file in the project root for project-specific configuration. See [phpcs-config.md](./references/phpcs-config.md) for templates and common options.

## Interpreting Results

| Severity | PHPCS Level | Review Priority |
|----------|-------------|-----------------|
| Error | Error | P1 (security) or P2 |
| Warning | Warning | P2 or P3 |
| Info (excluded sniff) | — | Not reported |

Common error categories:
- **Security**: Missing sanitization, escaping, nonce checks → P1
- **Coding standards**: Yoda conditions, spacing, naming → P2
- **Documentation**: Missing docblocks, wrong tags → P3

## Helper Scripts

- [setup-phpcs.sh](./scripts/setup-phpcs.sh) — Install PHPCS and WordPress Coding Standards via Composer
- [run-phpcs.sh](./scripts/run-phpcs.sh) — Run PHPCS on changed PHP files with structured output
