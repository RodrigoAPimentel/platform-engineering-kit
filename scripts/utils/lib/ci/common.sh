#!/usr/bin/env bash

ci_repo_root_from() {
    local script_path
    script_path="${1:?script path is required}"

    (cd "$(dirname "${script_path}")/../.." && pwd)
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
