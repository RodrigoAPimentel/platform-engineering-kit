# 💬 Prompts

Reusable prompts.

## Slash Commands

Workspace slash commands live in `.github/prompts/` and can be invoked in chat with `/`:

- `/guardian-audit`
- `/guardian-docs`
- `/guardian-scripts`
- `/guardian-cicd`
- `/guardian-standalone-categorization`
- `/guardian-multi-distro-consolidation`
- `/guardian-agent-sync`
- `/guardian-temp-triage`

## Agent-Specific Prompt Packs

Specialized prompt packs are versioned under each agent package:

- `ai/agents/platform-engineering-guardian/prompts/`
  - `guardian-context-migration.prompt.md`
  - `guardian-multi-distro-consolidation.prompt.md`
  - `guardian-runbook-enforcement.prompt.md`
  - `guardian-standalone-categorization.prompt.md`
  - `guardian-agent-sync.prompt.md`

## Purpose

Standardize AI interactions.

## Synchronization Policy

- Keep command catalogs synchronized between `.github/prompts/README.md` and this file.
- Keep prompt files synchronized between `.github/prompts/` and `ai/agents/platform-engineering-guardian/prompts/`.
