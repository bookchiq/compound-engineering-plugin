---
name: setup
description: Configure which review agents run for your project. Auto-detects WordPress project type and writes compound-engineering.local.md.
disable-model-invocation: true
---

# Compound WordPress Engineering Setup

Interactive setup for `compound-engineering.local.md` — configures which agents run during `/workflows:review` and `/workflows:work`.

## Step 1: Check Existing Config

Read `compound-engineering.local.md` in the project root. If it exists, display current settings summary and use AskUserQuestion:

```
question: "Settings file already exists. What would you like to do?"
header: "Config"
options:
  - label: "Reconfigure"
    description: "Run the interactive setup again from scratch"
  - label: "View current"
    description: "Show the file contents, then stop"
  - label: "Cancel"
    description: "Keep current settings"
```

If "View current": read and display the file, then stop.
If "Cancel": stop.

## Step 2: Detect and Ask

Auto-detect the project type. Check in this order (first match wins):

```bash
# WordPress plugin
grep -l "Plugin Name:" *.php 2>/dev/null && echo "wordpress-plugin" || \
# WordPress theme
test -f style.css && grep -q "Theme Name:" style.css 2>/dev/null && echo "wordpress-theme" || \
# WordPress block theme (FSE)
test -f theme.json && test -f style.css && echo "wordpress-block-theme" || \
# WordPress site
test -f wp-config.php && echo "wordpress-site" || \
test -f ../wp-config.php && echo "wordpress-site" || \
# Block development (standalone)
test -f block.json && echo "wordpress-block" || \
# Composer with WP dependencies
grep -q "wpackagist\|wordpress" composer.json 2>/dev/null && echo "wordpress-composer" || \
# Package.json with @wordpress dependencies
grep -q "@wordpress/" package.json 2>/dev/null && echo "wordpress-js" || \
# General fallback
echo "general"
```

Use AskUserQuestion:

```
question: "Detected {type} project. How would you like to configure?"
header: "Setup"
options:
  - label: "Auto-configure (Recommended)"
    description: "Use smart defaults for {type}. Done in one click."
  - label: "Customize"
    description: "Choose project type, focus areas, and review depth."
```

### If Auto-configure → Skip to Step 4 with defaults:

- **WordPress Plugin:** `[wp-php-reviewer, wp-hooks-reviewer, security-sentinel, performance-oracle, code-simplicity-reviewer]`
- **WordPress Theme:** `[wp-php-reviewer, wp-theme-reviewer, wp-hooks-reviewer, security-sentinel, performance-oracle]`
- **WordPress Block Theme (FSE):** `[wp-php-reviewer, wp-theme-reviewer, wp-gutenberg-reviewer, wp-javascript-reviewer, security-sentinel, performance-oracle]`
- **WordPress Block (standalone):** `[wp-gutenberg-reviewer, wp-javascript-reviewer, wp-frontend-races-reviewer, code-simplicity-reviewer]`
- **WordPress Site:** `[wp-php-reviewer, wp-hooks-reviewer, security-sentinel, performance-oracle, code-simplicity-reviewer]`
- **WordPress JS:** `[wp-javascript-reviewer, wp-frontend-races-reviewer, code-simplicity-reviewer, security-sentinel]`
- **General:** `[code-simplicity-reviewer, security-sentinel, performance-oracle, architecture-strategist]`

### If Customize → Step 3

## Step 3: Customize (3 questions)

**a. Project type** — confirm or override:

```
question: "Which project type should we optimize for?"
header: "Type"
options:
  - label: "{detected_type} (Recommended)"
    description: "Auto-detected from project files"
  - label: "WordPress Plugin"
    description: "PHP plugin — adds hooks reviewer, PHP reviewer, security sentinel"
  - label: "WordPress Theme"
    description: "Theme development — adds theme reviewer, PHP reviewer"
  - label: "WordPress Block"
    description: "Gutenberg block — adds block reviewer, JS reviewer, races reviewer"
```

Only show options that differ from the detected type.

**b. Focus areas** — multiSelect:

```
question: "Which review areas matter most?"
header: "Focus"
multiSelect: true
options:
  - label: "Security"
    description: "Nonces, capabilities, sanitization, escaping (security-sentinel)"
  - label: "Performance"
    description: "WP_Query, caching, hook placement, assets (performance-oracle)"
  - label: "Architecture"
    description: "Design patterns, hook architecture, separation of concerns (architecture-strategist)"
  - label: "Code simplicity"
    description: "Over-engineering, YAGNI violations (code-simplicity-reviewer)"
  - label: "Traceability"
    description: "End-to-end call chain verification, dead code detection (call-chain-verifier, pattern-recognition-specialist)"
  - label: "Data safety"
    description: "Migration validation, deployment checklists, ID mapping verification (data-migration-expert, deployment-verification-agent)"
```

**c. Depth:**

