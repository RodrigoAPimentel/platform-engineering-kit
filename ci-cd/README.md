# 🔄 CI/CD

Continuous Integration and Continuous Delivery pipelines.

## Contents

- azure-devops → Pipelines
- github-actions → Workflows
- templates → Reusable pipelines
- ci-setup-and-usage.md → CI setup, configuration, and usage manual

## Purpose

Standardize build, test and deployment automation.

## Quick Start

1. Read [`ci-setup-and-usage.md`](ci-setup-and-usage.md).
2. Configure or update workflows in `.github/workflows/`.
3. Mirror changes in `ci-cd/github-actions/`.
4. Open a pull request and validate CI checks.

## Local Checks

From repository root:

```bash
bash -n scripts/utils/lib/ci/validate-script-naming.sh
bash -n scripts/utils/lib/ci/validate-english-content.sh
bash -n scripts/utils/lib/ci/validate-docker-compose-config.sh
```

Then run:

```bash
bash scripts/utils/lib/ci/validate-script-naming.sh
bash scripts/utils/lib/ci/validate-english-content.sh
bash scripts/utils/lib/ci/validate-docker-compose-config.sh
```
