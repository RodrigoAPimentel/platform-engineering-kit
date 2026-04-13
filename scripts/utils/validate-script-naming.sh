#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TARGET_DIR="${ROOT_DIR}/scripts"
NAME_REGEX='^[a-z0-9]+(-[a-z0-9]+)*\.sh$'

violations=()

while IFS= read -r -d '' file; do
    name="$(basename "${file}")"
    rel_path="${file#${ROOT_DIR}/}"

    if [[ ! "${name}" =~ ${NAME_REGEX} ]]; then
        violations+=("${rel_path}")
    fi
done < <(find "${TARGET_DIR}" -type f -name '*.sh' -print0)

if [[ ${#violations[@]} -gt 0 ]]; then
    printf 'Script naming violations found (expected kebab-case):\n'
    printf ' - %s\n' "${violations[@]}"
    exit 1
fi

printf 'Script naming check passed for %s\n' "${TARGET_DIR}"
