---
mode: agent
description: "Use when: run a broad repository diagnosis with prioritized gaps, without default cross-cutting refactoring."
---

Run a broad repository diagnosis with the Platform Engineering Guardian agent.

Use when:

- You need a holistic view of structural quality, scripts, docs, CI/CD, and governance.
- You want a prioritized backlog before deciding the execution plan.

Avoid when:

- The objective is already limited to a specific domain (use `/guardian-docs`, `/guardian-scripts`, or `/guardian-cicd`).
- You need to execute a specialized migration (use `/guardian-standalone-categorization` or `/guardian-multi-distro-consolidation`).

Scope default:

- Full repository, unless `scope` is provided.

Output format:

1. Findings (ordered by severity, with file references).
2. Recommended actions (reusable and scalable).
3. Applied changes (what changed and expected impact).
4. Next steps (1-3 follow-up steps).

Optional context:

- Scope: ${input:scope:Ex.: scripts, docs, ci-cd, or full repository}
- Constraints: ${input:constraints:Ex.: no destructive changes, no broad refactoring}
- Expected outcome: ${input:outcome:Ex.: gap list with applied fixes}
