# Platform Engineering Guardian Package

Structured package for the Platform Engineering Guardian agent, prepared for long-term versioning and future multi-agent expansion.

## Structure

- versions/ -> immutable snapshots of agent definition and usage docs.
- prompts/ -> reusable task-focused prompts derived from real repository workflows.

## Current Version

- v1.0.0
  - versions/v1.0.0.agent.md
  - versions/v1.0.0.usage.md

## Prompt Catalog

- prompts/guardian-audit.prompt.md
- prompts/guardian-docs.prompt.md
- prompts/guardian-scripts.prompt.md
- prompts/guardian-cicd.prompt.md
- prompts/guardian-standalone-categorization.prompt.md
- prompts/guardian-multi-distro-consolidation.prompt.md
- prompts/guardian-agent-sync.prompt.md
- prompts/guardian-temp-triage.prompt.md

## Governance Notes

- Keep active execution entrypoint in .github/agents.
- Mirror behavioral changes between .github/agents and the package definition at `ai/agents/platform-engineering-guardian/`.
- When changing behavior significantly, publish a new version snapshot under versions/.

## Synchronization Policy

- **All prompt files (.prompt.md) in `.github/prompts` and `ai/agents/platform-engineering-guardian/prompts` must be kept in sync.**
- Any change in one location (creation, update, removal) must be reflected in the other.
- **All agent instruction changes must be mirrored between `.github/agents/platform-engineering-guardian.agent.md` and `ai/agents/platform-engineering-guardian/platform-engineering-guardian.agent.md`.**
- **Any command/catalog change must update `ai/agents/platform-engineering-guardian/platform-engineering-guardian.agent_USAGE.md`.**
- This ensures that VS Code usage and long-term versioning are always aligned.
- Use the agent-sync prompt (`guardian-agent-sync.prompt.md`) to audit and restore parity.

## Language Policy

- The default language for prompts, agent instructions, and package documentation is English.
- Use another language only when explicitly requested for a specific task.

## Troubleshooting

- If slash prompts do not appear in Copilot Chat, reload the window and confirm that the prompt files exist in both `.github/prompts/` and `ai/agents/platform-engineering-guardian/prompts/`.
