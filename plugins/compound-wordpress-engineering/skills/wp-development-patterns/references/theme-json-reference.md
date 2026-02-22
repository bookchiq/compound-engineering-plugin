# theme.json Quick Reference

## Minimal Block Theme theme.json

```json
{
  "$schema": "https://schemas.wp.org/trunk/theme.json",
  "version": 3,
  "settings": {
    "layout": {
      "contentSize": "650px",
      "wideSize": "1200px"
    },
    "color": {
      "palette": [
        { "slug": "base", "color": "#ffffff", "name": "Base" },
        { "slug": "contrast", "color": "#1a1a1a", "name": "Contrast" },
        { "slug": "primary", "color": "#0073aa", "name": "Primary" },
        { "slug": "secondary", "color": "#23282d", "name": "Secondary" }
      ],
      "defaultPalette": false,
      "defaultGradients": false
    },
    "typography": {
      "fluid": true,
      "fontFamilies": [
        {
          "fontFamily": "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
          "slug": "system",
          "name": "System"
        }
      ],
      "fontSizes": [
        { "slug": "small", "size": "0.875rem", "name": "Small" },
        { "slug": "medium", "size": "1rem", "name": "Medium" },
        { "slug": "large", "size": "1.25rem", "name": "Large" },
        { "slug": "x-large", "size": "1.5rem", "name": "Extra Large" }
      ]
    },
    "spacing": {
      "units": ["px", "em", "rem", "%", "vw"]
    },
    "appearanceTools": true
  },
  "styles": {
    "color": {
      "background": "var(--wp--preset--color--base)",
      "text": "var(--wp--preset--color--contrast)"
    },
    "typography": {
      "fontFamily": "var(--wp--preset--font-family--system)",
      "fontSize": "var(--wp--preset--font-size--medium)",
      "lineHeight": "1.6"
    },
    "elements": {
      "link": {
        "color": { "text": "var(--wp--preset--color--primary)" }
      },
      "button": {
        "color": {
          "background": "var(--wp--preset--color--primary)",
          "text": "var(--wp--preset--color--base)"
        }
      },
      "heading": {
        "typography": { "fontWeight": "700" }
      }
    },
    "blocks": {}
  },
  "customTemplates": [
    { "name": "page-no-title", "title": "Page (No Title)", "postTypes": ["page"] }
  ],
  "templateParts": [
    { "name": "header", "title": "Header", "area": "header" },
    { "name": "footer", "title": "Footer", "area": "footer" }
  ]
}
```

## CSS Custom Properties Generated

theme.json settings generate CSS custom properties:

| Setting | CSS Property |
|---------|-------------|
| `color.palette[slug]` | `--wp--preset--color--{slug}` |
| `typography.fontFamilies[slug]` | `--wp--preset--font-family--{slug}` |
| `typography.fontSizes[slug]` | `--wp--preset--font-size--{slug}` |
| `spacing.spacingSizes[slug]` | `--wp--preset--spacing--{slug}` |

## Settings Reference

| Setting | Purpose |
|---------|---------|
| `appearanceTools` | Enables border, color, spacing, typography, dimensions, position |
| `color.defaultPalette` | Show/hide core color palette (set `false` to hide) |
| `color.defaultGradients` | Show/hide core gradients |
| `typography.fluid` | Enable fluid (clamp-based) font sizes |
| `layout.contentSize` | Default content width |
| `layout.wideSize` | Wide alignment width |
| `spacing.spacingScale` | Auto-generate spacing presets |

## Template Part Areas

| Area | Purpose |
|------|---------|
| `header` | Site header template part |
| `footer` | Site footer template part |
| `uncategorized` | General-purpose template part |

## Block-Level Styles

```json
{
  "styles": {
    "blocks": {
      "core/paragraph": {
        "typography": { "lineHeight": "1.8" }
      },
      "core/heading": {
        "spacing": { "margin": { "top": "1.5em", "bottom": "0.5em" } }
      },
      "core/button": {
        "border": { "radius": "4px" }
      }
    }
  }
}
```

## Child Theme Override

Child theme's `theme.json` is **merged** with parent (not replaced). Child values take precedence for matching keys.
