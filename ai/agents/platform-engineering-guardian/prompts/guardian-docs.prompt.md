---
mode: agent
description: "Use when: audit and update documentation, README files, and runbook coverage with focus on discoverability and consistency."
---

Review and update documentation and README files with the Platform Engineering Guardian agent.

Use when:

- You need to fix navigation, indexes, and consistency between scripts and docs.
- You need runbook coverage for operational scripts and updates to `docs/runbooks/README.md`.

Avoid when:

- The main task is shell script technical standardization (use `/guardian-scripts`).
- The main task is CI/CD pipelines (use `/guardian-cicd`).

Scope default:

- `docs/`, `scripts/README.md`, `scripts/install/README.md`, `scripts/install/standalone/README.md`, and `docs/runbooks/`.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps

Optional context:

- Scope: ${input:scope:Ex.: docs/runbooks, scripts/README.md, root README}
- Goal: ${input:goal:Ex.: close runbook gaps and align indexes}

Criteria:

- Ensure consistency between scripts and runbooks.
- Update local indexes and navigation.
- Avoid root-level operational markdown when content belongs in `docs/runbooks`.
