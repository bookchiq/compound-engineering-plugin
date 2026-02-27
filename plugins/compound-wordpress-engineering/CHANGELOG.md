# Changelog

All notable changes to the compound-wordpress-engineering plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2026-02-27

### Added
- `wp-playground` skill — Start and manage WordPress Playground instances for local testing. Includes startup/stop/status scripts, blueprint patterns reference, and evaluation procedure for comparing Playground implementations.
- `wp-testing` skill — Scaffold and run WordPress test suites (PHPUnit, wp-browser, Playwright). Includes scaffold and run scripts, plus 4 reference docs: PHPUnit setup, test patterns, TDD workflow, and fixture patterns.
- `wp-phpcs` skill — Run PHP_CodeSniffer with WordPress Coding Standards. Includes setup and run scripts, plus phpcs.xml.dist configuration templates.
- `wp-phpstan` skill — Run PHPStan static analysis with WordPress extensions (`szepeviktor/phpstan-wordpress`). Includes setup and run scripts, plus phpstan.neon configuration templates.
- `wp-eslint` skill — Run ESLint with `@wordpress/eslint-plugin`. Includes run script and .eslintrc.json configuration templates.
- `wp-test-reviewer` agent — Reviews test suites for isolation, meaningful assertions, security path coverage, integration patterns, naming conventions, and anti-patterns.
- Playwright MCP server — Browser automation for end-to-end testing, replaces agent-browser as the primary tool.

### Changed
- `wp-php-reviewer` agent — Added Step 0: runs PHPCS and PHPStan (if available) before prompt-based analysis, incorporating tool findings into review.
- `wp-javascript-reviewer` agent — Added Step 0: runs ESLint (if available) before prompt-based analysis, incorporating tool findings into review.
- `workflows:work` command — Added "Establish Testing Strategy" step in Phase 1 (scaffolds tests if none exist), added red/green TDD checkpoints in Phase 2 task loop, added test coverage row to System-Wide Test Check, updated Phase 4 screenshots to use Playwright MCP with agent-browser fallback.
- `workflows:review` command — Added Static Analysis Phase (detects and runs PHPCS/PHPStan/ESLint on changed files before agents), added Test Coverage Check (flags new features without tests), added wp-test-reviewer as conditional agent for PRs containing test files.
- `test-browser` command — Rewritten to use Playwright MCP as primary tool with agent-browser as fallback. Auto-detects server URL (WP Playground, wp-env, custom). Reads `test_server_url` from settings.
- `setup` skill — Added test environment detection (WP Playground, wp-env, Local/MAMP), static analysis tool detection (PHPCS, PHPStan, ESLint, PHPUnit), new questions in Customize path, extended `compound-engineering.local.md` output with `test_environment`, `test_server_url`, and `static_analysis` frontmatter fields.
- Plugin keywords — Added `testing`, `phpunit`, `phpcs`, `phpstan`, `static-analysis`, `playwright`. Removed `agent-browser`.

## [1.3.2] - 2026-02-22

### Fixed
- `test-browser` command — Replaced Rails route mapping table (`app/views/`, `app/controllers/`, Stimulus controllers) with WordPress patterns (`wp-content/themes/*/templates/`, `src/blocks/*/`, etc.); replaced `bin/dev`/`rails server` prerequisites and server instructions with WordPress equivalents
- `generate_command` command — Replaced `bin/rails test` and `bundle exec standardrb` example with generic project test/lint commands (`phpunit`, `phpcs`, `eslint`)
- `workflows:review` command — Replaced `Gemfile` in project type detection with `composer.json`/`wp-content/*`; replaced "Rails + Hotwire Native" hybrid section with "WordPress + WooCommerce + Block Editor"
- `workflows:work` command — Replaced `bin/rails test` examples with `phpunit`/`wp-env` equivalents; replaced `bin/dev` with `wp-env start`; fixed EveryInc badge URL to bookchiq repository
- `workflows:plan` command — Replaced `app/services/example_service.rb` file path examples with WordPress PHP equivalents; replaced Ruby code block with PHP; replaced "DHH, Kieran" reviewer references with "WordPress, Security"
- `triage` command — Replaced Rails concern example (`google_oauth_callbacks.rb`) with WordPress plugin class example
- `compound-docs` skill — Replaced "Hotwire Native Tailwind variants" example with WordPress block editor custom store example
- `file-todos` template — Replaced Rails file paths (`app/models/`, `app/services/`, `test/models/`) with WordPress equivalents (`includes/`, `tests/`)
- `orchestrating-swarms` skill — Replaced all `.rb` file examples and `app/controllers/` paths with WordPress PHP class patterns (`class-*.php`, `includes/rest-api/`)
- `resolve-pr-parallel` script — Replaced `EveryInc/cora` example repo with `bookchiq/my-plugin`

