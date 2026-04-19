#!/usr/bin/env bash

ci_collect_workflow_files() {
    local workflows_dir
    workflows_dir="${1:?workflows dir is required}"

    find "${workflows_dir}" -maxdepth 1 -type f -name '*.yml' -printf '%f\n' | sort
}

ci_assert_workflow_inventory_match() {
    local left_dir right_dir
    left_dir="${1:?left dir is required}"
    right_dir="${2:?right dir is required}"

    local left_files right_files
    mapfile -t left_files < <(ci_collect_workflow_files "${left_dir}")
    mapfile -t right_files < <(ci_collect_workflow_files "${right_dir}")

    if [[ "${left_files[*]}" != "${right_files[*]}" ]]; then
        ci_log_error "Workflow file list mismatch between ${left_dir} and ${right_dir}"
        printf '[ci][error] %s files:\n' "${left_dir}" >&2
        printf '  - %s\n' "${left_files[@]}" >&2
        printf '[ci][error] %s files:\n' "${right_dir}" >&2
        printf '  - %s\n' "${right_files[@]}" >&2
        return 1
    fi
}

ci_assert_workflow_content_match() {
    local left_dir right_dir
    left_dir="${1:?left dir is required}"
    right_dir="${2:?right dir is required}"

    local workflow_file
    while IFS= read -r workflow_file; do
        if ! diff -q "${left_dir}/${workflow_file}" "${right_dir}/${workflow_file}" >/dev/null; then
            ci_log_error "Workflow content mismatch: ${workflow_file}"
            return 1
        fi
    done < <(ci_collect_workflow_files "${left_dir}")
}
