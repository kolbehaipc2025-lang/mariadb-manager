#!/usr/bin/env bash
# modules/plugins/module.sh — plugin management module (skeleton).
# shellcheck shell=bash

# Register the plugins module with the application menu.
# Returns: 0
module_plugins_init() {
  module_register "plugins" "Plugins" "module_plugins_run"
}

# Module entrypoint — lists loaded plugins; no business logic yet.
# Returns: 0
module_plugins_run() {
  local list
  local message

  list="$(plugin_loader_list)"
  if [[ -z "${list}" ]]; then
    message="No plugins loaded."
  else
    message="Loaded plugins:${list:+$'\n'}${list}"
  fi
  ui_msgbox "Plugins" "${message}"
}
