# WordPress Playground Blueprint Patterns

Blueprints define reproducible WordPress environments. Save as `.wp-playground/blueprint.json` in the project root.

## Basic Structure

```json
{
  "$schema": "https://playground.wordpress.net/blueprint-schema.json",
  "landingPage": "/wp-admin/",
  "preferredVersions": {
    "php": "8.2",
    "wp": "6.7"
  },
  "steps": []
}
```

## Common Patterns

### Activate a Mounted Plugin

```json
{
  "preferredVersions": { "wp": "6.7" },
  "steps": [
    {
      "step": "activatePlugin",
      "pluginPath": "my-plugin/my-plugin.php"
    }
  ]
}
```

### Install and Activate a Plugin from WordPress.org

```json
{
  "steps": [
    {
      "step": "installPlugin",
      "pluginData": {
        "resource": "wordpress.org/plugins",
        "slug": "query-monitor"
      }
    },
    {
      "step": "activatePlugin",
      "pluginPath": "query-monitor/query-monitor.php"
    }
  ]
}
```

### Activate a Theme

```json
{
  "steps": [
    {
      "step": "activateTheme",
      "themeFolderName": "twentytwentyfour"
    }
  ]
}
```

### Import Test Content

```json
{
  "steps": [
    {
      "step": "importWxr",
      "file": {
        "resource": "url",
        "url": "https://raw.githubusercontent.com/WPTT/theme-unit-test/master/themeunittestdata.wordpress.xml"
      }
    }
  ]
}
```

### Create Test Users

```json
{
  "steps": [
    {
      "step": "runPHP",
      "code": "<?php require '/wordpress/wp-load.php'; wp_create_user('editor', 'password', 'editor@example.com'); $user = get_user_by('login', 'editor'); $user->set_role('editor'); ?>"
    }
  ]
}
```

### Set Site Options

```json
{
  "steps": [
    {
      "step": "setSiteOptions",
      "options": {
        "blogname": "Test Site",
        "blogdescription": "A test WordPress installation",
        "permalink_structure": "/%postname%/"
      }
    }
  ]
}
```

### Enable WordPress Debug Mode

```json
{
  "steps": [
    {
      "step": "defineWpConfigConsts",
      "consts": {
        "WP_DEBUG": true,
        "WP_DEBUG_LOG": true,
        "WP_DEBUG_DISPLAY": true,
        "SCRIPT_DEBUG": true
      }
    }
  ]
}
```

### Full Plugin Testing Blueprint

A comprehensive blueprint for testing a mounted plugin:

```json
{
  "$schema": "https://playground.wordpress.net/blueprint-schema.json",
  "landingPage": "/wp-admin/plugins.php",
  "preferredVersions": {
    "php": "8.2",
    "wp": "6.7"
  },
  "steps": [
    {
      "step": "defineWpConfigConsts",
      "consts": {
        "WP_DEBUG": true,
        "WP_DEBUG_LOG": true,
        "SCRIPT_DEBUG": true
      }
    },
    {
      "step": "activatePlugin",
      "pluginPath": "my-plugin/my-plugin.php"
    },
    {
      "step": "installPlugin",
      "pluginData": {
        "resource": "wordpress.org/plugins",
        "slug": "query-monitor"
      }
    },
    {
      "step": "activatePlugin",
      "pluginPath": "query-monitor/query-monitor.php"
    },
    {
      "step": "setSiteOptions",
      "options": {
        "blogname": "Plugin Test Site",
        "permalink_structure": "/%postname%/"
      }
    },
    {
      "step": "importWxr",
      "file": {
        "resource": "url",
        "url": "https://raw.githubusercontent.com/WPTT/theme-unit-test/master/themeunittestdata.wordpress.xml"
      }
    }
  ]
}
```

## Usage

```bash
# Run with blueprint
npx @wp-playground/cli@latest server \
  --blueprint=.wp-playground/blueprint.json \
  --mount=.:/wordpress/wp-content/plugins/my-plugin \
  --port=9400
```

## Tips

- Store blueprints in `.wp-playground/` directory at project root
- Use `$schema` for IDE autocomplete
- `landingPage` controls which page opens in the browser
- Steps execute in order — activate plugins after installing them
- Use `runPHP` step for anything not covered by built-in steps
