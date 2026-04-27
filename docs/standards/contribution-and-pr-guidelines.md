# Contribution and PR Guidelines

This guide defines the minimum contribution flow for this repository.

## Prerequisites

- Git installed and configured locally.
- Bash available for local validation scripts.
- Access to repository CI (GitHub Actions and/or mirrored CI workflow review process).

## Branch and Commit Workflow

1. Create a branch from the target base branch (`develop` or `main`, according to team policy).
2. Keep changes scoped to one logical topic when possible.
3. Write clear commit messages in imperative style (example: `Update CI documentation links`).
4. Keep documentation updates in the same pull request as related code, scripts, or workflows.

## Pull Request Minimum Standard

- Describe what changed and why.
- Describe validation executed locally.
- List known limitations or follow-ups not covered in the current PR.
- For CI workflow changes, mirror updates in:
  - `.github/workflows/`
  - `ci-cd/github-actions/`

## Required Local Validation (When Available)

Run from repository root:

```bash
bash -n scripts/utils/lib/ci/validate-script-naming.sh
bash -n scripts/utils/lib/ci/validate-english-content.sh
bash -n scripts/utils/lib/ci/validate-docker-compose-config.sh
bash scripts/utils/lib/ci/validate-script-naming.sh
bash scripts/utils/lib/ci/validate-english-content.sh
bash scripts/utils/lib/ci/validate-docker-compose-config.sh
```

If any script does not exist in your branch, explicitly mention that in the PR description.

## Documentation and Runbook Expectations

- Update README indexes when adding, moving, or deleting files.
- For any created or modified script in `scripts/install/` or `scripts/maintenance/`, update the corresponding runbook in `docs/runbooks/`.
- Keep operational instructions executable (real paths, prerequisites, and commands).

## Security and Secrets

- Do not commit credentials, tokens, or private keys.
- Avoid passing secrets directly in shell command arguments.
- Follow repository guidance under `security/secrets/README.md`.