```
question: "How thorough should reviews be?"
header: "Depth"
options:
  - label: "Thorough (Recommended)"
    description: "Stack reviewers + all selected focus agents."
  - label: "Fast"
    description: "Stack reviewers + code simplicity only. Less context, quicker."
  - label: "Comprehensive"
    description: "All above + git history, data integrity, agent-native, schema drift."
```

## Step 3b: Test Environment & Static Analysis (3 questions, Customize path only)

**d. Test environment:**

```
question: "What test environment do you use?"
header: "Testing"
options:
  - label: "WP Playground (Recommended)"
    description: "Disposable instances via npx @wp-playground/cli. Fast, no Docker needed."
  - label: "wp-env"
    description: "Official WordPress development environment (@wordpress/env)"
  - label: "Local / MAMP / Custom"
    description: "Local by Flywheel, MAMP, Docker, or other local server"
  - label: "None"
    description: "No local test environment configured"
```

**e. Static analysis tools** — multiSelect:

Auto-detect which tools are installed and pre-select them:

```bash
vendor/bin/phpcs --version 2>/dev/null && echo "phpcs:installed"
vendor/bin/phpstan --version 2>/dev/null && echo "phpstan:installed"
npx eslint --version 2>/dev/null && echo "eslint:installed"
vendor/bin/phpunit --version 2>/dev/null && echo "phpunit:installed"
```

```
question: "Which static analysis tools are available? (auto-detected, confirm or adjust)"
header: "Analysis"
multiSelect: true
options:
  - label: "PHPCS"
    description: "PHP_CodeSniffer with WordPress standards (wp-phpcs skill)"
  - label: "PHPStan"
    description: "Static analysis for type safety (wp-phpstan skill)"
  - label: "ESLint"
    description: "JavaScript linting with @wordpress/eslint-plugin (wp-eslint skill)"
  - label: "PHPUnit"
    description: "Test runner for unit and integration tests (wp-testing skill)"
```

If PHPCS is not installed, recommend: "Install with: `skill: wp-phpcs` → run `setup-phpcs.sh`"
If PHPStan is not installed, recommend: "Install with: `skill: wp-phpstan` → run `setup-phpstan.sh`"

## Step 4: Build Agent List and Write File

**Project-type-specific agents:**
- WordPress Plugin → `wp-php-reviewer, wp-hooks-reviewer`
- WordPress Theme → `wp-php-reviewer, wp-theme-reviewer, wp-hooks-reviewer`
- WordPress Block Theme → `wp-php-reviewer, wp-theme-reviewer, wp-gutenberg-reviewer, wp-javascript-reviewer`
- WordPress Block → `wp-gutenberg-reviewer, wp-javascript-reviewer, wp-frontend-races-reviewer`
- WordPress JS → `wp-javascript-reviewer, wp-frontend-races-reviewer`
- General → (none)

**Focus area agents:**
- Security → `security-sentinel`
- Performance → `performance-oracle`
- Architecture → `architecture-strategist`
- Code simplicity → `code-simplicity-reviewer`
- Traceability → `call-chain-verifier, pattern-recognition-specialist`
- Data safety → `data-migration-expert, deployment-verification-agent`

**Depth:**
- Thorough: stack + selected focus areas
- Fast: stack + `code-simplicity-reviewer` only
- Comprehensive: all above + `git-history-analyzer, data-integrity-guardian, agent-native-reviewer, schema-drift-detector, call-chain-verifier, pattern-recognition-specialist, data-migration-expert, deployment-verification-agent, wp-ai-building-blocks-reviewer`

**Plan review agents:** stack-specific reviewer + `code-simplicity-reviewer`.

Write `compound-engineering.local.md`:

```markdown
---
review_agents: [{computed agent list}]
plan_review_agents: [{computed plan agent list}]
test_environment: {wp-playground | wp-env | local | custom | none}
test_server_url: {http://localhost:9400 | http://localhost:8888 | custom URL}
static_analysis:
  phpcs: {true | false}
  phpstan: {true | false}
  eslint: {true | false}
  tests: {true | false}
---

# Review Context

Add project-specific review instructions here.
These notes are passed to all review agents during /workflows:review and /workflows:work.

Examples:
- "We use the Interactivity API heavily — check for store race conditions"
- "Our REST API is public — extra scrutiny on permission_callback and input validation"
- "Performance-critical: we serve 10k req/s on the main query"
- "Block theme: all customization should go through theme.json, not CSS"
```

**Default values for Auto-configure path:**
- `test_environment`: `none` (user hasn't specified)
- `test_server_url`: `http://localhost:9400` (WP Playground default)
- `static_analysis`: auto-detected from installed tools

## Step 5: Confirm

```
Saved to compound-engineering.local.md

Project type: {type}
Review depth: {depth}
Agents:       {count} configured
              {agent list, one per line}

Tip: Edit the "Review Context" section to add project-specific instructions.
     Re-run this setup anytime to reconfigure.
```
