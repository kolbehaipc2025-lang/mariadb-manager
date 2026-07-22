#!/usr/bin/env bash
# modules/permissions/module.sh — privileges module (skeleton).
# shellcheck shell=bash

# Register the permissions module with the application menu.
# Returns: 0
module_permissions_init() {
  module_register "permissions" "Permissions" "module_permissions_run"
}

# Module entrypoint — business logic not implemented yet.
# Returns: 0
module_permissions_run() {
  ui_msgbox "Permissions" \
    "Permissions module skeleton loaded. Business logic not implemented yet."
}
