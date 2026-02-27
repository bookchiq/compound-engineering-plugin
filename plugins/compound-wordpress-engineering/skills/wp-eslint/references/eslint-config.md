# ESLint Configuration for WordPress

Templates for `.eslintrc.json` in WordPress projects.

## Block Development Template (Recommended)

```json
{
  "extends": ["plugin:@wordpress/eslint-plugin/recommended"]
}
```

This includes:
- WordPress coding standards
- React/JSX rules for block editor
- Import/export rules
- Prettier integration

## Plugin with Custom Rules

```json
{
  "extends": ["plugin:@wordpress/eslint-plugin/recommended"],
  "rules": {
    "no-console": "warn",
    "jsdoc/require-param-description": "off"
  },
  "globals": {
    "wp": "readonly",
    "jQuery": "readonly"
  }
}
```

## Theme Template

```json
{
  "extends": ["plugin:@wordpress/eslint-plugin/recommended"],
  "env": {
    "browser": true,
    "jquery": true
  },
  "globals": {
    "wp": "readonly"
  }
}
```

## Interactivity API Template

```json
{
  "extends": ["plugin:@wordpress/eslint-plugin/recommended"],
  "rules": {
    "@wordpress/no-unsafe-wp-apis": "error"
  }
}
```

## .eslintignore

```
node_modules/
vendor/
build/
dist/
*.min.js
```

## Common Rules

| Rule | Recommended Setting | Description |
|------|-------------------|-------------|
| `@wordpress/no-unsafe-wp-apis` | error | Flag experimental WordPress APIs |
| `@wordpress/dependency-group` | error | Group @wordpress imports |
| `@wordpress/no-unused-vars-before-return` | error | Declare vars after early returns |
| `@wordpress/i18n-text-domain` | error | Correct text domain usage |
| `no-console` | warn | Flag console.log in production |
| `no-unused-vars` | error | Remove unused variables |

## Using with wp-scripts

When `@wordpress/scripts` is installed, ESLint is preconfigured:

```json
{
  "scripts": {
    "lint:js": "wp-scripts lint-js",
    "lint:js:fix": "wp-scripts lint-js --fix"
  }
}
```

No `.eslintrc.json` needed — `wp-scripts` uses its built-in config by default. Only create one to override rules.

## Prettier Integration

WordPress ESLint config includes Prettier. Add a Prettier config to match WordPress style:

```json
{
  "useTabs": true,
  "tabWidth": 4,
  "printWidth": 80,
  "singleQuote": true,
  "trailingComma": "es5",
  "bracketSpacing": true,
  "parenSpacing": true,
  "jsxBracketSameLine": false,
  "semi": true,
  "arrowParens": "always"
}
```
