#!/usr/bin/env bash
# core/plugin_loader.sh — discover, filter, and autoload plugins.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_PLUGIN_LOADER_LOADED:-}" ]] && return 0
MARIADB_MANAGER_PLUGIN_LOADER_LOADED=1

declare -ga MM_LOADED_PLUGINS=()

# Initialize plugin subsystem and optionally autoload plugins.
# Returns: 0
plugin_loader_init() {
  local plugin_dir

  log_set_component "plugins"
  plugin_dir="$(mm_resolve_path "${PLUGIN_DIR:-plugins}")"
  mm_ensure_dir "${plugin_dir}" 0750
  if mm_is_yes "${PLUGIN_AUTOLOAD:-yes}"; then
    plugin_loader_autoload "${plugin_dir}"
  else
    log_info "Plugin autoload disabled"
  fi
  log_set_component "core"
}

# Autoload all eligible *.plugin.sh files in a directory.
# Args: $1 = plugin directory
# Returns: 0 (individual failures are logged, not fatal).
plugin_loader_autoload() {
  local plugin_dir="${1:?plugin directory required}"
  local plugin_file
  local count=0

  shopt -s nullglob
  for plugin_file in "${plugin_dir}"/*.plugin.sh; do
    if plugin_loader_load "${plugin_file}"; then
      count=$((count + 1))
    fi
  done
  shopt -u nullglob
  log_info "Plugins loaded: ${count}"
}

# Return whether a plugin name is disabled via PLUGIN_DISABLE.
# Args: $1 = plugin name
# Returns: 0 if disabled.
plugin_loader_is_disabled() {
  local want="${1:?plugin name required}"
  local name

  while IFS= read -r name; do
    if [[ "${name}" == "${want}" ]]; then
      return 0
    fi
  done < <(mm_csv_to_lines "${PLUGIN_DISABLE:-}")
  return 1
}

# Validate a plugin name (snake_case).
# Args: $1 = plugin name
# Returns: 0 if valid.
plugin_loader_validate_name() {
  local name="${1:?plugin name required}"

  if [[ ! "${name}" =~ ^[a-z][a-z0-9_]*$ ]]; then
    error_raise "${MM_ERR_PLUGIN}" "Invalid plugin name: ${name}" || return $?
  fi
}

# Load a single plugin file and call its register hook when present.
# Args: $1 = absolute plugin path
# Returns: 0 on success, 1 on failure.
plugin_loader_load() {
  local plugin_file="${1:?plugin file required}"
  local plugin_name

  if [[ ! -f "${plugin_file}" || ! -r "${plugin_file}" ]]; then
    error_warn "Plugin missing or unreadable: ${plugin_file}"
    return 1
  fi
  plugin_name="$(basename "${plugin_file}" .plugin.sh)"
  if ! plugin_loader_validate_name "${plugin_name}"; then
    return 1
  fi
  if plugin_loader_is_disabled "${plugin_name}"; then
    log_info "Plugin disabled: ${plugin_name}"
    return 1
  fi
  if plugin_loader_is_loaded "${plugin_name}"; then
    log_warn "Plugin already loaded: ${plugin_name}"
    return 0
  fi
  plugin_loader_source "${plugin_file}" "${plugin_name}"
}

# Source plugin and invoke register hook.
# Args: $1 = file, $2 = name
# Returns: 0 on success.
plugin_loader_source() {
  local plugin_file="${1:?plugin file required}"
  local plugin_name="${2:?plugin name required}"

  log_debug "Loading plugin: ${plugin_name}"
  # shellcheck disable=SC1090
  if ! source "${plugin_file}"; then
    error_warn "Failed to source plugin: ${plugin_name}"
    return 1
  fi
  if declare -F "plugin_${plugin_name}_register" >/dev/null 2>&1; then
    "plugin_${plugin_name}_register" || {
      error_warn "Plugin register failed: ${plugin_name}"
      return 1
    }
  fi
  MM_LOADED_PLUGINS+=("${plugin_name}")
  log_info "Plugin registered: ${plugin_name}"
}

# List names of loaded plugins.
# Returns: echoes one plugin name per line.
plugin_loader_list() {
  local name

  for name in "${MM_LOADED_PLUGINS[@]:-}"; do
    if [[ -n "${name}" ]]; then
      printf '%s\n' "${name}"
    fi
  done
}

# Return whether a plugin is loaded.
# Args: $1 = plugin name
# Returns: 0 if loaded.
plugin_loader_is_loaded() {
  local want="${1:?plugin name required}"
  local name

  for name in "${MM_LOADED_PLUGINS[@]:-}"; do
    if [[ "${name}" == "${want}" ]]; then
      return 0
    fi
  done
  return 1
}

# Count loaded plugins.
# Returns: echoes integer count.
plugin_loader_count() {
  printf '%s\n' "${#MM_LOADED_PLUGINS[@]}"
}
