# Changelog

All notable changes to the compound-wordpress-engineering plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
