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

- prompts/guardian-context-migration.prompt.md
- prompts/guardian-multi-distro-consolidation.prompt.md
- prompts/guardian-runbook-enforcement.prompt.md
- prompts/guardian-standalone-categorization.prompt.md
- prompts/guardian-agent-sync.prompt.md

## Governance Notes

- Keep active execution entrypoint in .github/agents.
- Mirror behavioral changes in both .github/agents and ai/agents root definition.
- When changing behavior significantly, publish a new version snapshot under versions/.
