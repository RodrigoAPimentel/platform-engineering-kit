#!/usr/bin/env bash

START_PROCESS="${START_PROCESS:-$(date +%s)}"

if [[ -t 1 ]]; then
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
    date +"%Y-%m-%d %H:%M:%S"
}

_log() {
    local color="$1"
    local level="$2"
    shift 2
    printf "%b[%s] [%s] %s%b\n" "$color" "$(_timestamp)" "$level" "$*" "$COLOR_OFF"
}

_step() {
    _log "$COLOR_INFO" "STEP" "$*"
}

_section() {
    printf "\n%b========== %s ==========%b\n" "$COLOR_SECTION" "$*" "$COLOR_OFF"
}

_section_end() {
    printf "%b=================================%b\n" "$COLOR_SECTION" "$COLOR_OFF"
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
    printf "%b----- %s -----%b\n%s\n%b----- %s -----%b\n" "$COLOR_SECTION" "$header" "$COLOR_OFF" "$content" "$COLOR_SECTION" "$footer" "$COLOR_OFF"
}

_step_result() {
    printf "%s\n" "$*"
}

_step_result_success() {
    _log "$COLOR_OK" "OK" "$*"
}

_step_result_failed() {
    _log "$COLOR_ERR" "ERROR" "$*"
}

_step_result_suggestion() {
    _log "$COLOR_WARN" "WARN" "$*"
}

_finish_information() {
    local end_process time_spent hours minutes seconds
    end_process="$(date +%s)"
    time_spent=$((end_process - START_PROCESS))
    hours=$((time_spent / 3600))
    minutes=$(((time_spent % 3600) / 60))
    seconds=$((time_spent % 60))

    printf "\n%bRun summary%b\n" "$COLOR_SECTION" "$COLOR_OFF"
    printf "- Start: %s\n" "$(date -d "@${START_PROCESS}" "+%Y-%m-%d %H:%M:%S")"
    printf "- End:   %s\n" "$(date -d "@${end_process}" "+%Y-%m-%d %H:%M:%S")"
    printf "- Took:  %02d:%02d:%02d\n" "$hours" "$minutes" "$seconds"
}