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
analyzed_dirs=()
analyzed_scripts=()

while IFS= read -r -d '' file; do
    name="$(basename "${file}")"
    rel_path="${file#${ROOT_DIR}/}"
    rel_dir="${rel_path%/*}"

    analyzed_scripts+=("${rel_path}")

    dir_already_listed=false
    for listed_dir in "${analyzed_dirs[@]}"; do
        if [[ "${listed_dir}" == "${rel_dir}" ]]; then
            dir_already_listed=true
            break
        fi
    done

    if [[ "${dir_already_listed}" == false ]]; then
        analyzed_dirs+=("${rel_dir}")
    fi

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

if [[ ${#analyzed_dirs[@]} -gt 0 ]]; then
    ci_log_info "Folders analyzed (${#analyzed_dirs[@]}):"
    printf ' - %s\n' "${analyzed_dirs[@]}"
else
    ci_log_info 'Folders analyzed: none'
fi

if [[ ${#analyzed_scripts[@]} -gt 0 ]]; then
    ci_log_info "Scripts analyzed (${#analyzed_scripts[@]}):"
    printf ' - %s\n' "${analyzed_scripts[@]}"
else
    ci_log_info 'Scripts analyzed: none'
fi
