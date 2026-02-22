# Fork Audit: compound-engineering → compound-wordpress-engineering

**Date:** 2026-02-21
**Source:** EveryInc/compound-engineering-plugin v2.34.0

## Classification Key

- **A** — Keep as-is (framework-agnostic)
- **B** — Adapt (has framework-specific content mixed with reusable structure)
- **C** — Remove entirely (fundamentally tied to Rails/Ruby/Every Inc.)

---

## Agents (29 files)

| File | Category | Rationale |
|------|----------|-----------|
| `design/design-implementation-reviewer.md` | A | Generic Figma-to-code comparison |
| `design/design-iterator.md` | A | Generic iterative UI refinement |
| `design/figma-design-sync.md` | A | Generic Figma sync |
| `docs/ankane-readme-writer.md` | C | Ruby gem README patterns — no WP analogue |
| `research/best-practices-researcher.md` | A | Generic best practices research |
| `research/framework-docs-researcher.md` | A | Generic framework docs lookup |
| `research/git-history-analyzer.md` | A | Generic git archaeology |
| `research/learnings-researcher.md` | A | Core compound loop — searches docs/solutions/ |
| `research/repo-research-analyst.md` | A | Generic repo structure research |
| `review/agent-native-reviewer.md` | A | Generic agent-native parity check |
| `review/architecture-strategist.md` | A | Generic architecture review |
| `review/code-simplicity-reviewer.md` | A | Generic YAGNI/simplicity review |
| `review/data-integrity-guardian.md` | A | Generic database safety review |
| `review/data-migration-expert.md` | A | Generic data migration validation |
| `review/deployment-verification-agent.md` | A | Generic deployment checklist |
| `review/dhh-rails-reviewer.md` | C | Entirely Rails/DHH-specific |
| `review/julik-frontend-races-reviewer.md` | B | Good race condition patterns, but Stimulus/Hotwire-specific examples |
| `review/kieran-python-reviewer.md` | B | Rewrite as wp-php-reviewer |
| `review/kieran-rails-reviewer.md` | C | Entirely Rails-specific |
| `review/kieran-typescript-reviewer.md` | B | Rewrite as wp-javascript-reviewer |
| `review/pattern-recognition-specialist.md` | A | Generic pattern analysis |
| `review/performance-oracle.md` | B | Good structure, but has Rails/ActiveRecord examples to replace |
| `review/schema-drift-detector.md` | B | Good concept, rewrite for WordPress dbDelta patterns |
| `review/security-sentinel.md` | B | Good OWASP structure, add WordPress-specific checks |
| `workflow/bug-reproduction-validator.md` | A | Generic bug reproduction |
| `workflow/every-style-editor.md` | C | Every Inc. internal style guide |
| `workflow/lint.md` | C | Ruby/ERB linting — no WP analogue in current form |
| `workflow/pr-comment-resolver.md` | A | Generic PR comment resolution |
| `workflow/spec-flow-analyzer.md` | A | Generic spec flow analysis |

## Skills (19 directories)

| Directory | Category | Rationale |
|-----------|----------|-----------|
| `agent-browser/` | A | Generic browser automation |
| `agent-native-architecture/` | A | Generic agent-native design |
| `andrew-kane-gem-writer/` | C | Ruby gem authoring |
| `brainstorming/` | A | Generic brainstorming |
| `compound-docs/` | A | Core compound loop — solution documentation |
| `create-agent-skills/` | A | Generic skill creation |
| `dhh-rails-style/` | C | Entirely Rails/DHH-specific |
| `document-review/` | A | Generic document review |
| `dspy-ruby/` | C | Ruby-specific LLM framework |
| `every-style-editor/` | C | Every Inc. internal tool |
| `file-todos/` | A | Generic todo tracking |
| `frontend-design/` | A | Generic frontend design |
| `gemini-imagegen/` | A | Generic image generation |
| `git-worktree/` | A | Generic git worktree management |
| `orchestrating-swarms/` | A | Generic swarm orchestration |
| `rclone/` | A | Generic file transfer |
| `resolve-pr-parallel/` | A | Generic parallel PR resolution |
| `setup/` | B | Rewrite detection logic for WordPress |
| `skill-creator/` | A | Generic skill creation guide |

## Commands (22 files)

| File | Category | Rationale |
|------|----------|-----------|
| `agent-native-audit.md` | A | Generic agent-native audit |
| `changelog.md` | A | Generic changelog generation |
| `create-agent-skill.md` | A | Generic skill creation |
| `deepen-plan.md` | A | Generic plan enhancement |
| `deploy-docs.md` | A | Generic docs deployment |
| `feature-video.md` | A | Generic video recording |
| `generate_command.md` | A | Generic command generation |
| `heal-skill.md` | A | Generic skill repair |
| `lfg.md` | A | Generic autonomous workflow |
| `report-bug.md` | A | Generic bug reporting |
| `reproduce-bug.md` | A | Generic bug reproduction |
| `resolve_parallel.md` | A | Generic parallel TODO resolution |
| `resolve_todo_parallel.md` | A | Generic parallel todo resolution |
| `slfg.md` | A | Generic swarm workflow |
| `test-browser.md` | A | Generic browser testing |
| `test-xcode.md` | A | iOS-specific but keep for now |
| `triage.md` | A | Generic triage |
| `workflows/brainstorm.md` | A | Generic brainstorming |
| `workflows/compound.md` | A | Core compound loop |
| `workflows/plan.md` | A | Generic planning |
| `workflows/review.md` | B | References Rails-specific agents by name |
| `workflows/work.md` | A | Generic work execution |

---

## Summary

| Category | Agents | Skills | Commands | Total |
|----------|--------|--------|----------|-------|
| A — Keep | 17 | 14 | 21 | 52 |
| B — Adapt | 5 | 1 | 1 | 7 |
| C — Remove | 7 | 5 | 0 | 12 |

### Removals (12)
- **Agents:** dhh-rails-reviewer, kieran-rails-reviewer, ankane-readme-writer, every-style-editor, lint
- **Skills:** andrew-kane-gem-writer, dhh-rails-style, dspy-ruby, every-style-editor

### Adaptations (7)
- **Agents:** security-sentinel, performance-oracle, kieran-python-reviewer (→ wp-php-reviewer), kieran-typescript-reviewer (→ wp-javascript-reviewer), julik-frontend-races-reviewer (→ wp-frontend-races-reviewer)
- **Skills:** setup
- **Commands:** workflows/review.md

### New WordPress Components (4 agents, 1 skill)
- **New agents:** wp-hooks-reviewer, wp-gutenberg-reviewer, wp-theme-reviewer
- **New skill:** wp-development-patterns (with 7 reference files)
