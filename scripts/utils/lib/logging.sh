#!/usr/bin/env bash

START_PROCESS="${START_PROCESS:-$(date +%s)}"

# Log level threshold. Options: DEBUG, INFO, WARN, ERROR
LOG_LEVEL="${LOG_LEVEL:-INFO}"

_log_level_value() {
    case "$1" in
        DEBUG) echo 10 ;;
        INFO) echo 20 ;;
        WARN) echo 30 ;;
        ERROR) echo 40 ;;
        *) echo 20 ;;
    esac
}

_log_should_emit() {
    local message_level="${1:-INFO}"
    [[ "$(_log_level_value "${message_level}")" -ge "$(_log_level_value "${LOG_LEVEL}")" ]]
}

if [[ -t 1 && "${NO_COLOR:-}" != "1" ]]; then
    COLOR_OFF='\033[0m'
    COLOR_INFO='\033[1;34m'
    COLOR_OK='\033[1;32m'
    COLOR_WARN='\033[1;33m'
    COLOR_ERR='\033[1;31m'
    COLOR_SECTION='\033[1;36m'
else
    COLOR_OFF=''
    COLOR_INFO=''
    COLOR_OK=''
    COLOR_WARN=''
    COLOR_ERR=''
    COLOR_SECTION=''
fi

_timestamp() {
    date +"%Y-%m-%dT%H:%M:%S%z"
}

_log() {
    local color="$1"
    local level="$2"
    shift 2
    _log_should_emit "$level" || return 0

    local stream=1
    if [[ "$level" == "WARN" || "$level" == "ERROR" ]]; then
        stream=2
    fi

    printf -- "%b[%s] [%s] %s%b\n" "$color" "$(_timestamp)" "$level" "$*" "$COLOR_OFF" >&${stream}
}

_debug() {
    _log "$COLOR_SECTION" "DEBUG" "$*"
}

_info() {
    _log "$COLOR_INFO" "INFO" "$*"
}

_warn() {
    _log "$COLOR_WARN" "WARN" "$*"
}

_error() {
    _log "$COLOR_ERR" "ERROR" "$*"
}

_step() {
    _info "$*"
}

_section() {
    local title="${*:-SECTION}"
    printf -- "\n%b========== %s ==========%b\n" "$COLOR_SECTION" "$title" "$COLOR_OFF"
}

_section_end() {
    printf -- "%b=================================%b\n" "$COLOR_SECTION" "$COLOR_OFF"
}

_script_start() {
    _section "$*"
}

_script_finish() {
    _section "$*"
}

_cat_file() {
    local header="$1"
    local content="$2"
    local footer="$3"
    printf -- "%b----- %s -----%b\n%s\n%b----- %s -----%b\n" "$COLOR_SECTION" "$header" "$COLOR_OFF" "$content" "$COLOR_SECTION" "$footer" "$COLOR_OFF"
}

_step_result() {
    printf -- "%s\n" "$*"
}

_step_result_success() {
    _log "$COLOR_OK" "INFO" "$*"
}

_step_result_failed() {
    _error "$*"
}

_step_result_suggestion() {
    _warn "$*"
}

_log_kv() {
    local key="$1"
    local value="$2"
    _info "${key}=${value}"
}

_finish_information() {
    local end_process time_spent hours minutes seconds
    end_process="$(date +%s)"
    time_spent=$((end_process - START_PROCESS))
    hours=$((time_spent / 3600))
    minutes=$(((time_spent % 3600) / 60))
    seconds=$((time_spent % 60))

    _section "Run Summary"
    _log_kv "start" "$(date -d "@${START_PROCESS}" "+%Y-%m-%d %H:%M:%S")"
    _log_kv "end" "$(date -d "@${end_process}" "+%Y-%m-%d %H:%M:%S")"
    _log_kv "elapsed" "$(printf -- "%02d:%02d:%02d" "$hours" "$minutes" "$seconds")"
}