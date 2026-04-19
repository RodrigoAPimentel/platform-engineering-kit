# ⚡ GitHub Actions

CI/CD workflows using GitHub Actions.

## Contents

- Workflow files
- Automation pipelines
- `validate-script-naming.yml` → Enforces kebab-case naming for shell scripts under `scripts/`.
- `test-install-awx.yml` → Validates Ansible AWX installation script across multiple Linux distributions (CentOS 7, Rocky Linux 8/9, Ubuntu 20.04/22.04) with syntax checks, dry-run tests, and code quality analysis.

## Purpose

Enable automated build, test and deployment.

## Usage

- Full setup and operations guide: [ci-cd/ci-setup-and-usage.md](ci-cd/ci-setup-and-usage.md)
- Use `.github/workflows/` as active workflows and keep mirrored copies in `ci-cd/github-actions/`.

## Mirroring Policy

- Keep workflow files mirrored between:
  - `.github/workflows/`
  - `ci-cd/github-actions/`
- Any workflow create/update/delete must be applied in both locations in the same change.
- Keep workflow names, triggers, and step labels standardized in English.
