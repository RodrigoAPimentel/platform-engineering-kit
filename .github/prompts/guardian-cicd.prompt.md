---
mode: agent
description: "Use when: review CI/CD pipelines, quality gates, and validation standards for scripts and infrastructure."
---

Audit and standardize CI/CD with the Platform Engineering Guardian agent.

Use when:

- You need to evolve pipelines, checks, and validation templates.
- You need to improve reliability, feedback speed, and multi-distro coverage.

Avoid when:

- The main task is script quality outside pipelines (use `/guardian-scripts`).
- The main task is documentation and indexing (use `/guardian-docs`).

Scope default:

- `ci-cd/github-actions/`, `ci-cd/azure-devops/`, and `ci-cd/templates/`.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps

Optional context:

- Scope: ${input:scope:Ex.: ci-cd/github-actions, ci-cd/templates}
- Goal: ${input:goal:Ex.: expand multi-distro script tests}

Criticality:

- Prioritize reliability, reuse, and fast feedback.
- Verify coverage for naming/syntax/script validations.
