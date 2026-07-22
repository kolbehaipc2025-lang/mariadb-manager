#!/usr/bin/env bash
# core/driver.sh — database driver loader and generic API facade.
# Modules MUST NOT call these directly. Use dispatcher_driver_* instead.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_DRIVER_LOADED:-}" ]] && return 0
MARIADB_MANAGER_DRIVER_LOADED=1

MM_DRIVER_NAME=""
MM_DRIVER_READY=0
MM_DRIVER_LOADED=0

# Required backend hooks for a valid driver.
readonly -a MM_DRIVER_REQUIRED_HOOKS=(
  driver_backend_setup
  driver_backend_client_available
  driver_backend_ping
  driver_backend_query
  driver_backend_escape_string
  driver_backend_quote_identifier
)

# Initialize and load the configured database driver.
# Returns: 0 on success.
driver_init() {
  log_set_component "driver"
  MM_DRIVER_NAME="${DRIVER_NAME:-mariadb}"
  MM_DRIVER_READY=0
  MM_DRIVER_LOADED=0
  validator_enum "DRIVER_NAME" "${MM_DRIVER_NAME}" "mariadb" || return $?
  driver_load "${MM_DRIVER_NAME}" || return $?
  driver_verify_hooks || return $?
  driver_backend_init || return $?
  MM_DRIVER_LOADED=1
  log_info "Driver ready: ${MM_DRIVER_NAME}"
  log_set_component "core"
}

# Source a driver implementation from DRIVER_DIR.
# Args: $1 = driver name
# Returns: 0 on success.
driver_load() {
  local name="${1:?driver name required}"
  local driver_dir
  local driver_file

  driver_dir="$(mm_resolve_path "${DRIVER_DIR:-drivers}")"
  driver_file="${driver_dir}/${name}.sh"
  if [[ ! -f "${driver_file}" ]]; then
    error_raise "${MM_ERR_DRIVER}" "Driver not found: ${driver_file}" || return $?
  fi
  # shellcheck disable=SC1090
  source "${driver_file}"
  log_debug "Driver sourced: ${name}"
}

# Verify all required backend hooks exist.
# Returns: 0 when complete.
driver_verify_hooks() {
  local hook

  for hook in "${MM_DRIVER_REQUIRED_HOOKS[@]}"; do
    if ! declare -F "${hook}" >/dev/null 2>&1; then
      error_raise "${MM_ERR_DRIVER}" "Driver missing hook: ${hook}" || return $?
    fi
  done
}

# Delegate initialization to the loaded backend.
# Returns: backend status.
driver_backend_init() {
  driver_backend_setup
}

# Probe driver client availability.
# Returns: 0 if client tools exist.
driver_client_available() {
  driver_require_loaded || return $?
  driver_backend_client_available
}

# Connection probe (stub until business logic lands).
# Returns: backend status.
driver_ping() {
  driver_require_loaded || return $?
  if driver_backend_ping; then
    MM_DRIVER_READY=1
    return 0
  fi
  MM_DRIVER_READY=0
  return 1
}

# Execute a query through the active driver (stub).
# Args: $@ = query fragments
# Returns: backend status.
driver_query() {
  driver_require_loaded || return $?
  driver_backend_query "$@"
}

# Escape a string literal via the active driver.
# Args: $1 = raw value
# Returns: echoes escaped value.
driver_escape_string() {
  driver_require_loaded || return $?
  driver_backend_escape_string "${1:-}"
}

# Quote a validated identifier via the active driver.
# Args: $1 = identifier
# Returns: echoes quoted identifier.
driver_quote_identifier() {
  driver_require_loaded || return $?
  validator_identifier "${1:-}" || return $?
  driver_backend_quote_identifier "${1}"
}

# Report driver readiness.
# Returns: echoes ready|not_ready
driver_status() {
  if ((MM_DRIVER_READY == 1)); then
    printf 'ready\n'
  else
    printf 'not_ready\n'
  fi
}

# Return the active driver name.
# Returns: echoes driver name.
driver_name() {
  printf '%s\n' "${MM_DRIVER_NAME:-}"
}

# Ensure a driver has been loaded by driver_init.
# Returns: 0 when loaded.
driver_require_loaded() {
  if ((MM_DRIVER_LOADED != 1)); then
    error_raise "${MM_ERR_DRIVER}" "Driver not loaded" || return $?
  fi
}

# Return whether the driver reports ready.
# Returns: 0 if ready.
driver_is_ready() {
  ((MM_DRIVER_READY == 1))
}
