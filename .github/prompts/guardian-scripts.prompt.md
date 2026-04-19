---
mode: agent
description: "Use when: review shell scripts with focus on technical standards, naming, structure, and minimum required documentation impact."
---

Review automation scripts and apply standards corrections with the Platform Engineering Guardian agent.

Use when:

- You need to fix shebang, strict mode, naming convention, and script organization.
- You need to review CLI contracts, operational messaging, and script reuse.

Avoid when:

- The main focus is runbook/index documentation reorganization (use `/guardian-docs`).
- The main focus is CI/CD (use `/guardian-cicd`).

Scope default:

- `scripts/install/`, `scripts/maintenance/`, `scripts/utils/`, and `scripts/install/standalone/`.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps

Optional context:

- Scope: ${input:scope:Ex.: scripts/install, scripts/maintenance, scripts/install/standalone}
- Constraints: ${input:constraints:Ex.: no feature removal}

Minimum checklist:

- Shebang and strict mode.
- Kebab-case naming under `scripts/`.
- Correct structure (`install`, `maintenance`, `standalone`, `utils/lib`).
- One runbook per created/updated script.
- Updates to affected README files.
