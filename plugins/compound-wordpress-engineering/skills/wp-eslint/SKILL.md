---
name: wp-eslint
description: Run ESLint with @wordpress/eslint-plugin for JavaScript code quality. Use when checking JS/TS code against WordPress standards or setting up ESLint for WordPress block development.
---

# WordPress ESLint

Run ESLint with `@wordpress/eslint-plugin` to enforce WordPress JavaScript coding standards.

## Setup Check

```bash
# Check ESLint
npx eslint --version 2>/dev/null || echo "ESLint not installed"

# Check for config
test -f .eslintrc.json || test -f .eslintrc.js || test -f .eslintrc.yml && echo "Config: found" || echo "Config: not found"
```

## Quick Start

```bash
# Run on changed JS/TS files
git diff --name-only main...HEAD -- '*.js' '*.jsx' '*.ts' '*.tsx' | xargs npx eslint

# Run on specific files
npx eslint src/blocks/my-block/edit.js

# Run on entire project
npx eslint .
```

## Running on Changed Files

```bash
# Changed files vs main branch
git diff --name-only main...HEAD -- '*.js' '*.jsx' '*.ts' '*.tsx' | xargs npx eslint

# Or use the run script
./scripts/run-eslint.sh
```

See [run-eslint.sh](./scripts/run-eslint.sh) for details.

## Auto-Fixing

```bash
# Fix auto-fixable issues
npx eslint --fix src/

# Fix specific files
npx eslint --fix src/blocks/my-block/edit.js
```

## JSON Output

```bash
npx eslint --format=json src/
```

## Installation

If using `@wordpress/scripts` (recommended):

```bash
npm install --save-dev @wordpress/scripts
```

`@wordpress/scripts` includes ESLint and the WordPress plugin.

For standalone ESLint:

```bash
npm install --save-dev eslint @wordpress/eslint-plugin
```

## Configuration

Use `.eslintrc.json` for project-specific configuration. See [eslint-config.md](./references/eslint-config.md) for templates.

## Integration with @wordpress/scripts

When using `wp-scripts`:

```bash
# Lint
npx wp-scripts lint-js

# Lint with auto-fix
npx wp-scripts lint-js --fix

# Lint specific files
npx wp-scripts lint-js src/blocks/
```

## Interpreting Results

| Severity | ESLint Level | Review Priority |
|----------|-------------|-----------------|
| Error | error | P1 or P2 |
| Warning | warn | P2 or P3 |
| Off | off | Not reported |

Common categories:
- **Security**: `no-eval`, unsafe patterns → P1
- **WordPress patterns**: `@wordpress/no-unsafe-wp-apis`, dependency rules → P2
- **Code quality**: Unused variables, complexity → P2/P3
- **Style**: Formatting, naming → P3

## Helper Scripts

- [run-eslint.sh](./scripts/run-eslint.sh) — Run ESLint on changed JS/TS files