## [1.3.1] - 2026-02-22

### Fixed
- `data-migration-expert` agent — Replaced Rails idioms: "rake tasks" → WP-CLI commands, "serializers" → REST API response schemas, `.fetch(id)` → direct array access, `includes(:deleted_association)` → unnecessary JOINs/meta queries
- `deployment-verification-agent` agent — Replaced `rails db:migrate` and `rake data:backfill` with WP-CLI equivalents; replaced Ruby console verification block with `wp db query` SQL commands
- `framework-docs-researcher` agent — Replaced all Ruby/gem references: `bundle show` → `composer show`/`npm ls`, `Gemfile.lock` → `composer.lock`/`package-lock.json`, "gem" → "package"
- `figma-design-sync` agent — Replaced ERB templates with PHP `get_template_part()` examples; added WordPress CSS note about theme.json, preprocessors, and Tailwind as optional tooling

## [1.3.0] - 2026-02-22

### Fixed
- `reproduce-bug` command — Complete rewrite: removed Rails agents (`rails-console-explorer`, `appsignal-log-investigator`), Playwright MCP tools, `bin/dev` reference, and Rails file paths; replaced with WordPress debug log, WP-CLI, agent-browser CLI, and WordPress file patterns
- `deploy-docs` command — Fixed all 10+ wrong paths (`plugins/compound-engineering/` → `plugins/compound-wordpress-engineering/` and `docs/`); fixed GitHub Pages URL from upstream to `bookchiq.github.io/compound-engineering-plugin/`
- `report-bug` command — Fixed repo from `EveryInc/compound-engineering-plugin` to `bookchiq/compound-wordpress-engineering`; updated title prefix, maintainer reference, and output URLs
- `feature-video` command — Replaced `bin/dev`/`rails server` prerequisites with WordPress dev servers (`wp-env start`, Local, MAMP); replaced Rails route mapping table with WordPress patterns (`wp-content/plugins/*/admin/*.php`, `src/blocks/*/`, etc.)
- `changelog` command — Removed reference to non-existent `EVERY_WRITE_STYLE.md` style guide; replaced with generic review guidance
- `bug-reproduction-validator` agent — Replaced "For Rails apps, check logs" with WordPress-specific debug log and hook tracing guidance
- `setup` skill — Added `data-migration-expert`, `deployment-verification-agent`, and `wp-ai-building-blocks-reviewer` to Comprehensive depth preset; added "Data safety" focus area
- Root `CLAUDE.md` — Fixed stale doc structure comments (24→29 agents, 13→21 commands, 11→17 skills); replaced `kieran-rails-reviewer` test example with `wp-php-reviewer`

### Removed
- `test-xcode` command — iOS/Xcode testing command not applicable to WordPress (commands: 22 → 21)

## [1.2.2] - 2026-02-22

### Fixed
- `workflows:work` command — Removed references to non-existent `linting-agent` (removed in v1.0.0 fork); replaced with generic linting guidance (phpcs, eslint, etc.)
- `orchestrating-swarms` skill — Added missing `call-chain-verifier` and `wp-ai-building-blocks-reviewer` to review agent inventory list
- Documentation site — Regenerated all pages to reflect WordPress fork (was still showing upstream Rails/Ruby agents and wrong component counts)

## [1.2.1] - 2026-02-22

### Changed
- `workflows:review` command — Added conditional TRACEABILITY trigger block for `call-chain-verifier` agent, fires on PRs with `wp_ajax_`, `admin_post_`, `register_rest_route()`, `apiFetch`, `save_post` hooks, meta box save callbacks, or form handlers
- `setup` skill — Added `call-chain-verifier` and `pattern-recognition-specialist` to Comprehensive depth preset; added "Traceability" focus area mapping both agents

## [1.2.0] - 2026-02-22

### Added
- `call-chain-verifier` agent — Traces UI-initiated actions through all WordPress layers (UI, Transport, Hook/Action, Service, Data) and verifies function signatures at each boundary. Detects broken chains, dead ends, orphaned registrations, and mismatched argument counts.

### Changed
- `pattern-recognition-specialist` agent — Added dead code detection: unused functions, orphaned hook callbacks, unreachable code paths, unused template files, unused CSS/JS assets, and WordPress-specific dead code patterns (unused CPTs, taxonomies, options, meta keys, REST routes, shortcodes, widgets). Includes confidence levels for hook-related findings.

## [1.1.1] - 2026-02-22

