#!/usr/bin/env bash
# modules/restore/module.sh — restore module (skeleton).
# shellcheck shell=bash

# Register the restore module with the application menu.
# Returns: 0
module_restore_init() {
  module_register "restore" "Restore" "module_restore_run"
}

# Module entrypoint — business logic not implemented yet.
# Returns: 0
module_restore_run() {
  ui_msgbox "Restore" "Restore module skeleton loaded. Business logic not implemented yet."
}
