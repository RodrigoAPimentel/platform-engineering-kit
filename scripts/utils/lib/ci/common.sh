#!/usr/bin/env bash

ci_repo_root_from() {
    local script_path
    local script_dir
    local git_root
    local probe_dir

    script_path="${1:?script path is required}"
    script_dir="$(cd "$(dirname "${script_path}")" && pwd)"

    if command -v git >/dev/null 2>&1; then
        if git_root="$(git -C "${script_dir}" rev-parse --show-toplevel 2>/dev/null)"; then
            printf '%s\n' "${git_root}"
            return 0
        fi
    fi

    probe_dir="${script_dir}"
    while [[ "${probe_dir}" != "/" ]]; do
        if [[ -d "${probe_dir}/.github" && -d "${probe_dir}/scripts" ]]; then
            printf '%s\n' "${probe_dir}"
            return 0
        fi
        probe_dir="$(dirname "${probe_dir}")"
    done

    ci_log_error "Unable to determine repository root from ${script_path}"
    return 1
}

ci_log_info() {
    printf '[ci] %s\n' "$1"
}

ci_log_error() {
    printf '[ci][error] %s\n' "$1" >&2
}

ci_require_commands() {
    local cmd

    for cmd in "$@"; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            ci_log_error "Missing required command: ${cmd}"
            return 1
        fi
    done
}
