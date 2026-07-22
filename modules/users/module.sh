#!/usr/bin/env bash
# modules/users/module.sh — user management module (skeleton).
# shellcheck shell=bash

# Register the users module with the application menu.
# Returns: 0
module_users_init() {
  module_register "users" "Users" "module_users_run"
}

# Module entrypoint — business logic not implemented yet.
# Database access (later): dispatcher_driver_* only — never driver_*.
# Returns: 0
module_users_run() {
  ui_msgbox "Users" "Users module skeleton loaded. Business logic not implemented yet."
}