### Added
- Recommended Companion Skills section in README — official `wordpress/agent-skills` collection (Interactivity API, REST API, WP-CLI, PHPStan, Playground, and more), `bobmatnyc/wordpress-testing-qa` for testing & CI/CD, and `bonny/wordpress-simple-history` for WordPress.org compliance

## [1.1.0] - 2026-02-22

### Added
- `wp-ai-building-blocks` skill with 4 reference files:
  - abilities-api.md — Abilities API registration, schemas, REST API, JavaScript client
  - ai-client-sdk.md — WP_AI_Client_Prompt_Builder, provider-agnostic generation, function calling
  - mcp-adapter.md — MCP server creation, transports, client configuration, security
  - building-blocks-architecture.md — How the four building blocks work together
- `wp-ai-building-blocks-reviewer` agent — Reviews code using Abilities API, AI Client SDK, and MCP Adapter for hook timing, schema correctness, permission callbacks, provider-agnostic patterns, and security

## [1.0.1] - 2026-02-21

Synced framework-agnostic improvements from upstream EveryInc/compound-engineering-plugin.

### Fixed
- `lfg.md` / `slfg.md` — Made ralph-wiggum step optional with graceful fallback; added "do not stop" continuity instruction
- `feature-video.md` — Removed hardcoded R2 URL; added public base URL prerequisite and HTTP 200 validation before PR update
- `workflows/plan.md` — Fixed spec-flow-analyzer to use fully qualified agent name; enhanced brainstorm intake with 7-step content carry-forward; added `origin:` frontmatter and Sources sections to all templates; added System-Wide Impact sections to MORE and A LOT templates; added mandatory Write Plan File step; added brainstorm cross-check in final review
- `workflows/work.md` — Added System-Wide Test Check with 5 structured questions for cross-layer validation; added integration test guidance

## [1.0.0] - 2026-02-21

WordPress fork of [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) v2.34.0.

### Added
- `wp-php-reviewer` agent — WordPress PHP coding standards, WPCS, security patterns
- `wp-javascript-reviewer` agent — WordPress JS, block editor, Interactivity API, @wordpress/* packages
- `wp-hooks-reviewer` agent — WordPress hook system architecture, timing, priorities, removal
- `wp-gutenberg-reviewer` agent — Block editor deprecations, block.json, SSR, InnerBlocks
- `wp-theme-reviewer` agent — Theme architecture, theme.json, template hierarchy, FSE patterns
- `wp-frontend-races-reviewer` agent — Race conditions in Interactivity API stores and block editor
- `wp-development-patterns` skill with 7 reference files:
  - coding-standards.md — WordPress PHP Coding Standards summary
  - security-checklist.md — Comprehensive WordPress security checklist
  - performance-patterns.md — WordPress performance optimization patterns
  - block-development.md — Block development quick reference
  - theme-json-reference.md — theme.json schema quick reference
  - hooks-reference.md — Key WordPress hooks and correct timing
  - database-patterns.md — $wpdb patterns, custom tables, dbDelta, migrations
- WordPress project detection in setup skill (wp-config.php, style.css Theme Name, Plugin Name header, block.json, theme.json, composer.json, package.json)

### Changed
- `security-sentinel` agent — Added WordPress nonce verification, capability checks, sanitization/escaping, SQL safety via $wpdb->prepare(), REST API permission_callback, direct file access guards
- `performance-oracle` agent — Added WP_Query optimization, N+1 query detection, hook placement, object cache, transient patterns, asset loading, AJAX patterns
- `schema-drift-detector` agent — Rewritten for WordPress dbDelta patterns, version tracking via get_option/update_option, $wpdb->prefix consistency
- `setup` skill — Rewritten for WordPress project type detection and agent configuration
- `workflows:review` command — Updated agent roster and database migration detection for WordPress patterns
- Plugin renamed from `compound-engineering` to `compound-wordpress-engineering`
- Version reset to 1.0.0

### Removed
- `dhh-rails-reviewer` agent (Rails-specific)
- `kieran-rails-reviewer` agent (Rails-specific)
- `kieran-python-reviewer` agent (replaced by wp-php-reviewer)
- `kieran-typescript-reviewer` agent (replaced by wp-javascript-reviewer)
- `julik-frontend-races-reviewer` agent (replaced by wp-frontend-races-reviewer)
- `ankane-readme-writer` agent (Ruby gem-specific)
- `every-style-editor` agent (Every Inc. internal)
- `lint` agent (Ruby/ERB-specific)
- `dhh-rails-style` skill (Rails-specific)
- `andrew-kane-gem-writer` skill (Ruby gem-specific)
- `dspy-ruby` skill (Ruby-specific)
- `every-style-editor` skill (Every Inc. internal)
