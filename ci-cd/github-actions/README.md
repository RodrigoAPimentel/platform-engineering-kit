# ⚡ GitHub Actions

CI/CD workflows using GitHub Actions.

## Contents

- Workflow files
- Automation pipelines
- `guardian-audit-gate.yml` → Runs repository-wide guardian audit checks on every push and pull request.
- `validate-script-naming.yml` → Enforces kebab-case naming for shell scripts under `scripts/`.
- `validate-docker-compose-config.yml` → Recursively validates all Docker Compose files with `docker compose config`.
- `test-install-awx.yml` → Validates Ansible AWX installation script across multiple Linux distributions (CentOS 7, Rocky Linux 8/9, Ubuntu 20.04/22.04) with syntax checks, dry-run tests, and code quality analysis.
- `validate-ansible-temp.yml` → Validates Ansible assets under `infrastructure/ansible/` with `yamllint`, `ansible-lint`, and syntax checks.

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
