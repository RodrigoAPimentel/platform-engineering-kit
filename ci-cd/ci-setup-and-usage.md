# CI Setup and Usage Manual

This guide explains how to configure, maintain, and use CI workflows in this repository.

## Scope

- CI implementation paths:
  - `.github/workflows/` (active GitHub Actions workflows)
  - `ci-cd/github-actions/` (mirrored workflow catalog)
- Script validators used by CI:
  - `scripts/utils/validate-script-naming.sh`
  - `scripts/utils/validate-english-content.sh`

## Prerequisites

- GitHub repository with Actions enabled.
- Branch strategy aligned with current workflows (`main` and `develop`).
- Shell scripts executable and using Bash strict mode where applicable.

## Current Workflow Inventory

- `validate-script-naming.yml`
  - Validates shell script naming convention.
- `validate-repository-language.yml`
  - Enforces English-only policy in governed paths.
- `test-install-awx.yml`
  - Validates AWX installer script quality and compatibility.

## How CI Is Triggered

- `pull_request`
  - Runs when governed files are changed.
- `push`
  - Runs on `main` and `develop` for governed paths.

Each workflow uses `paths` filters. If your changes are outside these filters, no run is triggered.

## Configure a New Workflow

1. Create the workflow in `.github/workflows/`.
2. Mirror the same file in `ci-cd/github-actions/`.
3. Keep both files synchronized in the same commit.
4. Use English for:
   - workflow names
   - job names
   - step names
   - workflow documentation
5. Include path triggers for both mirrored locations when applicable:
   - `.github/workflows/<workflow>.yml`
   - `ci-cd/github-actions/<workflow>.yml`

## Update an Existing Workflow

1. Edit the workflow in `.github/workflows/`.
2. Apply the same update to the mirrored file in `ci-cd/github-actions/`.
3. Verify syntax and run conditions before opening a pull request.

## Local Validation Before Push

Use these commands from repository root:

```bash
bash -n scripts/utils/validate-script-naming.sh
bash -n scripts/utils/validate-english-content.sh
bash scripts/utils/validate-script-naming.sh
bash scripts/utils/validate-english-content.sh
```

## Open a Pull Request and Validate

1. Push your branch.
2. Open a pull request targeting `develop` or `main`.
3. Confirm CI runs in GitHub Actions.
4. Review failing jobs and logs, then fix and push again.

## Common Issues and Fixes

- Workflow did not trigger:
  - Check if changed files match workflow `paths` filters.
- `Resource not accessible by integration`:
  - Common on forked PRs for security-events upload steps.
  - Gate privileged steps to internal PRs or push events.
- `CodeQL did not detect any code`:
  - Select languages that actually exist in the repository for that workflow context.
- Shell validator says command not found (`rg`):
  - Ensure Ripgrep is available in the runner before executing validation.

## Pull Request Checklist (CI)

- Workflow updated in both mirror locations.
- Path triggers include both mirror file paths.
- English naming and labels are preserved.
- Validators run locally.
- README indexes updated when introducing new workflow files.

## Ownership and Maintenance

- CI standards are maintained under:
  - `ci-cd/`
  - `.github/workflows/`
- Agent guidance is maintained under:
  - `.github/agents/`
  - `ai/agents/platform-engineering-guardian/`
