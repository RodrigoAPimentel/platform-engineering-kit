# 🏗 Infrastructure

Infrastructure as Code (IaC) definitions.

## Contents

- terraform → Multi-cloud provisioning
- bicep → Azure-native IaC
- ansible → Configuration management

## Purpose

Ensure scalable, repeatable and version-controlled infrastructure.

## Getting Started

1. Select the target stack:
   - `terraform/` for multi-cloud modules and environments.
   - `bicep/` for Azure-native deployments.
   - `ansible/` for post-provisioning configuration.
2. Read the corresponding README in each subdirectory before applying changes.
3. Keep environment-specific values outside versioned code when they include sensitive data.

## Validation Notes

- Run each stack's native validation commands from its own directory (for example, Terraform/Bicep/Ansible lint or validate commands when configured).
- If a validation command is not documented in the subdirectory yet, document it before relying on manual-only checks.
