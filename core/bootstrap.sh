#!/usr/bin/env bash
# core/bootstrap.sh — phased Core Engine initialization.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_BOOTSTRAP_LOADED:-}" ]] && return 0
MARIADB_MANAGER_BOOTSTRAP_LOADED=1

MM_BOOTSTRAPPED=0

# Resolve repository / install root from this file.
# Returns: sets MM_ROOT.
bootstrap_resolve_root() {
  local source_path="${BASH_SOURCE[0]}"
  local core_dir

  core_dir="$(cd "$(dirname "${source_path}")" && pwd)"
  MM_ROOT="$(cd "${core_dir}/.." && pwd)"
}

# Source Core libraries in dependency order.
# Returns: 0 on success.
bootstrap_source_core() {
  local lib

  for lib in \
    common.sh error.sh helpers.sh version.sh config.sh logger.sh \
    validator.sh theme.sh ui.sh driver.sh module_loader.sh \
    plugin_loader.sh dispatcher.sh; do
    # shellcheck disable=SC1090
    source "${MM_ROOT}/core/${lib}"
  done
}

# Prepare runtime directories used by the application.
# Returns: 0
bootstrap_prepare_runtime() {
  mm_ensure_dir "$(mm_resolve_path "${LOG_DIR:-logs}")" 0750
  mm_ensure_dir "$(mm_resolve_path "${TMP_DIR:-tmp}")" 0750
  mm_ensure_dir "$(mm_resolve_path "${BACKUP_DIR:-backups}")" 0750
  mm_ensure_dir "$(mm_resolve_path "${PLUGIN_DIR:-plugins}")" 0750
  mm_ensure_dir "$(mm_resolve_path "${DRIVER_DIR:-drivers}")" 0750
  mm_ensure_dir "$(mm_resolve_path "${THEME_DIR:-themes}")" 0750
}

# Load foundation libraries and enable strict mode.
# Returns: 0
bootstrap_load_foundation() {
  # shellcheck disable=SC1091
  source "${MM_ROOT}/core/common.sh"
  # shellcheck disable=SC1091
  source "${MM_ROOT}/core/error.sh"
  error_enable_strict_mode
  bootstrap_source_core
}

# Load and validate configuration, prepare runtime dirs.
# Returns: 0 on success.
bootstrap_load_config() {
  config_load || error_exit "${MM_ERR_CONFIG}" "Configuration load failed"
  bootstrap_prepare_runtime
}

# Start core services: logger, theme, UI, driver.
# Returns: 0 on success.
bootstrap_start_services() {
  log_init
  log_set_component "bootstrap"
  theme_load "${THEME_NAME:-default}" \
    || error_exit "${MM_ERR_THEME}" "Theme load failed"
  ui_init || error_exit "${MM_ERR_UI}" "UI init failed"
  driver_init || error_exit "${MM_ERR_DRIVER}" "Driver init failed"
}

# Load modules and plugins.
# Returns: 0 on success.
bootstrap_load_extensions() {
  module_loader_init || error_exit "${MM_ERR_MODULE}" "Module load failed"
  plugin_loader_init
}

# Full application bootstrap sequence.
# Returns: 0 on success.
bootstrap_init() {
  bootstrap_resolve_root
  bootstrap_load_foundation
  bootstrap_load_config
  bootstrap_start_services
  bootstrap_load_extensions
  MM_BOOTSTRAPPED=1
  log_info "$(version_string) started (ui=$(ui_backend) driver=$(driver_name))"
  log_set_component "core"
}

# Report whether Core has completed bootstrap.
# Returns: 0 if bootstrapped.
bootstrap_is_ready() {
  ((MM_BOOTSTRAPPED == 1))
}

# Emit a short health summary to the log.
# Returns: 0
bootstrap_health() {
  log_info "health: bootstrapped=${MM_BOOTSTRAPPED} ui=$(ui_backend) driver=$(driver_status) modules=${#MM_LOADED_MODULES[@]} plugins=$(plugin_loader_count)"
}

# Graceful shutdown hook.
# Returns: 0
bootstrap_shutdown() {
  if declare -F log_info >/dev/null 2>&1; then
    log_set_component "bootstrap"
    log_info "MariaDB Manager shutting down"
    log_set_component "core"
  fi
  MM_BOOTSTRAPPED=0
}
