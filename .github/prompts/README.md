# Prompt Commands

Slash commands for Platform Engineering Guardian workflows.

## How to use

In Copilot Chat, type `/` and choose one of the commands below.

## Commands

- `/guardian-audit` -> Broad diagnosis with prioritized gaps (default planning entry point).
- `/guardian-docs` -> Documentation, indexes, and runbook coverage.
- `/guardian-scripts` -> Shell script technical quality (standards, naming, and structure).
- `/guardian-cicd` -> Pipeline and quality gate review/standardization.
- `/guardian-standalone-categorization` -> Organization of independent installers under standalone.
- `/guardian-multi-distro-consolidation` -> Consolidation of distro-specific installers into one script.
- `/guardian-agent-sync` -> Synchronization of prompts and agent instructions between `.github` and `ai`.
- `/guardian-temp-triage` -> Analyze `_temp/`, classify artifacts, and move valid files to canonical locations.

## Synchronization Policy

- Any prompt change must be mirrored between `.github/prompts/` and `ai/agents/platform-engineering-guardian/prompts/`.
- Any agent instruction change must be mirrored between `.github/agents/platform-engineering-guardian.agent.md` and `ai/agents/platform-engineering-guardian/platform-engineering-guardian.agent.md`.
- Catalog and usage changes must also update `ai/agents/platform-engineering-guardian/platform-engineering-guardian.agent_USAGE.md`.

## Purpose

Provide reusable, guided entry points for frequent platform engineering tasks.

## Troubleshooting

- If the `/` command list does not appear in Copilot Chat, reload the window after opening the workspace and verify that the `.github/prompts/*.prompt.md` files are present.
