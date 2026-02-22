---
name: wp-development-patterns
description: WordPress development patterns, coding standards, and architectural best practices. Use when planning or reviewing WordPress themes, plugins, or blocks.
---

# WordPress Development Patterns

Comprehensive reference for WordPress development conventions, coding standards, and architectural patterns. Use this skill when planning, implementing, or reviewing WordPress themes, plugins, and blocks.

## References

- [coding-standards.md](./references/coding-standards.md) — WordPress PHP Coding Standards (WPCS) summary
- [security-checklist.md](./references/security-checklist.md) — Comprehensive WordPress security checklist
- [performance-patterns.md](./references/performance-patterns.md) — WordPress performance optimization patterns
- [block-development.md](./references/block-development.md) — Block development quick reference
- [theme-json-reference.md](./references/theme-json-reference.md) — theme.json schema quick reference
- [hooks-reference.md](./references/hooks-reference.md) — Key WordPress hooks and their correct usage timing
- [database-patterns.md](./references/database-patterns.md) — $wpdb patterns, custom tables, and data migration

## Plugin Architecture Patterns

### Main Plugin File Structure
```php
<?php
/**
 * Plugin Name: My Plugin
 * Description: Brief description.
 * Version: 1.0.0
 * Requires at least: 6.4
 * Requires PHP: 8.0
 * Author: Author Name
 * Text Domain: my-plugin
 * Domain Path: /languages
 * License: GPL v2 or later
 */

defined( 'ABSPATH' ) || exit;

define( 'MY_PLUGIN_VERSION', '1.0.0' );
define( 'MY_PLUGIN_PATH', plugin_dir_path( __FILE__ ) );
define( 'MY_PLUGIN_URL', plugin_dir_url( __FILE__ ) );

require_once MY_PLUGIN_PATH . 'includes/class-my-plugin.php';

My_Plugin::instance();
```

### Hook-Driven Architecture
WordPress is event-driven via actions and filters. Structure code around hooks:

```php
// Register features at the right time
add_action( 'init', 'my_plugin_register_post_types' );
add_action( 'rest_api_init', 'my_plugin_register_routes' );
add_action( 'wp_enqueue_scripts', 'my_plugin_enqueue_assets' );
add_action( 'admin_menu', 'my_plugin_admin_pages' );
```

### Database Interaction Hierarchy
Prefer higher-level APIs over direct queries:

1. **WordPress APIs** (first choice): `WP_Query`, `get_posts()`, `get_option()`, `get_post_meta()`
2. **Custom queries with $wpdb**: When WordPress APIs are insufficient
3. **Custom tables**: When post meta isn't appropriate (high-volume, structured data)

### Custom Post Types and Taxonomies
Register on `init` hook. Use `register_post_type()` and `register_taxonomy()`.

### REST API Endpoints
Register on `rest_api_init` hook. Always include `permission_callback`.

### Settings API
Use `register_setting()`, `add_settings_section()`, `add_settings_field()` for admin settings.

### Internationalization (i18n)
All user-facing strings must be translatable:
- `__( 'Text', 'text-domain' )` — Returns translated string
- `_e( 'Text', 'text-domain' )` — Echoes translated string
- `esc_html__( 'Text', 'text-domain' )` — Returns escaped translated string
- `_n( 'singular', 'plural', $count, 'text-domain' )` — Pluralization
- `_x( 'Text', 'context', 'text-domain' )` — With context for translators
