# Changelog

All notable changes to the compound-wordpress-engineering plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
