#!/usr/bin/env bash
# core/dispatcher.sh — menu loop and sole module→driver gateway.
# Modules MUST use dispatcher_driver_* — never call driver_* directly.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_DISPATCHER_LOADED:-}" ]] && return 0
MARIADB_MANAGER_DISPATCHER_LOADED=1

MM_DISPATCH_ONCE=0
MM_DISPATCH_MODULE=""

# Configure single-iteration menu mode.
# Args: $1 = 0|1
# Returns: 0
dispatcher_set_once() {
  MM_DISPATCH_ONCE="${1:-0}"
}

# Echo the module currently being dispatched, if any.
# Returns: echoes module id (may be empty).
dispatcher_current_module() {
  printf '%s\n' "${MM_DISPATCH_MODULE}"
}

# Dispatch to a registered module handler by id.
# Args: $1 = module id
# Returns: handler exit status.
dispatcher_dispatch() {
  local id="${1:?module id required}"
  local handler="${MM_MODULE_HANDLERS[${id}]:-}"
  local status=0

  if [[ -z "${handler}" ]]; then
    error_raise "${MM_ERR_MODULE}" "No handler for module: ${id}" || return $?
  fi
  MM_DISPATCH_MODULE="${id}"
  log_set_component "module:${id}"
  log_info "Opening module: ${id}"
  error_clear
  "${handler}" || status=$?
  log_set_component "core"
  MM_DISPATCH_MODULE=""
  return "${status}"
}

# Build and show the main module menu once.
# Returns: 0 continue, 1 quit/cancel.
dispatcher_show_menu() {
  local choice=""

  module_menu_items
  if ((${#MM_MENU_ITEMS[@]} == 0)); then
    ui_msgbox "Error" "No modules registered."
    return 1
  fi
  if ! choice="$(ui_menu "${APP_NAME}" "Select a module" \
    "${MM_MENU_ITEMS[@]}" "quit" "Quit")"; then
    return 1
  fi
  if [[ "${choice}" == "quit" ]]; then
    return 1
  fi
  dispatcher_dispatch "${choice}" || log_warn "Module returned error: ${choice}"
  return 0
}

# Run the main application menu loop.
# Returns: 0 on normal exit.
dispatcher_run() {
  log_set_component "dispatcher"
  log_info "Dispatcher started"
  log_set_component "core"
  while true; do
    if ! dispatcher_show_menu; then
      break
    fi
    if ((MM_DISPATCH_ONCE == 1)); then
      break
    fi
  done
}

# --- Driver mediation (modules call these only) ---

# Mediated driver ping.
# Returns: driver status.
dispatcher_driver_ping() {
  dispatcher_require_module_context
  log_debug "dispatcher_driver_ping via ${MM_DISPATCH_MODULE}"
  driver_ping
}

# Mediated driver query (stub).
# Args: $@ = query fragments
# Returns: driver status.
dispatcher_driver_query() {
  dispatcher_require_module_context
  log_debug "dispatcher_driver_query via ${MM_DISPATCH_MODULE}"
  driver_query "$@"
}

# Mediated string escape.
# Args: $1 = raw value
# Returns: echoes escaped value.
dispatcher_driver_escape() {
  dispatcher_require_module_context
  driver_escape_string "${1:-}"
}

# Mediated identifier quote.
# Args: $1 = identifier
# Returns: echoes quoted identifier.
dispatcher_driver_quote() {
  dispatcher_require_module_context
  driver_quote_identifier "${1:-}"
}

# Mediated driver status.
# Returns: echoes ready|not_ready
dispatcher_driver_status() {
  driver_status
}

# Mediated driver name.
# Returns: echoes driver name.
dispatcher_driver_name() {
  driver_name
}

# Mediated client availability probe.
# Returns: 0 if client exists.
dispatcher_driver_client_available() {
  dispatcher_require_module_context
  driver_client_available
}

# Ensure a module context is active for privileged driver calls.
# Returns: 0 when inside dispatcher_dispatch.
dispatcher_require_module_context() {
  if [[ -z "${MM_DISPATCH_MODULE}" ]]; then
    error_raise "${MM_ERR_MODULE}" \
      "Driver access denied outside module context" || return $?
  fi
}
