import { formatFrontmatter } from "../utils/frontmatter"
import type { ClaudeAgent, ClaudePlugin } from "../types/claude"
import type { QoderBundle } from "../types/qoder"
import type { ClaudeToOpenCodeOptions } from "./claude-to-opencode"

export type ClaudeToQoderOptions = ClaudeToOpenCodeOptions

// Qoder tool names - mostly 1:1 mapping with Claude
const TOOL_MAP: Record<string, string> = {
  bash: "Bash",
  read: "Read",
  write: "Write",
  edit: "Edit",
  grep: "Grep",
  glob: "Glob",
  webfetch: "WebFetch",
  websearch: "WebSearch",
  patch: "Patch",
  task: "Task",
  question: "Question",
  todowrite: "TodoWrite",
  toread: "TodoRead",
}

export function convertClaudeToQoder(
  plugin: ClaudePlugin,
  _options: ClaudeToQoderOptions,
): QoderBundle {
  const agents = plugin.agents.map((agent) => convertAgent(agent))
  const skillDirs = plugin.skills.map((skill) => ({
    name: skill.name,
    sourceDir: skill.sourceDir,
  }))

  return {
    agents,
    skillDirs,
  }
}

function convertAgent(agent: ClaudeAgent): { name: string; content: string } {
  const frontmatter: Record<string, unknown> = {
    name: normalizeName(agent.name),
    description: agent.description ?? `Converted from Claude agent ${agent.name}`,
  }

  // Map allowed tools if specified
  if (agent.capabilities && agent.capabilities.length > 0) {
    const tools: string[] = []
    for (const c of agent.capabilities) {
      const mapped = TOOL_MAP[c.toLowerCase()]
      if (mapped) {
        tools.push(mapped)
      } else {
        tools.push(c)
      }
    }
    if (tools.length > 0) {
      frontmatter.tools = tools
    }
  }

  // Rewrite Claude paths to Qoder paths
  const body = rewriteClaudePaths(agent.body.trim())

  const content = formatFrontmatter(frontmatter, body)
  return { name: normalizeName(agent.name), content }
}

function rewriteClaudePaths(body: string): string {
  return body
    .replace(/~\/\.claude\//g, "~/.qoder/")
    .replace(/\.claude\//g, ".qoder/")
}

function normalizeName(value: string): string {
  const trimmed = value.trim()
  if (!trimmed) return "item"
  const normalized = trimmed
    .toLowerCase()
    .replace(/[\\/]+/g, "-")
    .replace(/[:\s]+/g, "-")
    .replace(/[^a-z0-9_-]+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-+|-+$/g, "")
  return normalized || "item"
}
