import { describe, expect, test } from "bun:test"
import { promises as fs } from "fs"
import path from "path"
import os from "os"
import { writeQoderBundle } from "../src/targets/qoder"
import type { QoderBundle } from "../src/types/qoder"

async function exists(filePath: string): Promise<boolean> {
  try {
    await fs.access(filePath)
    return true
  } catch {
    return false
  }
}

describe("writeQoderBundle", () => {
  test("writes agents and skills to correct locations", async () => {
    const tempRoot = await fs.mkdtemp(path.join(os.tmpdir(), "qoder-test-"))
    const bundle: QoderBundle = {
      agents: [
        {
          name: "security-reviewer",
          content: "---\nname: security-reviewer\ndescription: Security\n---\n\nReview code.",
        },
      ],
      skillDirs: [
        {
          name: "skill-one",
          sourceDir: path.join(import.meta.dir, "fixtures", "sample-plugin", "skills", "skill-one"),
        },
      ],
    }

    await writeQoderBundle(tempRoot, bundle)

    // Check agents are written to .qoder/agents/
    expect(await exists(path.join(tempRoot, ".qoder", "agents", "security-reviewer.md"))).toBe(true)

    // Check skills are copied to .qoder/skills/
    expect(await exists(path.join(tempRoot, ".qoder", "skills", "skill-one", "SKILL.md"))).toBe(true)
  })

  test("writes to .qoder directly when outputRoot is .qoder", async () => {
    const tempRoot = await fs.mkdtemp(path.join(os.tmpdir(), "qoder-test-"))
    const qoderRoot = path.join(tempRoot, ".qoder")
    await fs.mkdir(qoderRoot)

    const bundle: QoderBundle = {
      agents: [
        {
          name: "test-agent",
          content: "---\nname: test-agent\ndescription: Test\n---\n\nTest agent.",
        },
      ],
      skillDirs: [],
    }

    await writeQoderBundle(qoderRoot, bundle)

    expect(await exists(path.join(qoderRoot, "agents", "test-agent.md"))).toBe(true)
  })

  test("handles empty bundle", async () => {
    const tempRoot = await fs.mkdtemp(path.join(os.tmpdir(), "qoder-test-"))
    const bundle: QoderBundle = {
      agents: [],
      skillDirs: [],
    }

    await writeQoderBundle(tempRoot, bundle)

    // Should not throw, no files created
    expect(await exists(path.join(tempRoot, ".qoder"))).toBe(false)
  })
})
