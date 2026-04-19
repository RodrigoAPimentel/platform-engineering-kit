---
mode: agent
description: "Use when: classify and organize independent installers under scripts/install/standalone with complete documentation."
---

Analyze independent application installers and organize them in the standalone category.

Use when:

- You need to move/adjust independent installers into `scripts/install/standalone`.
- You need to align README files and runbooks after standalone categorization.

Avoid when:

- The main task is multi-distro consolidation for one installer (use `/guardian-multi-distro-consolidation`).
- The main task is general script improvement without standalone scope (use `/guardian-scripts`).

Scope default:

- `scripts/install/standalone/`, `scripts/install/README.md`, `scripts/README.md`, and related runbooks.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps

Objective:

- Move independent installers to `scripts/install/standalone`.
- Update `scripts/README.md`, `scripts/install/README.md`, and `scripts/install/standalone/README.md`.
- Create dedicated runbooks.

Criteria:

- Preserve functionality.
- Improve readability and reuse.
- Standardize CLI interface and operational messaging.
