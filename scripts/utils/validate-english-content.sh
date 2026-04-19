#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Areas governed by the repository language policy.
INCLUDE_GLOBS=(
    '*.md'
    '.github/**/*.md'
    'ai/**/*.md'
    'docs/**/*.md'
    'security/**/*.md'
    'scripts/**/*.md'
    'scripts/**/*.sh'
)

EXCLUDE_GLOBS=(
    '_temp/**'
    'docs/runbooks/minikube_images/**'
)

ACCENT_REGEX='[áàâãéêíóôõúçÁÀÂÃÉÊÍÓÔÕÚÇ]'
PORTUGUESE_WORDS_REGEX='\b(instala[cç][aã]o|reposit[oó]rio|usu[aá]rio|seguran[cç]a|aten[cç][aã]o|objetivo|escopo|restri[cç][oõ]es|valida[cç][aã]o|configura[cç][aã]o|execu[cç][aã]o|atualiza[cç][aã]o|pre-?requisitos|uso\s+r[aá]pido|op[cç][oõ]es\s+principais|resultado\s+esperado|sa[ií]da)\b'

tmp_file="$(mktemp)"
trap 'rm -f "${tmp_file}"' EXIT

build_glob_args() {
    local glob

    for glob in "${INCLUDE_GLOBS[@]}"; do
        printf -- '-g\n%s\n' "${glob}"
    done

    for glob in "${EXCLUDE_GLOBS[@]}"; do
        printf -- '-g\n!%s\n' "${glob}"
    done
}

mapfile -t glob_args < <(build_glob_args)

cd "${ROOT_DIR}"

{
    rg --line-number --ignore-case --color never "${ACCENT_REGEX}" "${glob_args[@]}" || true
    rg --line-number --ignore-case --color never "${PORTUGUESE_WORDS_REGEX}" "${glob_args[@]}" || true
} | sort -u > "${tmp_file}"

if [[ -s "${tmp_file}" ]]; then
    printf 'Non-English content detected in language-governed areas:\n'
    cat "${tmp_file}"
    printf '\nPlease translate these entries to English or refine validation exclusions if intentional.\n'
    exit 1
fi

printf 'English content validation passed.\n'
