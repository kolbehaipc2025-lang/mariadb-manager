#!/usr/bin/env bash
# modules/theme/module.sh — theme selection module (skeleton).
# shellcheck shell=bash

# Register the theme module with the application menu.
# Returns: 0
module_theme_init() {
  module_register "theme" "Theme" "module_theme_run"
}

# Module entrypoint — shows current theme; switching logic later.
# Returns: 0
module_theme_run() {
  local themes
  local message

  themes="$(theme_list | tr '\n' ' ')"
  message="Current theme: ${THEME_NAME:-default}"$'\n'"Available: ${themes}"$'\n\n'"Theme switching UI not implemented yet."
  ui_msgbox "Theme" "${message}"
}
