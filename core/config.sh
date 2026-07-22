#!/usr/bin/env bash
# core/config.sh — dynamic configuration loader and accessors.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_CONFIG_LOADED:-}" ]] && return 0
MARIADB_MANAGER_CONFIG_LOADED=1

MM_CONFIG_LOADED=0
MM_CONFIG_MAIN=""
MM_CONFIG_LOCAL=""

# Load a single config file if it exists.
# Args: $1 = absolute path to config file
# Returns: 0 when loaded or missing.
config_source_file() {
  local file="${1:?config file required}"

  if [[ ! -f "${file}" ]]; then
    return 0
  fi
  # shellcheck disable=SC1090
  source "${file}"
}

# Load main, local, and environment configuration.
# Returns: 0 on success.
config_load() {
  MM_CONFIG_MAIN="$(mm_resolve_path "config/config.conf")"
  MM_CONFIG_LOCAL="$(mm_resolve_path "config/config.local.conf")"
  if [[ ! -f "${MM_CONFIG_MAIN}" ]]; then
    error_raise "${MM_ERR_CONFIG}" "Missing config: ${MM_CONFIG_MAIN}" || return $?
  fi
  config_source_file "${MM_CONFIG_MAIN}"
  config_source_file "${MM_CONFIG_LOCAL}"
  config_apply_defaults
  config_apply_env_overrides
  config_validate || return $?
  MM_CONFIG_LOADED=1
}

# Reload configuration at runtime.
# Returns: 0 on success.
config_reload() {
  log_info "Reloading configuration"
  config_load || return $?
  log_info "Configuration reloaded"
}

# Apply defaults for any unset required keys.
# Returns: 0
config_apply_defaults() {
  APP_NAME="${APP_NAME:-MariaDB Manager}"
  APP_VERSION="${APP_VERSION:-0.3.0}"
  DRIVER_NAME="${DRIVER_NAME:-mariadb}"
  DRIVER_DIR="${DRIVER_DIR:-drivers}"
  LOG_FILE="${LOG_FILE:-logs/manager.log}"
  LOG_LEVEL="${LOG_LEVEL:-INFO}"
  LOG_MAX_BYTES="${LOG_MAX_BYTES:-10485760}"
  LOG_KEEP_FILES="${LOG_KEEP_FILES:-5}"
  LOG_TO_CONSOLE="${LOG_TO_CONSOLE:-auto}"
  THEME_NAME="${THEME_NAME:-default}"
  UI_PREFERRED="${UI_PREFERRED:-auto}"
  UI_TIMEOUT="${UI_TIMEOUT:-0}"
  PLUGIN_DIR="${PLUGIN_DIR:-plugins}"
  PLUGIN_AUTOLOAD="${PLUGIN_AUTOLOAD:-yes}"
  PLUGIN_DISABLE="${PLUGIN_DISABLE:-}"
  MODULE_DIR="${MODULE_DIR:-modules}"
  THEME_DIR="${THEME_DIR:-themes}"
  CONFIRM_DANGEROUS="${CONFIRM_DANGEROUS:-yes}"
  MASK_PASSWORDS="${MASK_PASSWORDS:-yes}"
  DEBUG="${DEBUG:-no}"
  NO_COLOR="${NO_COLOR:-}"
}

# Apply MDBM_* environment overrides after file load.
# Returns: 0
config_apply_env_overrides() {
  if [[ -n "${MDBM_LOG_LEVEL:-}" ]]; then
    LOG_LEVEL="${MDBM_LOG_LEVEL}"
  fi
  if [[ -n "${MDBM_UI_PREFERRED:-}" ]]; then
    UI_PREFERRED="${MDBM_UI_PREFERRED}"
  fi
  if [[ -n "${MDBM_THEME_NAME:-}" ]]; then
    THEME_NAME="${MDBM_THEME_NAME}"
  fi
  if [[ -n "${MDBM_DRIVER_NAME:-}" ]]; then
    DRIVER_NAME="${MDBM_DRIVER_NAME}"
  fi
  if [[ -n "${MDBM_DEBUG:-}" ]]; then
    DEBUG="${MDBM_DEBUG}"
  fi
  if [[ -n "${MDBM_PLUGIN_AUTOLOAD:-}" ]]; then
    PLUGIN_AUTOLOAD="${MDBM_PLUGIN_AUTOLOAD}"
  fi
  if [[ -n "${MDBM_NO_COLOR:-}" ]]; then
    NO_COLOR="${MDBM_NO_COLOR}"
  fi
  return 0
}

# Validate configuration values after load.
# Returns: 0 when valid.
config_validate() {
  config_validate_enum LOG_LEVEL "${LOG_LEVEL}" DEBUG INFO WARN ERROR || return $?
  config_validate_enum UI_PREFERRED "${UI_PREFERRED}" auto dialog whiptail plain || return $?
  config_validate_enum CONFIRM_DANGEROUS "${CONFIRM_DANGEROUS}" yes no || return $?
  config_validate_enum MASK_PASSWORDS "${MASK_PASSWORDS}" yes no || return $?
  config_validate_enum DEBUG "${DEBUG}" yes no || return $?
  config_validate_enum PLUGIN_AUTOLOAD "${PLUGIN_AUTOLOAD}" yes no || return $?
  config_validate_enum DRIVER_NAME "${DRIVER_NAME}" mariadb || return $?
  config_validate_enum LOG_TO_CONSOLE "${LOG_TO_CONSOLE}" auto always never || return $?
}

# Validate an enum-style config key.
# Args: $1 = key, $2 = value, remaining = allowed
# Returns: 0 if allowed.
config_validate_enum() {
  local key="${1:?key required}"
  local value="${2:-}"
  shift 2
  local allowed

  for allowed in "$@"; do
    if [[ "${value}" == "${allowed}" ]]; then
      return 0
    fi
  done
  error_raise "${MM_ERR_CONFIG}" "Invalid ${key}: ${value}" || return $?
}

# Read a config value by name.
# Args: $1 = variable name
# Returns: echoes value; 1 if unset.
config_get() {
  local key="${1:?config key required}"

  if [[ -z "${!key+x}" ]]; then
    return 1
  fi
  printf '%s\n' "${!key}"
}

# Require a config key to be set and non-empty.
# Args: $1 = variable name
# Returns: echoes value; non-zero if missing.
config_require() {
  local key="${1:?config key required}"
  local value="${!key:-}"

  if [[ -z "${value}" ]]; then
    error_raise "${MM_ERR_CONFIG}" "Required config missing: ${key}" || return $?
  fi
  printf '%s\n' "${value}"
}

# Set a config key at runtime (in-memory only).
# Args: $1 = key, $2 = value
# Returns: 0
config_set() {
  local key="${1:?config key required}"
  local value="${2:-}"

  printf -v "${key}" '%s' "${value}"
  log_debug "Config set: ${key}"
}

# Return whether configuration has been loaded.
# Returns: 0 if loaded.
config_is_loaded() {
  ((MM_CONFIG_LOADED == 1))
}
