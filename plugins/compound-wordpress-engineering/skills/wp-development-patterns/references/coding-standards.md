# WordPress PHP Coding Standards (WPCS)

## Naming Conventions
- **Functions/Variables**: `snake_case` — `my_plugin_get_settings()`
- **Classes**: `My_Plugin_Settings` or namespaced `My_Plugin\Settings`
- **Constants**: `MY_PLUGIN_VERSION`
- **Files**: `class-my-plugin-settings.php` for class files
- **Hooks**: `{plugin_slug}_{action}` — `my_plugin_after_save`

## Formatting
- Yoda conditions: `if ( 'value' === $variable )`
- Spaces inside parentheses: `if ( $condition )`
- Braces on same line: `if ( $condition ) {`
- Single quotes for static strings: `'hello'`
- Double quotes only for interpolation: `"Hello {$name}"`
- Tabs for indentation (not spaces)
- No trailing whitespace
- Unix line endings (LF)

## PHP Tags
- Opening tag: `<?php` (never short tags `<?`)
- No closing `?>` in PHP-only files
- `defined( 'ABSPATH' ) || exit;` guard in every file

## Functions
- Prefix all public functions with plugin slug
- PHPDoc on all functions with `@param`, `@return`, `@since`
- Type hints where PHP version allows
- Default parameter values for optional params

## Arrays
- Short array syntax `[]` is acceptable
- Multiline arrays with trailing comma
- Align `=>` arrows in associative arrays when practical

## Comparison and Type
- Use strict comparison (`===`, `!==`) by default
- Yoda conditions for all comparisons
- Check return types: `is_wp_error()`, `is_null()`, `empty()`
- Cast explicitly: `(int)`, `(string)`, `(bool)`, `(array)`

## Resources
- [WordPress PHP Coding Standards](https://developer.wordpress.org/coding-standards/wordpress-coding-standards/php/)
- PHPCS ruleset: `WordPress` (includes `WordPress-Core`, `WordPress-Docs`, `WordPress-Extra`)
