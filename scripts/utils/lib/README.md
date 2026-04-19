# Shell Libraries

Reusable shell modules shared across installation and maintenance scripts.

## Contents

- `logging.sh` -> Structured logging helpers with levels and execution summary.
- `system-functions.sh` -> Cross-distro package and system helper functions.
- `basic-packages.sh` -> Baseline package list used by setup scripts.
- `ci/common.sh` -> Shared CI helper functions (repository root resolution, logging, command checks).
- `ci/workflow-audit.sh` -> CI helpers for workflow mirror inventory and content checks.
- `ci/validate-script-naming.sh` -> CI entrypoint for shell naming validation.
- `ci/validate-english-content.sh` -> CI entrypoint for English-only content validation.
- `ci/run-guardian-audit.sh` -> CI entrypoint for full guardian audit gate.

## Purpose

Improve script consistency, maintainability and reuse.
