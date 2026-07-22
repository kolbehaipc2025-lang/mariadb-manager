#!/usr/bin/env bash
# core/logger.sh — structured logging with levels, masking, and rotation.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_LOGGER_LOADED:-}" ]] && return 0
MARIADB_MANAGER_LOGGER_LOADED=1

declare -gA MM_LOG_PRIORITY=(
  [DEBUG]=10
  [INFO]=20
  [WARN]=30
  [ERROR]=40
)

MM_LOG_COMPONENT="core"
MM_LOGGER_READY=0

# Initialize logging directory and file.
# Returns: 0 on success.
log_init() {
  local log_path

  log_path="$(mm_resolve_path "${LOG_FILE:-logs/manager.log}")"
  LOG_FILE="${log_path}"
  mm_ensure_dir "$(dirname "${LOG_FILE}")" 0750
  if [[ ! -f "${LOG_FILE}" ]]; then
    : >"${LOG_FILE}"
    chmod 0640 "${LOG_FILE}"
  fi
  MM_LOGGER_READY=1
  log_info "Logger initialized"
}

# Set the active log component tag for subsequent messages.
# Args: $1 = component name
# Returns: 0
log_set_component() {
  MM_LOG_COMPONENT="${1:-core}"
}

# Return whether a level should be emitted for the current LOG_LEVEL.
# Args: $1 = level name
# Returns: 0 if enabled.
log_level_enabled() {
  local level="${1:?level required}"
  local current="${LOG_LEVEL:-INFO}"
  local want have

  want="${MM_LOG_PRIORITY[${level}]:-99}"
  have="${MM_LOG_PRIORITY[${current}]:-20}"
  ((want >= have))
}

# Rotate the log file when it exceeds LOG_MAX_BYTES.
# Returns: 0
log_rotate_if_needed() {
  local max_bytes="${LOG_MAX_BYTES:-10485760}"
  local keep="${LOG_KEEP_FILES:-5}"
  local size=0
  local i

  [[ -f "${LOG_FILE}" ]] || return 0
  size="$(wc -c <"${LOG_FILE}" | tr -d '[:space:]')"
  size="${size:-0}"
  if ((size < max_bytes)); then
    return 0
  fi
  for ((i = keep; i >= 1; i--)); do
    if [[ -f "${LOG_FILE}.${i}" ]]; then
      if ((i == keep)); then
        rm -f "${LOG_FILE}.${i}"
      else
        mv -f "${LOG_FILE}.${i}" "${LOG_FILE}.$((i + 1))"
      fi
    fi
  done
  mv -f "${LOG_FILE}" "${LOG_FILE}.1"
  : >"${LOG_FILE}"
  chmod 0640 "${LOG_FILE}"
}

# Decide whether console logging is enabled.
# Returns: 0 if console output should be used.
log_console_enabled() {
  case "${LOG_TO_CONSOLE:-auto}" in
    always) return 0 ;;
    never) return 1 ;;
    *)
      [[ -t 2 ]] || [[ "${DEBUG:-no}" == "yes" ]]
      ;;
  esac
}

# Write one log line to file and optionally stderr.
# Args: $1 = level, $2 = message
# Returns: 0
log_write() {
  local level="${1:?level required}"
  local message="${2:-}"
  local stamp safe_message line

  if ! log_level_enabled "${level}"; then
    return 0
  fi
  if ((MM_LOGGER_READY != 1)); then
    printf '%s [%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "${level}" "${message}" >&2
    return 0
  fi
  log_rotate_if_needed
  stamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  if [[ "${MASK_PASSWORDS:-yes}" == "yes" ]]; then
    safe_message="$(mm_mask_secrets "${message}")"
  else
    safe_message="${message}"
  fi
  line="$(printf '%s [%s] [%s] %s' "${stamp}" "${level}" "${MM_LOG_COMPONENT}" "${safe_message}")"
  printf '%s\n' "${line}" >>"${LOG_FILE}"
  if log_console_enabled; then
    log_print_console "${level}" "${safe_message}"
  fi
}

# Print a colored log line to stderr using the theme engine.
# Args: $1 = level, $2 = message
# Returns: 0
log_print_console() {
  local level="${1:?level required}"
  local message="${2:-}"
  local color_name="COLOR_LOG_${level}"
  local color_code="${!color_name:-}"
  local prefix

  prefix="$(printf '[%s][%s]' "${level}" "${MM_LOG_COMPONENT}")"
  if declare -F theme_paint >/dev/null 2>&1 && [[ -n "${color_code}" ]]; then
    printf '%s %s\n' "$(theme_paint "${color_code}" "${prefix}")" "${message}" >&2
  else
    printf '%s %s\n' "${prefix}" "${message}" >&2
  fi
}

# Log an INFO message.
# Args: $1 = message
log_info() { log_write "INFO" "${1:-}"; }

# Log a WARN message.
# Args: $1 = message
log_warn() { log_write "WARN" "${1:-}"; }

# Log an ERROR message.
# Args: $1 = message
log_error() { log_write "ERROR" "${1:-}"; }

# Log a DEBUG message.
# Args: $1 = message
log_debug() { log_write "DEBUG" "${1:-}"; }

# Log with an explicit component override for one message.
# Args: $1 = component, $2 = level, $3 = message
# Returns: 0
log_with_component() {
  local component="${1:?component required}"
  local level="${2:?level required}"
  local message="${3:-}"
  local previous="${MM_LOG_COMPONENT}"

  MM_LOG_COMPONENT="${component}"
  log_write "${level}" "${message}"
  MM_LOG_COMPONENT="${previous}"
}
