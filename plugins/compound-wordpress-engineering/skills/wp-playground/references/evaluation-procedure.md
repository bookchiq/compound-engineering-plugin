# WP Playground Evaluation Procedure

A documented procedure for evaluating WordPress Playground implementations — either the official `wordpress/agent-skills` wp-playground skill or the `@wp-playground/cli` package directly.

## Purpose

Run this evaluation when:
- First adopting WP Playground for a project
- A major Playground CLI version is released
- Comparing the built-in skill against the official `wordpress/agent-skills` version
- Troubleshooting Playground-related test failures

## Evaluation Steps

### 1. Installation and Startup

```bash
# Install and start
npx @wp-playground/cli@latest server --auto-mount --port=9400

# Measure startup time
time npx @wp-playground/cli@latest server --auto-mount --port=9400 &
# Wait for HTTP 200, then record elapsed time
```

**Record:** Startup time, any errors, Node.js version used.

### 2. Plugin/Theme Mounting

```bash
# Mount a plugin
npx @wp-playground/cli@latest server \
  --mount=./test-plugin:/wordpress/wp-content/plugins/test-plugin \
  --port=9400

# Verify mount
npx @wp-playground/cli@latest wp-cli -- plugin list
```

**Verify:** Plugin appears in list, files are accessible, changes reflect live.

### 3. PHP/WP Version Matrix

Test with different WordPress and PHP versions:

| WordPress | PHP | Command | Result |
|-----------|-----|---------|--------|
| 6.7 | default | `--wp=6.7` | |
| 6.6 | default | `--wp=6.6` | |
| 6.5 | default | `--wp=6.5` | |
| latest | 8.2 | `--php=8.2` | |
| latest | 8.3 | `--php=8.3` | |

### 4. WP-CLI Availability

```bash
npx @wp-playground/cli@latest wp-cli -- wp --info
npx @wp-playground/cli@latest wp-cli -- plugin list
npx @wp-playground/cli@latest wp-cli -- theme list
npx @wp-playground/cli@latest wp-cli -- user list
npx @wp-playground/cli@latest wp-cli -- option get siteurl
```

**Record:** Which commands work, any limitations.

### 5. Composer Inside Playground

```bash
# Check if Composer is available
npx @wp-playground/cli@latest wp-cli -- composer --version 2>/dev/null
```

**Record:** Available or not. If not, note workaround (install dependencies locally, mount vendor/).

### 6. Database Investigation

Playground uses SQLite by default.

```bash
# Check database type
npx @wp-playground/cli@latest wp-cli -- wp db check
```

**Investigate:**
- Can PHPUnit/wp-browser connect to the SQLite database?
- Does `$wpdb` work normally?
- Are there schema differences from MySQL?
- Can tests that use `$wpdb->query()` run successfully?

### 7. Persistence Model

```bash
# Create test data
npx @wp-playground/cli@latest wp-cli -- post create --post_title="Test" --post_status=publish

# Restart Playground
# Check if test data persists
npx @wp-playground/cli@latest wp-cli -- post list
```

**Record:** Whether data persists across restarts, what gets lost.

## Decision Matrix

After evaluation, choose one:

| Option | When to Use |
|--------|-------------|
| **Adopt as-is** | CLI meets all needs, SQLite works for tests, startup is fast |
| **Adopt with workarounds** | Minor issues (e.g., no Composer) that have easy workarounds |
| **Use for browser tests only** | SQLite incompatible with PHPUnit tests, but HTTP testing works |
| **Wait for improvements** | Major blockers that prevent effective use |

## Recording Findings

After running this evaluation, record:

1. Date and Playground CLI version
2. Results for each step
3. Decision made and rationale
4. Any workarounds implemented
5. Next evaluation trigger (e.g., "re-evaluate at CLI v1.0")
