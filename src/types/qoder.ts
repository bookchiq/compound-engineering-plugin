export type QoderAgentFile = {
  name: string
  content: string
}

export type QoderSkillDir = {
  name: string
  sourceDir: string
}

export type QoderBundle = {
  agents: QoderAgentFile[]
  skillDirs: QoderSkillDir[]
}
