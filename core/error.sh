#!/usr/bin/env bash
# core/error.sh — strict mode, traps, and controlled error handling.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_ERROR_LOADED:-}" ]] && return 0
MARIADB_MANAGER_ERROR_LOADED=1

readonly MM_ERR_OK=0
readonly MM_ERR_USAGE=2
readonly MM_ERR_CONFIG=10
readonly MM_ERR_DRIVER=20
readonly MM_ERR_MODULE=30
readonly MM_ERR_VALIDATION=40
readonly MM_ERR_INTERNAL=50
readonly MM_ERR_PLUGIN=60
readonly MM_ERR_UI=70
readonly MM_ERR_THEME=80

MM_LAST_ERROR_CODE=0
MM_LAST_ERROR_MESSAGE=""

# Trap handler for unexpected errors under set -E.
# Args: $1 = line number
# Returns: exits with the failed command status.
error_on_trap() {
  local exit_code=$?
  local line_no="${1:-unknown}"

  MM_LAST_ERROR_CODE="${exit_code}"
  MM_LAST_ERROR_MESSAGE="Unhandled error at line ${line_no}: ${BASH_COMMAND}"
  if declare -F log_error >/dev/null 2>&1; then
    log_error "${MM_LAST_ERROR_MESSAGE} (exit ${exit_code})"
  else
    printf 'ERROR: %s (exit %s)\n' "${MM_LAST_ERROR_MESSAGE}" "${exit_code}" >&2
  fi
  exit "${exit_code}"
}

# Enable strict Bash mode and ERR trap.
# Returns: 0
error_enable_strict_mode() {
  set -Eeuo pipefail
  IFS=$'\n\t'
  trap 'error_on_trap ${LINENO}' ERR
}

# Temporarily disable the ERR trap (for expected failures).
# Returns: 0
error_trap_off() {
  set +e
  trap - ERR
}

# Re-enable strict mode and ERR trap after error_trap_off.
# Returns: 0
error_trap_on() {
  error_enable_strict_mode
}

# Raise a controlled application error and return a code.
# Args: $1 = exit code, $2 = message
# Returns: the provided exit code.
error_raise() {
  local code="${1:?error code required}"
  local message="${2:?error message required}"

  MM_LAST_ERROR_CODE="${code}"
  MM_LAST_ERROR_MESSAGE="${message}"
  if declare -F log_error >/dev/null 2>&1; then
    log_error "${message}"
  else
    printf 'ERROR: %s\n' "${message}" >&2
  fi
  return "${code}"
}

# Exit the process with a controlled error.
# Args: $1 = exit code, $2 = message
# Returns: does not return.
error_exit() {
  local code="${1:?error code required}"
  local message="${2:?error message required}"

  error_raise "${code}" "${message}" || true
  exit "${code}"
}

# Clear the last recorded error state.
# Returns: 0
error_clear() {
  MM_LAST_ERROR_CODE=0
  MM_LAST_ERROR_MESSAGE=""
}

# Print the last error message.
# Returns: echoes message; 1 if none.
error_last_message() {
  if [[ -z "${MM_LAST_ERROR_MESSAGE}" ]]; then
    return 1
  fi
  printf '%s\n' "${MM_LAST_ERROR_MESSAGE}"
}

# Print the last error code.
# Returns: echoes numeric code.
error_last_code() {
  printf '%s\n' "${MM_LAST_ERROR_CODE:-0}"
}

# Warn without failing (non-fatal).
# Args: $1 = message
# Returns: 0
error_warn() {
  local message="${1:?message required}"

  if declare -F log_warn >/dev/null 2>&1; then
    log_warn "${message}"
  else
    printf 'WARN: %s\n' "${message}" >&2
  fi
}
