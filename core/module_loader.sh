#!/usr/bin/env bash
# core/module_loader.sh — discover and load module packages.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_MODULE_LOADER_LOADED:-}" ]] && return 0
MARIADB_MANAGER_MODULE_LOADER_LOADED=1

declare -ga MM_LOADED_MODULES=()
declare -gA MM_MODULE_LABELS=()
declare -gA MM_MODULE_HANDLERS=()

# Register a module for the main menu.
# Args: $1 = id, $2 = label, $3 = handler function name
# Returns: 0
module_register() {
  local id="${1:?module id required}"
  local label="${2:?module label required}"
  local handler="${3:?module handler required}"

  if ! declare -F "${handler}" >/dev/null 2>&1; then
    error_raise "${MM_ERR_MODULE}" "Module handler missing: ${handler}" || return $?
  fi
  MM_MODULE_LABELS["${id}"]="${label}"
  MM_MODULE_HANDLERS["${id}"]="${handler}"
  log_debug "Module registered: ${id}"
}

# Load all module packages from MODULE_DIR.
# Returns: 0
module_loader_init() {
  local module_dir
  local module_path
  local count=0

  module_dir="$(mm_resolve_path "${MODULE_DIR:-modules}")"
  if [[ ! -d "${module_dir}" ]]; then
    error_raise "${MM_ERR_MODULE}" "Module directory missing: ${module_dir}" || return $?
  fi
  shopt -s nullglob
  for module_path in "${module_dir}"/*/module.sh; do
    if module_loader_load "${module_path}"; then
      count=$((count + 1))
    fi
  done
  shopt -u nullglob
  log_info "Modules loaded: ${count}"
}

# Source one module package and invoke its init hook.
# Args: $1 = path to module.sh
# Returns: 0 on success, 1 on failure.
module_loader_load() {
  local module_file="${1:?module file required}"
  local module_name
  local init_fn

  module_name="$(basename "$(dirname "${module_file}")")"
  log_debug "Loading module: ${module_name}"
  # shellcheck disable=SC1090
  if ! source "${module_file}"; then
    error_raise "${MM_ERR_MODULE}" "Failed to source module: ${module_name}" || return $?
  fi
  init_fn="module_${module_name}_init"
  if declare -F "${init_fn}" >/dev/null 2>&1; then
    "${init_fn}"
  fi
  MM_LOADED_MODULES+=("${module_name}")
  log_info "Module ready: ${module_name}"
}

# Build menu item pairs from registered modules.
# Returns: fills global MM_MENU_ITEMS array.
module_menu_items() {
  local id

  MM_MENU_ITEMS=()
  for id in "${MM_LOADED_MODULES[@]:-}"; do
    if [[ -n "${MM_MODULE_LABELS[${id}]:-}" ]]; then
      MM_MENU_ITEMS+=("${id}" "${MM_MODULE_LABELS[${id}]}")
    fi
  done
}
