# Compound WordPress Engineering Plugin

AI-powered WordPress development tools that get smarter with every use. Make each unit of engineering work easier than the last.

Forked from [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin). Preserves the four-stage compounding loop (Plan, Work, Review, Compound) while replacing framework-specific components with WordPress equivalents.

## Components

| Component | Count |
|-----------|-------|
| Agents | 30 |
| Commands | 21 |
| Skills | 22 |
| MCP Servers | 2 |

## Agents

Agents are organized into categories for easier discovery.

### Review (19)

| Agent | Description |
|-------|-------------|
| `wp-php-reviewer` | WordPress PHP coding standards, security patterns, and WPCS compliance. Runs PHPCS + PHPStan if available. |
| `wp-javascript-reviewer` | WordPress JS, block editor, Interactivity API, @wordpress/* packages. Runs ESLint if available. |
| `wp-hooks-reviewer` | WordPress hook system — timing, priorities, removal, custom hooks |
| `wp-gutenberg-reviewer` | Block editor — deprecations, block.json, SSR, InnerBlocks |
| `wp-theme-reviewer` | Theme architecture — theme.json, template hierarchy, FSE patterns |
| `wp-frontend-races-reviewer` | Race conditions in Interactivity API, block editor, AJAX/REST |
| `wp-test-reviewer` | Test suite quality — isolation, assertions, security paths, coverage |
| `security-sentinel` | OWASP top 10 + WordPress nonces, capabilities, sanitization, escaping |
| `performance-oracle` | Performance + WordPress WP_Query, caching, hook placement, asset loading |
| `schema-drift-detector` | Detect unrelated dbDelta/schema changes, verify version tracking |
| `agent-native-reviewer` | Verify features are agent-native (action + context parity) |
| `architecture-strategist` | Analyze architectural decisions and compliance |
| `code-simplicity-reviewer` | Final pass for simplicity and minimalism |
| `data-integrity-guardian` | Database migrations and data integrity |
| `data-migration-expert` | Validate ID mappings match production, check for swapped values |
| `deployment-verification-agent` | Create Go/No-Go deployment checklists for risky data changes |
| `call-chain-verifier` | Trace UI actions through all layers, verify signatures at boundaries |
| `pattern-recognition-specialist` | Analyze code for patterns, anti-patterns, and dead code |
| `wp-ai-building-blocks-reviewer` | Review code using Abilities API, AI Client SDK, and MCP Adapter |

### Research (5)

| Agent | Description |
|-------|-------------|
| `best-practices-researcher` | Gather external best practices and examples |
| `framework-docs-researcher` | Research framework documentation and best practices |
| `git-history-analyzer` | Analyze git history and code evolution |
| `learnings-researcher` | Search institutional learnings for relevant past solutions |
| `repo-research-analyst` | Research repository structure and conventions |

### Design (3)

| Agent | Description |
|-------|-------------|
| `design-implementation-reviewer` | Verify UI implementations match Figma designs |
| `design-iterator` | Iteratively refine UI through systematic design iterations |
| `figma-design-sync` | Synchronize web implementations with Figma designs |

### Workflow (3)

| Agent | Description |
|-------|-------------|
| `bug-reproduction-validator` | Systematically reproduce and validate bug reports |
| `pr-comment-resolver` | Address PR comments and implement fixes |
| `spec-flow-analyzer` | Analyze user flows and identify gaps in specifications |

## Commands

### Workflow Commands

| Command | Description |
|---------|-------------|
| `/workflows:brainstorm` | Explore requirements and approaches before planning |
| `/workflows:plan` | Create implementation plans |
| `/workflows:review` | Run comprehensive code reviews |
| `/workflows:work` | Execute work items systematically |
| `/workflows:compound` | Document solved problems to compound team knowledge |

### Utility Commands

| Command | Description |
|---------|-------------|
| `/lfg` | Full autonomous engineering workflow |
| `/slfg` | Full autonomous workflow with swarm mode |
| `/deepen-plan` | Enhance plans with parallel research |
| `/changelog` | Create changelogs for recent merges |
| `/create-agent-skill` | Create or edit Claude Code skills |
| `/generate_command` | Generate new slash commands |
| `/heal-skill` | Fix skill documentation issues |
| `/report-bug` | Report a bug in the plugin |
| `/reproduce-bug` | Reproduce bugs using logs and console |
| `/resolve_parallel` | Resolve TODO comments in parallel |
| `/resolve_todo_parallel` | Resolve todos in parallel |
| `/triage` | Triage and prioritize issues |
| `/test-browser` | Run browser tests on PR-affected pages |
| `/feature-video` | Record video walkthroughs |
| `/agent-native-audit` | Run agent-native architecture review |
| `/deploy-docs` | Validate docs for GitHub Pages |

## Skills

### WordPress Development

| Skill | Description |
|-------|-------------|
| `wp-development-patterns` | WordPress patterns, coding standards, and best practices |
| `setup` | Configure review agents, test environment, and static analysis for your WordPress project |
| `wp-ai-building-blocks` | Abilities API, AI Client SDK, MCP Adapter, and AI Experiments reference |

### Testing & Quality

| Skill | Description |
|-------|-------------|
| `wp-testing` | Scaffold and run WordPress test suites (PHPUnit, wp-browser, Playwright) |
| `wp-playground` | Start and manage WordPress Playground instances for local testing |
| `wp-phpcs` | Run PHP_CodeSniffer with WordPress Coding Standards |
| `wp-phpstan` | Run PHPStan static analysis with WordPress extensions |
| `wp-eslint` | Run ESLint with @wordpress/eslint-plugin |

### Architecture & Tools

| Skill | Description |
|-------|-------------|
| `agent-native-architecture` | Build AI agents using prompt-native architecture |
| `frontend-design` | Create production-grade frontend interfaces |
| `compound-docs` | Capture solved problems as documentation |
| `create-agent-skills` | Expert guidance for creating skills |
| `skill-creator` | Guide for creating effective skills |
| `document-review` | Structured self-review for documents |

### Workflow

| Skill | Description |
|-------|-------------|
| `brainstorming` | Collaborative dialogue before planning |
| `file-todos` | File-based todo tracking system |
| `git-worktree` | Git worktrees for parallel development |
| `resolve-pr-parallel` | Resolve PR comments in parallel |
| `orchestrating-swarms` | Multi-agent swarm orchestration |

### Integrations

| Skill | Description |
|-------|-------------|
| `agent-browser` | Browser automation via agent-browser CLI (fallback for Playwright MCP) |
| `gemini-imagegen` | Image generation via Gemini API |
| `rclone` | Cloud storage file transfer |

## WordPress-Specific Features

- **7 WordPress review agents** for PHP, JS, hooks, Gutenberg, themes, race conditions, and test quality
- **Static analysis integration** — wp-php-reviewer and wp-javascript-reviewer run PHPCS/PHPStan/ESLint before prompt-based analysis
- **Testing infrastructure** — wp-testing skill scaffolds PHPUnit, wp-browser, and test patterns with TDD workflow
- **WP Playground integration** — disposable WordPress instances for testing via `@wp-playground/cli`
- **Enhanced security-sentinel** with nonces, capabilities, sanitization/escaping
- **Enhanced performance-oracle** with WP_Query, caching, hook placement patterns
- **WordPress setup skill** auto-detects plugin/theme/block projects, test environments, and static analysis tools
- **AI Building Blocks support** — Abilities API, AI Client SDK, MCP Adapter review agent + skill with 4 reference files
- **wp-development-patterns skill** with 7 reference files

## MCP Servers

| Server | Description |
|--------|-------------|
| `context7` | Framework documentation lookup (100+ frameworks) |
| `playwright` | Browser automation for end-to-end testing via Playwright |

## Installation

```bash
claude /plugin install compound-wordpress-engineering
```

## Recommended Companion Skills

This plugin now includes built-in testing (wp-testing, wp-playground), static analysis (wp-phpcs, wp-phpstan, wp-eslint), and browser testing (Playwright MCP). For deep WordPress API reference, install these community skills alongside it:

### Official WordPress Collection

The [`wordpress/agent-skills`](https://github.com/wordpress/agent-skills) collection covers areas this plugin intentionally doesn't duplicate:

```bash
# Interactivity API — directives, stores, server-side rendering
npx skills add https://github.com/wordpress/agent-skills --skill wp-interactivity-api

# REST API — custom endpoints, validation, authentication, schemas
npx skills add https://github.com/wordpress/agent-skills --skill wp-rest-api

# WP-CLI & Ops — migrations, search-replace, multisite, cron
npx skills add https://github.com/wordpress/agent-skills --skill wp-wpcli-and-ops

# Block development — scaffolding, block.json, dynamic blocks, deprecations
npx skills add https://github.com/wordpress/agent-skills --skill wp-block-development

# Block themes — theme.json, templates, patterns, style variations
npx skills add https://github.com/wordpress/agent-skills --skill wp-block-themes

# Performance — backend profiling, WP-CLI doctor, Query Monitor
npx skills add https://github.com/wordpress/agent-skills --skill wp-performance

# Plugin development — architecture, lifecycle, admin UI, security
npx skills add https://github.com/wordpress/agent-skills --skill wp-plugin-development
```

### WordPress.org Compliance

```bash
# Plugin directory guidelines — free vs premium, review rules
npx skills add https://github.com/bonny/wordpress-simple-history --skill wordpress-org-compliance
```

## Credits

Forked from [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) by Kieran Klaassen.

## License

MIT
