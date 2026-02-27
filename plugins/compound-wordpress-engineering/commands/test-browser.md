---
name: test-browser
description: Run browser tests on pages affected by current PR or branch
argument-hint: "[PR number, branch name, or 'current' for current branch]"
---

# Browser Test Command

<command_purpose>Run end-to-end browser tests on pages affected by a PR or branch changes using Playwright MCP (preferred) or agent-browser CLI (fallback).</command_purpose>

## Tool Selection

**Primary: Playwright MCP** — Use `mcp__playwright__*` tools when the Playwright MCP server is configured. These provide structured browser automation with snapshot-based element selection.

**Fallback: agent-browser CLI** — If Playwright MCP tools are not available (tool calls fail), fall back to the `agent-browser` CLI. See the `agent-browser` skill for detailed usage.

**DO NOT use Chrome MCP tools (mcp__claude-in-chrome__*).** These are for a different purpose.

## Introduction

<role>QA Engineer specializing in browser-based end-to-end testing</role>

This command tests affected pages in a real browser, catching issues that unit tests miss:
- JavaScript integration bugs
- CSS/layout regressions
- User workflow breakages
- Console errors

## Prerequisites

<requirements>
- Local development server running (WP Playground, wp-env, Local by Flywheel, MAMP, or custom)
- Playwright MCP server configured in plugin.json (preferred) OR agent-browser CLI installed
- Git repository with changes to test
</requirements>

## Main Tasks

### 0. Detect Browser Automation Tool

Check which tool is available:

```
# Try Playwright MCP first
mcp__playwright__browser_navigate({ url: "about:blank" })
```

If Playwright MCP is available, use it for all browser interactions. If it fails, fall back to agent-browser:

```bash
command -v agent-browser >/dev/null 2>&1 && echo "agent-browser: Ready" || echo "agent-browser: NOT INSTALLED"
```

If neither is available, inform the user and stop.

### 1. Detect Server URL

Determine the test server URL in this order:

1. Read `compound-engineering.local.md` for `test_server_url` setting
2. Check if WP Playground is running: `curl -s -o /dev/null -w "%{http_code}" http://localhost:9400 2>/dev/null`
3. Check wp-env default: `curl -s -o /dev/null -w "%{http_code}" http://localhost:8888 2>/dev/null`
4. Check common dev ports: `8080`, `3000`, `80`
5. If no server found, offer to start WP Playground via the `wp-playground` skill

Store the detected URL as `$SERVER_URL` for all subsequent steps.

### 2. Determine Test Scope

<test_target> $ARGUMENTS </test_target>

<determine_scope>

**If PR number provided:**
```bash
gh pr view [number] --json files -q '.files[].path'
```

**If 'current' or empty:**
```bash
git diff --name-only main...HEAD
```

**If branch name provided:**
```bash
git diff --name-only main...[branch]
```

</determine_scope>

### 3. Map Files to Routes

<file_to_route_mapping>

Map changed files to testable routes:

| File Pattern | Route(s) |
|-------------|----------|
| `wp-content/themes/*/templates/*` | Pages using that template |
| `wp-content/themes/*/parts/*` | Pages using that template part |
| `wp-content/themes/*/style.css`, `*.css` | Visual regression on key pages |
| `wp-content/themes/*/functions.php` | All pages (test homepage at minimum) |
| `wp-content/plugins/*/admin/*.php` | WordPress admin pages for that plugin |
| `wp-content/plugins/*/public/*.php` | Frontend pages rendered by that plugin |
| `src/blocks/*/` | Pages containing that block |
| `src/*.js`, `src/*.ts` | Pages using those scripts |

Build a list of URLs to test based on the mapping.

</file_to_route_mapping>

### 4. Verify Server is Running

<check_server>

**With Playwright MCP:**
```
mcp__playwright__browser_navigate({ url: "$SERVER_URL" })
mcp__playwright__browser_snapshot()
```

**With agent-browser:**
```bash
agent-browser open $SERVER_URL
agent-browser snapshot -i
```

If server is not running, inform user:
```markdown
**Server not running at $SERVER_URL**

Start a development server:
- WP Playground: `npx @wp-playground/cli@latest server --auto-mount --port=9400`
- wp-env: `npx wp-env start`
- Local by Flywheel, MAMP, or Docker

Then run `/test-browser` again.
```

</check_server>

### 5. Test Each Affected Page

<test_pages>

For each affected route:

**With Playwright MCP (preferred):**

```
# Step 1: Navigate
mcp__playwright__browser_navigate({ url: "$SERVER_URL/[route]" })

# Step 2: Get page snapshot (accessibility tree with element refs)
mcp__playwright__browser_snapshot()

# Step 3: Verify key elements
# - Page title/heading present
# - Primary content rendered
# - No error messages visible
# - Forms have expected fields

# Step 4: Test critical interactions
mcp__playwright__browser_click({ element: "Submit button", ref: "e5" })
mcp__playwright__browser_snapshot()

# Step 5: Take screenshot
mcp__playwright__browser_screenshot()
```

