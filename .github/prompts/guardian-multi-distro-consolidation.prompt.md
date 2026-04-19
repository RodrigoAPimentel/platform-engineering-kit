---
mode: agent
description: "Use when: consolidate distro-specific installers into a single script with OS and package manager detection."
---

Consolidate distro-specific installer variants into one reusable script.

Use when:

- There are separate scripts by distro for the same tool.
- The objective is to reduce duplication while keeping apt/dnf/yum coverage.

Avoid when:

- The main task is only standalone folder organization (use `/guardian-standalone-categorization`).
- The main task is broad auditing without specialized execution (use `/guardian-audit`).

Scope default:

- `scripts/install/` and `scripts/install/standalone/`.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps

Typical scope:

- scripts/install
- scripts/install/standalone

Criteria:

- One script per tool whenever feasible.
- apt/dnf/yum detection and architecture-specific adjustments when needed.
- No removal of existing functionality.
- Update the corresponding README and runbook.
