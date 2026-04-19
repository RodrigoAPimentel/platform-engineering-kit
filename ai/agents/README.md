# 🤖 Agents

Definitions of AI agents.

## Usage Modes

- Agent selector mode: use `.github/agents/platform-engineering-guardian.agent.md`.
- Slash command mode: use prompts from `.github/prompts/` in Copilot Chat (`/guardian-*`).

## Scalable Structure

For future multi-agent growth, each agent should use its own package folder:

- `ai/agents/<agent-name>/README.md`
- `ai/agents/<agent-name>/versions/`
- `ai/agents/<agent-name>/prompts/`

Current package:

- `ai/agents/platform-engineering-guardian/`

Compatibility files now live inside the agent package:

- `ai/agents/platform-engineering-guardian/platform-engineering-guardian.agent.md`
- `ai/agents/platform-engineering-guardian/platform-engineering-guardian.agent_USAGE.md`

## Purpose

Enable intelligent automation and assistance.
