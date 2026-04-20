---
mode: agent
description: "Analyze _temp folder, process pending artifacts, move files to proper locations, and update all related documentation."
---

Analyze `_temp/` and execute complete triage with Platform Engineering Guardian.

Goal:

- Ensure no actionable artifacts remain in `_temp/`.
- Process and relocate valid files to canonical locations.
- Keep structure, scripts, and docs aligned with repository standards.

Optional context:

- Scope: ${input:scope:Example: \_temp only, or \_temp + scripts + docs}
- Constraints: ${input:constraints:Example: preserve behavior, no destructive changes}

Expected steps:

1. Inspect `_temp/` and classify each file by type.
2. Modernize files to match standards when needed.
3. Move files to proper destinations (`scripts/install`, `scripts/install/standalone`, `scripts/maintenance`, `scripts/utils`, `docs/runbooks`).
4. Ensure one runbook per created/updated operational script.
5. Update impacted README indexes for discoverability.
6. Validate naming, syntax, and references.

Output format:

1. Findings
2. Recommended actions
3. Applied changes
4. Next steps