**With agent-browser (fallback):**

```bash
# Step 1: Navigate and capture snapshot
agent-browser open "$SERVER_URL/[route]"
agent-browser snapshot -i

# Step 2: Verify key elements (same checks as above)

# Step 3: Test critical interactions
agent-browser click @e1
agent-browser snapshot -i

# Step 4: Take screenshots
agent-browser screenshot page-name.png
agent-browser screenshot --full page-name-full.png
```

</test_pages>

### 6. Human Verification (When Required)

<human_verification>

Pause for human input when testing touches:

| Flow Type | What to Ask |
|-----------|-------------|
| OAuth | "Please sign in with [provider] and confirm it works" |
| Email | "Check your inbox for the test email and confirm receipt" |
| Payments | "Complete a test purchase in sandbox mode" |
| SMS | "Verify you received the SMS code" |
| External APIs | "Confirm the [service] integration is working" |

Use AskUserQuestion:
```markdown
**Human Verification Needed**

This test touches the [flow type]. Please:
1. [Action to take]
2. [What to verify]

Did it work correctly?
1. Yes - continue testing
2. No - describe the issue
```

</human_verification>

### 7. Handle Failures

<failure_handling>

When a test fails:

1. **Document the failure:**
   - Screenshot the error state (Playwright: `mcp__playwright__browser_screenshot()` / agent-browser: `agent-browser screenshot error.png`)
   - Note the exact reproduction steps

2. **Ask user how to proceed:**
   ```markdown
   **Test Failed: [route]**

   Issue: [description]
   Console errors: [if any]

   How to proceed?
   1. Fix now - I'll help debug and fix
   2. Create todo - Add to todos/ for later
   3. Skip - Continue testing other pages
   ```

3. **If "Fix now":** Investigate, propose fix, apply, re-run
4. **If "Create todo":** Create `{id}-pending-p1-browser-test-{description}.md`
5. **If "Skip":** Log as skipped, continue

</failure_handling>

### 8. Test Summary

<test_summary>

After all tests complete, present summary:

```markdown
## Browser Test Results

**Test Scope:** PR #[number] / [branch name]
**Server:** $SERVER_URL
**Tool:** Playwright MCP / agent-browser CLI

### Pages Tested: [count]

| Route | Status | Notes |
|-------|--------|-------|
| `/` | Pass | |
| `/wp-admin/` | Pass | |
| `/sample-page/` | Fail | Console error: [msg] |
| `/checkout/` | Skip | Requires payment credentials |

### Console Errors: [count]
- [List any errors found]

### Human Verifications: [count]
- OAuth flow: Confirmed
- Email delivery: Confirmed

### Failures: [count]
- `/sample-page/` - [issue description]

### Created Todos: [count]
- `005-pending-p1-browser-test-page-error.md`

### Result: [PASS / FAIL / PARTIAL]
```

</test_summary>

## Quick Usage Examples

```bash
# Test current branch changes
/test-browser

# Test specific PR
/test-browser 847

# Test specific branch
/test-browser feature/new-dashboard
```

## Playwright MCP Reference

```
# Navigation
mcp__playwright__browser_navigate({ url: "..." })      # Navigate to URL
mcp__playwright__browser_go_back()                      # Go back
mcp__playwright__browser_go_forward()                   # Go forward

# Page inspection
mcp__playwright__browser_snapshot()                     # Get accessibility tree with refs
mcp__playwright__browser_screenshot()                   # Capture screenshot

# Interactions (use refs from snapshot)
mcp__playwright__browser_click({ element: "...", ref: "e1" })
mcp__playwright__browser_type({ element: "...", ref: "e2", text: "..." })
mcp__playwright__browser_select_option({ element: "...", ref: "e3", values: ["..."] })
mcp__playwright__browser_press_key({ key: "Enter" })

# Wait
mcp__playwright__browser_wait_for_page_load()
```

## agent-browser CLI Reference (Fallback)

```bash
# Navigation
agent-browser open <url>               # Navigate to URL
agent-browser back                     # Go back
agent-browser close                    # Close browser

# Snapshots
agent-browser snapshot -i              # Interactive elements with refs
agent-browser snapshot -i --json       # JSON output

# Interactions
agent-browser click @e1                # Click element
agent-browser fill @e1 "text"          # Fill input
agent-browser press Enter              # Press key

# Screenshots
agent-browser screenshot out.png       # Viewport screenshot
agent-browser screenshot --full out.png # Full page

# Headed mode
agent-browser --headed open <url>      # Visible browser
```
