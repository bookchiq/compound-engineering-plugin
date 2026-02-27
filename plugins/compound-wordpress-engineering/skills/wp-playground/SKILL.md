---
name: wp-playground
description: Start and manage WordPress Playground instances for local testing. Use when setting up disposable WordPress environments, mounting plugins/themes for testing, or running integration tests.
---

# WordPress Playground

Start and manage disposable WordPress Playground instances for local development and testing.

## Prerequisites

- Node.js 20.18+ (`node -v`)
- npx available (`npx --version`)

## Quick Start

```bash
npx @wp-playground/cli@latest server --auto-mount --port=9400
```

Access at `http://localhost:9400` — login with `admin` / `password`.

## Setup Check

Verify prerequisites before starting:

```bash
node_version=$(node -v 2>/dev/null | sed 's/v//')
required="20.18"
if [ "$(printf '%s\n' "$required" "$node_version" | sort -V | head -n1)" = "$required" ]; then
  echo "Node.js $node_version — OK"
else
  echo "Node.js $node_version too old — need 20.18+"
fi
```

## Core Procedures

### Start with Plugin Mount

Mount the current directory as a plugin:

```bash
npx @wp-playground/cli@latest server \
  --mount=.:/wordpress/wp-content/plugins/$(basename "$PWD") \
  --port=9400
```

### Start with Theme Mount

Mount as a theme instead:

```bash
npx @wp-playground/cli@latest server \
  --mount=.:/wordpress/wp-content/themes/$(basename "$PWD") \
  --port=9400
```

### WordPress Version Pinning

Specify a WordPress version:

```bash
npx @wp-playground/cli@latest server \
  --wp=6.7 \
  --auto-mount \
  --port=9400
```

### Blueprint Execution

Use a blueprint file for reproducible environments:

```bash
npx @wp-playground/cli@latest server \
  --blueprint=.wp-playground/blueprint.json \
  --port=9400
```

See [blueprint-patterns.md](./references/blueprint-patterns.md) for blueprint examples.

### WP-CLI Access

Run WP-CLI commands inside Playground:

```bash
npx @wp-playground/cli@latest wp-cli -- plugin list
npx @wp-playground/cli@latest wp-cli -- user create testuser test@example.com --role=editor
npx @wp-playground/cli@latest wp-cli -- option update blogname "Test Site"
```

### HTTP Access

- **Frontend:** `http://localhost:9400`
- **Admin:** `http://localhost:9400/wp-admin/`
- **Login:** `admin` / `password`
- **REST API:** `http://localhost:9400/wp-json/wp/v2/`

### Shutdown

Stop the running Playground:

```bash
# Find and kill the process
lsof -ti:9400 | xargs kill 2>/dev/null
```

Or use the helper script: [playground-stop.sh](./scripts/playground-stop.sh)

## Startup Verification

Wait for Playground to be ready before running tests:

```bash
echo "Waiting for Playground..."
for i in $(seq 1 30); do
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:9400 | grep -q "200"; then
    echo "Playground ready at http://localhost:9400"
    break
  fi
  sleep 1
done
```

## Helper Scripts

- [playground-start.sh](./scripts/playground-start.sh) — Detect project type, construct mount flags, start server, wait for ready
- [playground-stop.sh](./scripts/playground-stop.sh) — Find and stop running Playground process
- [playground-status.sh](./scripts/playground-status.sh) — Health check, report URL/WP version/mounted paths

## Integration Notes

### PHPUnit / wp-browser

Playground uses SQLite by default. For PHPUnit integration tests that need `$wpdb`:

1. Start Playground with a known port
2. Point test bootstrap at Playground's WordPress installation
3. Or use Playground as the HTTP target for REST API tests via `wp_remote_get()`

### Playwright MCP / Browser Testing

Point Playwright at the Playground URL:

```bash
# In compound-engineering.local.md:
# test_server_url: http://localhost:9400
```

The `/test-browser` command auto-detects running servers.

### Evaluation Procedure

For evaluating the official `wordpress/agent-skills` wp-playground skill or comparing implementations, see [evaluation-procedure.md](./references/evaluation-procedure.md).

## Troubleshooting

### Port Conflicts

```bash
# Check if port 9400 is in use
lsof -i:9400
# Kill the process using the port
lsof -ti:9400 | xargs kill
# Use a different port
npx @wp-playground/cli@latest server --auto-mount --port=9401
```

### Node.js Version

Playground CLI requires Node.js 20.18+. Use nvm to switch:

```bash
nvm install 20
nvm use 20
```

### Mount Failures

- Ensure the mount source path exists and is readable
- Use absolute paths if relative paths fail: `--mount=/full/path:/wordpress/wp-content/plugins/name`
- Check that the target directory in WordPress exists

### Playground Won't Start

```bash
# Clear npx cache
npx --yes @wp-playground/cli@latest server --auto-mount --port=9400
# Or install globally
npm install -g @wp-playground/cli
wp-playground server --auto-mount --port=9400
```
