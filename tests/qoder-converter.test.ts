import { describe, expect, test } from "bun:test"
import { convertClaudeToQoder } from "../src/converters/claude-to-qoder"
import { parseFrontmatter } from "../src/utils/frontmatter"
import type { ClaudePlugin } from "../src/types/claude"

const fixturePlugin: ClaudePlugin = {
  root: "/tmp/plugin",
  manifest: { name: "fixture", version: "1.0.0" },
  agents: [
    {
      name: "Security Reviewer",
      description: "Security-focused agent",
      capabilities: ["bash", "read", "grep"],
      model: "claude-sonnet-4-20250514",
      body: "Focus on vulnerabilities.",
      sourcePath: "/tmp/plugin/agents/security-reviewer.md",
    },
  ],
  commands: [
    {
      name: "workflows:plan",
      description: "Planning command",
      argumentHint: "[FOCUS]",
      model: "inherit",
      allowedTools: ["Read"],
      body: "Plan the work.",
      sourcePath: "/tmp/plugin/commands/workflows/plan.md",
    },
  ],
  skills: [
    {
      name: "existing-skill",
      description: "Existing skill",
      sourceDir: "/tmp/plugin/skills/existing-skill",
      skillPath: "/tmp/plugin/skills/existing-skill/SKILL.md",
    },
  ],
  hooks: undefined,
  mcpServers: {
    local: { command: "echo", args: ["hello"] },
  },
}

describe("convertClaudeToQoder", () => {
  test("converts agents to Qoder format with frontmatter", () => {
    const bundle = convertClaudeToQoder(fixturePlugin, {
      agentMode: "subagent",
      inferTemperature: false,
      permissions: "none",
    })

    const agent = bundle.agents.find((a) => a.name === "security-reviewer")
    expect(agent).toBeDefined()
    const parsed = parseFrontmatter(agent!.content)
    expect(parsed.data.name).toBe("security-reviewer")
    expect(parsed.data.description).toBe("Security-focused agent")
    expect(parsed.data.tools).toEqual(["Bash", "Read", "Grep"])
    expect(parsed.body).toContain("Focus on vulnerabilities.")
  })

  test("normalizes agent name to lowercase with hyphens", () => {
    const plugin: ClaudePlugin = {
      ...fixturePlugin,
      agents: [
        {
          name: "My Agent Name",
          description: "Test agent",
          body: "Test body",
          sourcePath: "/tmp/test.md",
        },
      ],
    }

    const bundle = convertClaudeToQoder(plugin, {
      agentMode: "subagent",
      inferTemperature: false,
      permissions: "none",
    })

    expect(bundle.agents[0].name).toBe("my-agent-name")
  })

  test("includes skillDirs for skills", () => {
    const bundle = convertClaudeToQoder(fixturePlugin, {
      agentMode: "subagent",
      inferTemperature: false,
      permissions: "none",
    })

    expect(bundle.skillDirs).toHaveLength(1)
    expect(bundle.skillDirs[0].name).toBe("existing-skill")
    expect(bundle.skillDirs[0].sourceDir).toBe("/tmp/plugin/skills/existing-skill")
  })

  test("rewrites Claude paths to Qoder paths", () => {
    const plugin: ClaudePlugin = {
      ...fixturePlugin,
      agents: [
        {
          name: "Test Agent",
          description: "Test",
          body: "Use ~/.claude/settings.json for configuration",
          sourcePath: "/tmp/test.md",
        },
      ],
    }

    const bundle = convertClaudeToQoder(plugin, {
      agentMode: "subagent",
      inferTemperature: false,
      permissions: "none",
    })

    expect(bundle.agents[0].content).toContain("~/.qoder/")
  })
})
