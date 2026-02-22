# Plan: Fork Compound Engineering Plugin for WordPress Development

## Context

This plan adapts the [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) (v2.35.x, 29 agents, 22 commands, 19 skills, 1 MCP server) for WordPress-centric development. The goal is to preserve the four-stage compounding loop (Plan → Work → Review → Compound) and all framework-agnostic infrastructure while replacing Rails/Ruby-specific review agents, skills, and references with WordPress equivalents.

Three existing WordPress knowledge sources should be used as reference material during this work:

- **WordPress/agent-skills** (https://github.com/WordPress/agent-skills) — Official WordPress agent skills covering blocks, themes, plugins, REST API, Interactivity API, WP-CLI, performance, PHPStan, and Playground. 13 skills with SKILL.md files, references/, and scripts/. This is the primary authoritative source for WordPress development patterns.
- **elvismdev/claude-wordpress-skills** (https://github.com/elvismdev/claude-wordpress-skills) — Community Claude Code plugin with a mature wp-performance-review skill covering database query anti-patterns, hooks/actions, caching, AJAX, template performance, and platform-specific guidance (WP Engine, VIP, Pantheon).
- **Automattic/wordpress-agent-skills** (https://github.com/Automattic/wordpress-agent-skills) — Automattic's theme generation skills including block theming (FSE architecture, theme.json, template parts, patterns) and design systems.

Do NOT clone or install these repos. Read their published content on GitHub to extract patterns, anti-pattern lists, and domain knowledge when writing the replacement agents and skills described below.

---

## Phase 0: Fork Setup and Inventory

### 0.1 Fork and rename

1. Fork `EveryInc/compound-engineering-plugin` to your GitHub account.
2. Rename the repo to `compound-wordpress-engineering` (or your preferred name).
3. Inside the repo, rename the plugin directory: `plugins/compound-engineering/` → `plugins/compound-wordpress-engineering/`.
4. Update all internal references to match:
   - `.claude-plugin/marketplace.json` — change plugin `name`, `source` path, and `description`.
   - `plugins/compound-wordpress-engineering/.claude-plugin/plugin.json` — change `name`, `description`, and `version` (reset to `1.0.0`).
   - `CLAUDE.md` — update all paths and plugin name references.
   - `README.md` — rewrite intro to describe the WordPress focus. Preserve install instructions but update the marketplace URL and plugin name.

### 0.2 Audit every component

Before changing anything, read every file in these directories and classify each as one of three categories. This classification drives all subsequent phases.

**Category A — Keep as-is (framework-agnostic):**
These components have no Rails/Ruby/framework-specific content and work for any tech stack.

**Category B — Adapt (has some framework-specific content mixed with reusable structure):**
These components have a useful structure and purpose but contain Rails/Ruby examples, references, or domain logic that needs to be replaced with WordPress equivalents.

**Category C — Remove or replace entirely:**
These components are fundamentally tied to Rails/Ruby/Every Inc. internals and have no meaningful WordPress analogue in their current form.

Perform this audit by reading each file. Output the classification to a file called `docs/fork-audit.md` with three columns: filename, category (A/B/C), and a one-line rationale.

---

## Phase 1: Agents — Remove, Replace, and Adapt

The plugin's `agents/` directory contains ~29 markdown files. Each file defines a specialized AI agent with a system prompt, description, and behavioral instructions.

### 1.1 Agents to keep unchanged (Category A)

These agents are framework-agnostic and should be preserved exactly as they are:

| Agent file | Purpose |
|---|---|
| `security-sentinel.md` | OWASP top 10, injection, auth flaws — generic enough to work, but see 1.3 for WordPress enhancement |
| `performance-oracle.md` | N+1 queries, caching, bottlenecks — generic enough, but see 1.3 for WordPress enhancement |
| `architecture-strategist.md` | System design, component boundaries, dependency analysis |
| `code-simplicity-reviewer.md` | YAGNI, minimalism, unnecessary complexity |
| `pattern-recognition-specialist.md` | Design patterns and anti-patterns |
| `data-integrity-guardian.md` | Database migrations, data safety, transaction boundaries |
| `data-migration-expert.md` | Validate ID mappings, check for swapped values |
| `deployment-verification-agent.md` | Pre-deploy checklists, rollback plans |
| `best-practices-researcher.md` | External best practices research |
| `framework-docs-researcher.md` | Framework documentation lookup |
| `learnings-researcher.md` | Search docs/solutions/ for past issues (core to the compound loop) |
| `agent-native-reviewer.md` | Verify features are agent-native (action + context parity) |

Also keep all design agents (Figma sync, iterative UI refinement, etc.) and all workflow/docs agents unchanged.

### 1.2 Agents to remove entirely (Category C)

Delete these files from `agents/`:

| Agent file | Reason |
|---|---|
| `dhh-rails-reviewer.md` | Entirely Rails-specific (DHH/37signals philosophy, Turbo Streams, Omakase stack). No WordPress analogue. |
| `kieran-rails-reviewer.md` | Rails-specific code review (controllers, models, ActiveRecord, namespacing). No WordPress analogue. |

Also remove any other agent that references `andrew-kane-gem-writer` or similar Ruby gem-specific agents if they exist at the current version. Check the agents directory listing carefully.

### 1.3 Agents to adapt (Category B)

These agents have the right purpose but need their framework examples and detection rules rewritten for WordPress.

#### 1.3a Adapt `security-sentinel.md` — add WordPress-specific checks

Read the existing agent file. Preserve its structure (OWASP top 10 framing, severity levels, output format). Add a new section or replace the framework-specific examples with WordPress security patterns. Source these from WordPress/agent-skills `wp-plugin-development` and `wp-abilities-api` skills:

- **Nonce verification**: Every form submission and AJAX handler must use `wp_nonce_field()`/`wp_verify_nonce()` or `check_ajax_referer()`. Flag any `$_POST`/`$_GET` processing without nonce checks.
- **Capability checks**: Flag any action that modifies data without `current_user_can()`. Reference the WordPress capability system (manage_options, edit_posts, etc.).
- **Data sanitization**: Flag any database write using raw `$_POST`/`$_GET`/`$_REQUEST` values. Require `sanitize_text_field()`, `sanitize_email()`, `absint()`, `wp_kses_post()`, etc.
- **Output escaping**: Flag any `echo` of dynamic data without `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses()`.
- **SQL injection**: Flag any direct `$wpdb->query()` or `$wpdb->prepare()` misuse. Require parameterized queries via `$wpdb->prepare()`.
- **File inclusion**: Flag `include`/`require` with user-controlled paths. Flag `eval()`, `extract()`, `unserialize()` on user data.
- **REST API auth**: Flag REST route registrations without `permission_callback`. Reference WordPress/agent-skills `wp-rest-api` skill.
- **Direct file access**: Flag PHP files without `defined('ABSPATH') || exit` guard.

#### 1.3b Adapt `performance-oracle.md` — add WordPress-specific checks

Preserve structure and severity format. Replace Rails-specific examples with WordPress patterns. Source these from elvismdev/claude-wordpress-skills `wp-performance-review` skill and WordPress/agent-skills `wp-performance` skill:

- **Database query anti-patterns**: Unbounded `WP_Query` (no `posts_per_page`), `'posts_per_page' => -1`, `get_posts()` without limits, `$wpdb->get_results()` without `LIMIT`, `meta_query` on unindexed meta keys, `LIKE '%term%'` patterns, `NOT IN` subqueries.
- **N+1 queries**: Calling `get_post_meta()` inside loops instead of batch-fetching. Calling `get_the_terms()` per-post instead of using `update_post_term_cache`.
- **Hook placement**: Expensive operations on `init` or `wp_loaded`. Database writes on every page load. `wp_enqueue_script` outside proper hooks.
- **Caching**: Missing `wp_cache_get()`/`wp_cache_set()` for expensive queries. Missing transient usage for external API calls. Uncached calls to `get_option()` for values that change rarely.
- **AJAX**: Using `admin-ajax.php` where REST API would be more appropriate. Polling patterns instead of long-poll or heartbeat.
- **Template performance**: `get_template_part()` called in tight loops. Queries inside template partials instead of passing data.
- **Asset loading**: Full library imports (all of jQuery UI) when only one component is needed. Missing `defer`/`async` on non-critical scripts. Scripts loaded in header that should be in footer.
- **Object cache**: Not leveraging persistent object cache when available. Using `autoload => yes` on options that are rarely needed.

#### 1.3c Adapt `kieran-python-reviewer.md` → rename to `wp-php-reviewer.md`

This agent does language-specific code review. Rewrite it entirely for PHP in a WordPress context:

- **WordPress coding standards**: Follow WordPress PHP Coding Standards (WPCS). Flag violations: Yoda conditions preferred, spaces inside parentheses, snake_case for functions/variables, braces on same line.
- **Naming conventions**: Plugin function prefixes to avoid collisions. Class naming. Hook naming patterns (`pluginname_action_description`).
- **Error handling**: Proper use of `WP_Error` objects. Checking `is_wp_error()` before using return values. Not swallowing errors silently.
- **Type safety**: PHPDoc blocks on all functions. Type hints where supported. Reference WordPress/agent-skills `wp-phpstan` skill.
- **Autoloading**: PSR-4 autoloading vs WordPress's `require_once` patterns. When each is appropriate.
- **Plugin architecture**: Single responsibility for files. Proper use of hooks over direct function calls. OOP patterns where appropriate (singletons for main plugin class, dependency injection).
- **Deprecated functions**: Flag use of deprecated WordPress functions. Reference WordPress deprecated function list.

#### 1.3d Adapt `kieran-typescript-reviewer.md` → rename to `wp-javascript-reviewer.md`

Rewrite for WordPress JavaScript patterns:

- **Block Editor (Gutenberg)**: Proper use of `@wordpress/scripts` build toolchain. Block registration patterns. `block.json` as source of truth. Reference WordPress/agent-skills `wp-block-development` skill.
- **Interactivity API**: Proper use of `data-wp-*` directives and stores. Reference WordPress/agent-skills `wp-interactivity-api` skill.
- **jQuery patterns**: Flag unnecessary jQuery when vanilla JS or `@wordpress/*` packages would work. If jQuery is required, use WordPress's bundled version, not CDN.
- **Script dependencies**: Proper `wp_register_script` dependency arrays. Using `wp_add_inline_script` for localized data instead of global variables.
- **ESLint/Prettier**: WordPress ESLint config (`@wordpress/eslint-plugin`).

#### 1.3e Adapt `julik-frontend-races-reviewer.md` → rename to `wp-frontend-races-reviewer.md`

The original reviews JavaScript/Stimulus code for race conditions. Replace Stimulus references with WordPress Interactivity API patterns:

- Race conditions in `data-wp-on--*` event handlers.
- Shared store state mutations from concurrent async operations.
- AJAX/REST calls that don't guard against stale responses.
- Block editor sidebar panel interactions with async save operations.

#### 1.3f Adapt `schema-drift-detector` (if present at current version)

The original detects unrelated `schema.rb` changes in Rails migrations. Replace with WordPress equivalent:

- Detect unrelated changes to `dbDelta()` schema definitions.
- Flag plugin activation hooks that alter tables without proper version checks in `get_option()`/`update_option()` patterns.
- Check that `$wpdb->prefix` is used consistently (not hardcoded `wp_` prefix).

### 1.4 New agents to add

Create these new agent files in `agents/`:

#### `wp-hooks-reviewer.md`

WordPress's hook system is its most distinctive architectural pattern and deserves a dedicated reviewer:

- Flag plugins that modify core behavior without hooks (direct file edits).
- Check `add_action`/`add_filter` priority values for conflicts.
- Flag excessive hook nesting (filters inside filters).
- Check that `remove_action`/`remove_filter` calls match the exact priority and callback.
- Flag late-bound callbacks that may not fire in expected order.
- Check for hooks registered at `plugins_loaded` vs `init` vs `wp` for correct timing.
- Flag `do_action`/`apply_filters` calls with inconsistent argument counts.

#### `wp-gutenberg-reviewer.md`

Block editor code deserves specialized review beyond what the general JS reviewer covers:

- Block deprecation handling — flag blocks that modify save output without adding a deprecation entry. Reference WordPress/agent-skills `wp-block-development` skill, specifically the deprecations reference.
- `block.json` completeness — required fields, proper `apiVersion`, valid `category`, `supports` flags.
- Server-side rendering patterns for dynamic blocks.
- `InnerBlocks` usage patterns and `templateLock` settings.
- Proper use of `useBlockProps`, `RichText`, and `InspectorControls`.
- Block style variation registration overhead.

#### `wp-theme-reviewer.md`

- `theme.json` schema compliance and best practices.
- Template hierarchy correctness.
- Proper use of template parts vs templates vs patterns.
- FSE (Full Site Editing) patterns. Reference Automattic/wordpress-agent-skills block theming skill.
- Enqueue patterns: `enqueue_block_assets` hook (not `wp_enqueue_scripts`) for editor+frontend loading.
- Required theme support declarations.

### 1.5 Update review.md command

Open `commands/review.md`. This command orchestrates the multi-agent parallel review. It references agent names by their filenames. Update it:

1. Remove all references to `dhh-rails-reviewer` and `kieran-rails-reviewer`.
2. Replace `kieran-python-reviewer` references with `wp-php-reviewer`.
3. Replace `kieran-typescript-reviewer` references with `wp-javascript-reviewer`.
4. Replace `julik-frontend-races-reviewer` references with `wp-frontend-races-reviewer`.
5. Add `wp-hooks-reviewer`, `wp-gutenberg-reviewer`, and `wp-theme-reviewer` to the parallel agent spawn list.
6. If the review command has a conditional section that triggers `schema-drift-detector` on database migrations, update the detection condition to look for `dbDelta` calls or `$wpdb->query("CREATE TABLE` patterns instead of Rails migration file patterns.

### 1.6 Update agent count in metadata

After all agent additions and removals, count the total `.md` files in `agents/`. Update the count in:
- `plugins/compound-wordpress-engineering/.claude-plugin/plugin.json` — `description` field
- `.claude-plugin/marketplace.json` — plugin description
- `plugins/compound-wordpress-engineering/README.md` — intro paragraph

---

## Phase 2: Skills — Remove, Replace, and Adapt

Skills live in `plugins/compound-wordpress-engineering/skills/` as directories containing `SKILL.md` files and optional `references/`, `templates/`, and `scripts/` subdirectories.

### 2.1 Skills to keep unchanged (Category A)

These are framework-agnostic and should be preserved:

- `agent-native/` — Agent-native architecture skill (building apps where agents are first-class citizens).
- `brainstorm/` — Brainstorming and exploration skill.
- `changelog/` — Changelog generation skill.
- `create-agent-skill/` — Meta-skill for creating new skills.
- `gemini-imagegen/` — Image generation via Gemini API.
- `agent-browser/` — Browser automation documentation.
- `setup/` — **Adapt this, see 2.3 below.**
- `file-todos/` — Todo tracking from code.
- `learnings-researcher/` — Searches docs/solutions/ for past issues. Core to the compound loop. Keep as-is.

Keep any other skill that has no framework-specific content.

### 2.2 Skills to remove entirely (Category C)

| Skill directory | Reason |
|---|---|
| `dhh-rails-style/` | Entirely Rails-specific. DHH conventions, Turbo Streams, Omakase philosophy. |
| `andrew-kane-gem-writer/` (if present) | Ruby gem authoring. No WordPress analogue. |
| `every-style-editor/` (if present) | Every Inc. internal tool. |

Delete these directories.

### 2.3 Skills to adapt (Category B)

#### `setup/` skill — Critical adaptation

The `setup` skill auto-detects the project's tech stack and writes `compound-engineering.local.md` to configure which review agents run. This is the linchpin that connects the review system to the project.

Rewrite the detection logic to identify WordPress projects:

**Detection signals (check in this order):**
1. `wp-config.php` in project root or parent → WordPress site
2. `style.css` with `Theme Name:` header → WordPress theme
3. Main PHP file with `Plugin Name:` header → WordPress plugin
4. `block.json` files → Gutenberg block development
5. `theme.json` → Block theme (FSE)
6. `composer.json` with `wpackagist-*` or `wordpress-*` dependencies
7. `package.json` with `@wordpress/*` dependencies → Block/JS development

**Based on detection, configure `compound-engineering.local.md` with:**
- Which review agents to activate (wp-php-reviewer, wp-javascript-reviewer, wp-hooks-reviewer, wp-gutenberg-reviewer, wp-theme-reviewer, security-sentinel, performance-oracle, etc.).
- Which to skip (e.g., skip wp-gutenberg-reviewer for classic themes, skip wp-theme-reviewer for standalone plugins).
- Project-specific conventions to enforce.

#### New skill: `wp-development-patterns/`

Create a new skill directory `skills/wp-development-patterns/` with:

**`SKILL.md`** — Main skill file with frontmatter:
```yaml
---
name: wp-development-patterns
description: WordPress development patterns, coding standards, and architectural best practices. Use when planning or reviewing WordPress themes, plugins, or blocks.
---
```

The body should cover:
- WordPress plugin architecture patterns (main file, includes structure, class-based vs functional)
- Hook-driven architecture (actions, filters, event-driven design)
- Database interaction patterns ($wpdb, WP_Query, custom tables vs post meta)
- Settings API patterns
- Custom post type and taxonomy registration
- REST API endpoint patterns
- Block development patterns
- Internationalization (i18n) with `__()`, `_e()`, `esc_html__()`, text domains

**`references/` directory** — Create these reference files by synthesizing knowledge from WordPress/agent-skills and elvismdev/claude-wordpress-skills:

- `references/coding-standards.md` — WordPress PHP Coding Standards summary (WPCS rules, naming conventions, formatting)
- `references/security-checklist.md` — Comprehensive WordPress security checklist (nonces, capabilities, sanitization, escaping, prepared statements)
- `references/performance-patterns.md` — WordPress performance patterns (query optimization, caching layers, asset loading)
- `references/block-development.md` — Block development quick reference (block.json schema, attributes, save/edit, deprecations)
- `references/theme-json-reference.md` — theme.json schema quick reference
- `references/hooks-reference.md` — Key WordPress hooks and their correct usage timing (plugins_loaded, init, wp, template_redirect, wp_enqueue_scripts, etc.)
- `references/database-patterns.md` — $wpdb patterns, custom table creation, dbDelta usage, data migration patterns

### 2.4 Update skill count in metadata

Count skill directories. Update the count in the same three files as in Phase 1.6.

---

## Phase 3: Commands — Audit and Adapt

Commands live in `plugins/compound-wordpress-engineering/commands/` as markdown files.

### 3.1 Commands to keep unchanged

Most commands are framework-agnostic workflow commands. Keep these as-is:

- `workflows/plan.md` (or `plan.md`)
- `workflows/work.md` (or `work.md`)
- `workflows/compound.md` (or `compound.md`)
- `workflows/brainstorm.md`
- `lfg.md` — Full autonomous workflow
- `slfg.md` — Swarm mode
- `deepen-plan.md`
- `changelog.md`
- `create-agent-skill.md`
- `generate_command.md`
- `heal-skill.md`
- `sync.md`
- `report-bug.md`
- `reproduce-bug.md`
- `resolve_parallel.md`
- `resolve_pr_parallel.md`
- `resolve_todo_parallel.md`
- `triage.md`

### 3.2 Commands to adapt

#### `review.md` — Already addressed in Phase 1.5

#### `workflows/review.md` (if separate from review.md)

Same adaptations as 1.5. Ensure any agent name references match the new filenames.

### 3.3 Update command count in metadata

Count `.md` files in `commands/`. Update the count in the same three metadata files.

---

## Phase 4: MCP Servers

### 4.1 Keep Context7 MCP server

The Context7 MCP server provides real-time documentation lookup for 100+ frameworks. WordPress (via PHP, JavaScript, and specific WordPress libraries) is likely already partially covered. Keep the configuration as-is in `plugin.json`.

### 4.2 Consider adding WP-CLI MCP capability (optional, future phase)

If you use WordPress Playground or WP-CLI locally, you could add the WordPress Studio MCP server from Automattic/wordpress-agent-skills (`studio-mcp/`) as an optional MCP server. This is not required for the initial fork — flag it as a future enhancement in the README.

---

## Phase 5: Documentation and Cleanup

### 5.1 Update README.md

Rewrite `plugins/compound-wordpress-engineering/README.md`:

- New title: "Compound WordPress Engineering Plugin"
- Description: Explain that this is a WordPress adaptation of the Compound Engineering methodology.
- Credit the upstream repo (EveryInc/compound-engineering-plugin) prominently with a link.
- List all agents organized by category (Review, Research, Design, Workflow/Docs) with the WordPress-specific ones clearly marked.
- List all commands.
- List all skills.
- Include a "WordPress-specific features" section highlighting what's different from upstream.
- Preserve the cross-tool converter documentation (OpenCode, Codex, etc.) if you plan to support it. Otherwise, remove it and note it's Claude Code only.

### 5.2 Update CLAUDE.md

Rewrite the repo's `CLAUDE.md` to reflect:
- New directory structure and file paths.
- New agent/skill/command counts.
- WordPress-specific conventions for contributing to this repo.
- Updated verification commands (`ls agents/*.md | wc -l`, etc.).

### 5.3 Update CHANGELOG.md

Start a new changelog:
```markdown
## v1.0.0 — WordPress Fork

Forked from EveryInc/compound-engineering-plugin v2.35.x.

### Added
- wp-php-reviewer agent (WordPress PHP coding standards and patterns)
- wp-javascript-reviewer agent (WordPress JS, block editor, Interactivity API)
- wp-hooks-reviewer agent (WordPress hook system architecture review)
- wp-gutenberg-reviewer agent (Block editor code review)
- wp-theme-reviewer agent (Theme architecture, theme.json, FSE patterns)
- wp-frontend-races-reviewer agent (Race conditions in WP Interactivity API)
- wp-development-patterns skill (WordPress development patterns and references)
- WordPress-specific detection in setup skill

### Changed
- security-sentinel agent: Added WordPress nonce, capability, sanitization, escaping checks
- performance-oracle agent: Added WP_Query, hook placement, object cache, transient patterns
- review command: Updated agent roster for WordPress stack
- setup skill: Rewrote stack detection for WordPress (wp-config.php, style.css headers, block.json, theme.json, composer.json, package.json)

### Removed
- dhh-rails-reviewer agent (Rails-specific)
- kieran-rails-reviewer agent (Rails-specific)
- dhh-rails-style skill (Rails-specific)
- andrew-kane-gem-writer skill (Ruby gem-specific, if present)
- every-style-editor skill (Every Inc. internal, if present)
```

### 5.4 Update docs/ site (if maintaining it)

The upstream repo has a GitHub Pages documentation site in `docs/`. Either:
- Update it to reflect the WordPress focus (update agent cards, descriptions, stat numbers), or
- Remove it entirely and rely on the README. The docs site is nice-to-have, not essential for a personal/small-team fork.

---

## Phase 6: Testing and Validation

### 6.1 Structural validation

Run these checks after all changes:

```bash
# Count agents and verify against plugin.json description
echo "Agents: $(ls plugins/compound-wordpress-engineering/agents/*.md | wc -l)"

# Count commands
echo "Commands: $(ls plugins/compound-wordpress-engineering/commands/*.md | wc -l)"

# Count skills
echo "Skills: $(ls -d plugins/compound-wordpress-engineering/skills/*/ | wc -l)"

# Check for broken agent references in review.md
grep -oP '(?<=agent )\S+' plugins/compound-wordpress-engineering/commands/review.md | while read agent; do
  if [ ! -f "plugins/compound-wordpress-engineering/agents/${agent}.md" ]; then
    echo "BROKEN REFERENCE: ${agent}"
  fi
done

# Check for any remaining Rails/Ruby references that should have been removed
grep -ril "rails\|activerecord\|turbo.stream\|omakase\|dhh\|stimulus\|ruby\|gemspec\|bundler\|rubocop" \
  plugins/compound-wordpress-engineering/agents/ \
  plugins/compound-wordpress-engineering/skills/ \
  plugins/compound-wordpress-engineering/commands/ || echo "Clean: no Rails/Ruby references found"

# Check that all WordPress agents exist
for agent in wp-php-reviewer wp-javascript-reviewer wp-hooks-reviewer wp-gutenberg-reviewer wp-theme-reviewer wp-frontend-races-reviewer; do
  if [ ! -f "plugins/compound-wordpress-engineering/agents/${agent}.md" ]; then
    echo "MISSING: agents/${agent}.md"
  fi
done

# Check that the WordPress skill exists
if [ ! -f "plugins/compound-wordpress-engineering/skills/wp-development-patterns/SKILL.md" ]; then
  echo "MISSING: skills/wp-development-patterns/SKILL.md"
fi
```

### 6.2 Functional testing

1. Install the plugin locally using `--plugin-dir`:
   ```
   claude --plugin-dir ./plugins/compound-wordpress-engineering
   ```
2. Run `/plan` on a real WordPress plugin or theme project. Verify that:
   - The `setup` skill correctly detects WordPress.
   - The plan references WordPress-specific patterns.
   - Research agents can find WordPress documentation via Context7.
3. Run `/review` on a WordPress project with known issues. Verify that:
   - WordPress-specific agents are spawned (check agent names in output).
   - Security sentinel flags missing nonces/capability checks.
   - Performance oracle flags unbounded WP_Query.
   - wp-hooks-reviewer flags hook issues.
   - No Rails-specific agents are referenced or spawned.
4. Run `/compound` after fixing an issue. Verify that:
   - A solution document is created in `docs/solutions/`.
   - The solution is findable by `learnings-researcher` in subsequent runs.

### 6.3 Edge cases to verify

- Run on a project that is NOT WordPress (e.g., a plain Node.js project). The `setup` skill should not force WordPress agents. Generic agents should still work.
- Run on a WordPress project with both PHP and JavaScript (a block plugin). Both `wp-php-reviewer` and `wp-javascript-reviewer` should activate.
- Run on a classic theme (no block editor). `wp-gutenberg-reviewer` should NOT activate.

---

## Phase 7: Ongoing Maintenance

### 7.1 Upstream sync strategy

The upstream repo iterates rapidly (v2.35+ and climbing). To benefit from upstream improvements to the framework-agnostic components:

1. Add upstream as a remote: `git remote add upstream https://github.com/EveryInc/compound-engineering-plugin.git`
2. Periodically fetch and review upstream changes: `git fetch upstream main`
3. Cherry-pick or merge changes to framework-agnostic files (commands, workflow logic, design agents, infrastructure).
4. Never merge changes to Rails-specific agents or skills — these are the files you've replaced.

### 7.2 Compounding your own fork

Use the fork's own compound loop on itself:
- When you encounter a WordPress pattern the agents miss, run `/compound` to document it as a solution.
- Over time, the `learnings-researcher` agent will accumulate WordPress-specific institutional knowledge in `docs/solutions/`, making each review cycle more thorough than the last.

---

## Execution Order Summary

| Phase | Estimated Effort | Dependencies |
|---|---|---|
| Phase 0: Fork setup and inventory | 1-2 hours | None |
| Phase 1: Agents | 4-6 hours | Phase 0 |
| Phase 2: Skills | 3-4 hours | Phase 0 |
| Phase 3: Commands | 30 min | Phase 1 (need final agent names) |
| Phase 4: MCP servers | 15 min | None |
| Phase 5: Documentation | 1-2 hours | Phases 1-4 |
| Phase 6: Testing | 1-2 hours | Phases 1-5 |
| Phase 7: Ongoing | Continuous | Phase 6 |

Execute phases 0 through 6 sequentially. Phase 1 is the largest and most important — the review agents are the core differentiator of this fork.
