---
mode: agent
description: "Use when: synchronize Platform Engineering Guardian prompts and instructions between .github and ai with traceability."
---

Review and synchronize Platform Engineering Guardian definitions across all official locations.

Use when:

- A prompt, agent definition, or usage manual changed in one location.
- You need parity between VS Code execution assets and the versioned package in `ai/`.

Avoid when:

- The main task is repository/code auditing (use another Guardian prompt).

Scope default:

- `.github/agents/`, `.github/prompts/`, `ai/agents/platform-engineering-guardian/`, and `ai/agents/platform-engineering-guardian/prompts/`.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps

Objective:

- Ensure parity between `.github/agents` and `ai/agents`.
- Ensure parity between `.github/prompts` and `ai/agents/platform-engineering-guardian/prompts`.
- Update usage manuals and related prompts.
- Record a new package version when changes are significant.

Checklist:

1. Compare current definitions.
2. Apply the same rules to agent files in both locations.
3. Apply the same prompt changes in both locations.
4. Update usage and prompt index/catalog files.
5. Publish a version snapshot when needed.
