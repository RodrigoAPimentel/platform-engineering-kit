#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

ROOT_DIR="$(ci_repo_root_from "${BASH_SOURCE[0]}")"
TARGET_DIR="${ROOT_DIR}/scripts"
NAME_REGEX='^[a-z0-9]+(-[a-z0-9]+)*\.sh$'

ci_require_commands find basename

violations=()

while IFS= read -r -d '' file; do
    name="$(basename "${file}")"
    rel_path="${file#${ROOT_DIR}/}"

    if [[ ! "${name}" =~ ${NAME_REGEX} ]]; then
        violations+=("${rel_path}")
    fi
done < <(find "${TARGET_DIR}" -type f -name '*.sh' -print0)

if [[ ${#violations[@]} -gt 0 ]]; then
    ci_log_error 'Script naming violations found (expected kebab-case):'
    printf ' - %s\n' "${violations[@]}"
    exit 1
fi

ci_log_info "Script naming check passed for ${TARGET_DIR}"
