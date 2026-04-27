# ⚙️ Ansible

Configuration management and automation.

## Contents

- `playbooks/` - Operational and provisioning playbooks grouped by domain.
- `roles/` - Reusable role modules consumed by playbooks.
- `collections/` - `ansible-galaxy` dependency declarations.

## Purpose

Automate system configuration and operational tasks.

## Usage

1. Install collections from `collections/requirements.yml`.
2. Run lint and syntax validation before PRs.
3. Keep inventory, variables, and secrets externalized from versioned code.
