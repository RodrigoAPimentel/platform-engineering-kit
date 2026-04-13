# Script Naming Convention

This standard defines shell script naming to keep automation assets readable, discoverable, and consistent.

## Rule

Use `kebab-case` for every `.sh` file under `scripts/`.

Pattern:

`^[a-z0-9]+(-[a-z0-9]+)*.sh$`

## Why this standard

- Improves readability and scanning in large repositories.
- Avoids mixed naming styles (`snake_case`, `camelCase`, prefixed underscore).
- Enables deterministic CI validation.

## Naming Matrix

| Script Type                       | Location               | Pattern                 | Example                     |
| --------------------------------- | ---------------------- | ----------------------- | --------------------------- |
| Install and setup entrypoints     | `scripts/install/`     | `<action>-<scope>.sh`   | `initial-preparation.sh`    |
| Utility validators and generators | `scripts/utils/`       | `<action>-<object>.sh`  | `validate-script-naming.sh` |
| Shared shell libraries            | `scripts/utils/lib/`   | `<domain>-<purpose>.sh` | `system-functions.sh`       |
| Maintenance operations            | `scripts/maintenance/` | `<verb>-<target>.sh`    | `cleanup-artifacts.sh`      |

## Allowed and not allowed

Allowed:

- `generate-structure.sh`
- `logging.sh`
- `basic-packages.sh`

Not allowed:

- `_logs.sh`
- `basic_packages.sh`
- `initialPreparation.sh`

## Enforcement

Validation script:

- `scripts/utils/validate-script-naming.sh`

CI workflow:

- `ci-cd/github-actions/validate-script-naming.yml`
