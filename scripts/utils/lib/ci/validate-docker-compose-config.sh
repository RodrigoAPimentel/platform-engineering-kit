#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

ROOT_DIR="${1:-.}"

if [[ ! -d "${ROOT_DIR}" ]]; then
    echo "[ERROR] Root directory not found: ${ROOT_DIR}" >&2
    exit 1
fi

mapfile -d '' compose_files < <(
    find "${ROOT_DIR}" -type f \( -name 'docker-compose*.yml' -o -name 'docker-compose*.yaml' \) -print0 | sort -z
)

if [[ ${#compose_files[@]} -eq 0 ]]; then
    echo "[INFO] No docker compose files found."
    exit 0
fi

echo "[INFO] Found ${#compose_files[@]} docker compose file(s)."

failures=0

extract_env_files() {
    local compose_file="$1"

    awk '
        /^[[:space:]]*env_file:[[:space:]]*$/ { in_env=1; next }
        in_env == 1 {
            if ($0 ~ /^[[:space:]]*-[[:space:]]*/) {
                line=$0
                sub(/^[[:space:]]*-[[:space:]]*/, "", line)
                sub(/[[:space:]]*#.*/, "", line)
                gsub(/"/, "", line)
                gsub(/\047/, "", line)
                if (line != "") print line
                next
            }
            if ($0 ~ /^[[:space:]]*[A-Za-z0-9_.-]+:[[:space:]]*/ || $0 ~ /^[^[:space:]]/) {
                in_env=0
            }
        }
    ' "${compose_file}"
}

for compose_file in "${compose_files[@]}"; do
    compose_dir="$(cd "$(dirname "${compose_file}")" && pwd)"
    compose_name="$(basename "${compose_file}")"

    echo "[INFO] Validating ${compose_file}"

    created_files=()

    # Provide an empty default .env when missing to avoid false negatives.
    if [[ ! -f "${compose_dir}/.env" ]]; then
        : > "${compose_dir}/.env"
        created_files+=("${compose_dir}/.env")
    fi

    while IFS= read -r env_path; do
        [[ -z "${env_path}" ]] && continue

        if [[ "${env_path}" = /* ]]; then
            target_env="${env_path}"
        else
            target_env="${compose_dir}/${env_path}"
        fi

        if [[ ! -f "${target_env}" ]]; then
            mkdir -p "$(dirname "${target_env}")"
            : > "${target_env}"
            created_files+=("${target_env}")
        fi
    done < <(extract_env_files "${compose_file}")

    if (cd "${compose_dir}" && docker compose -f "${compose_name}" config >/dev/null); then
        echo "[OK] ${compose_file}"
    else
        echo "[FAIL] ${compose_file}" >&2
        failures=$((failures + 1))
    fi

    for created_file in "${created_files[@]}"; do
        rm -f "${created_file}"
    done
done

if [[ ${failures} -gt 0 ]]; then
    echo "[ERROR] Validation failed for ${failures} docker compose file(s)." >&2
    exit 1
fi

echo "[INFO] All docker compose files are valid."
