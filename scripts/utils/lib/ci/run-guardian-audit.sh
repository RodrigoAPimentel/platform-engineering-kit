#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/workflow-audit.sh"

ROOT_DIR="$(ci_repo_root_from "${BASH_SOURCE[0]}")"
cd "${ROOT_DIR}"

ci_log_info "Starting guardian repository audit checks..."
ci_require_commands bash diff find sort

required_files=(
  ".github/prompts/guardian-audit.prompt.md"
  ".github/agents/platform-engineering-guardian.agent.md"
  ".github/agents/platform-engineering-guardian.agent_USAGE.md"
  "ai/agents/platform-engineering-guardian/platform-engineering-guardian.agent.md"
  "ai/agents/platform-engineering-guardian/platform-engineering-guardian.agent_USAGE.md"
  "ci-cd/ci-setup-and-usage.md"
  "ci-cd/github-actions/README.md"
)

for file_path in "${required_files[@]}"; do
  if [[ ! -f "${file_path}" ]]; then
    ci_log_error "Missing required file: ${file_path}"
    exit 1
  fi
done

ci_log_info "Verifying mirrored workflow inventory..."
ci_assert_workflow_inventory_match ".github/workflows" "ci-cd/github-actions"

ci_log_info "Verifying mirrored workflow content..."
ci_assert_workflow_content_match ".github/workflows" "ci-cd/github-actions"

ci_log_info "Running script naming validation..."
bash scripts/utils/lib/ci/validate-script-naming.sh

ci_log_info "Running English-only validation..."
bash scripts/utils/lib/ci/validate-english-content.sh

ci_log_info "Guardian audit passed."
