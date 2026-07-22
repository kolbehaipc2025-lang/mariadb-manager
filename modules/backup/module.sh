#!/usr/bin/env bash
# modules/backup/module.sh — backup module (skeleton).
# shellcheck shell=bash

# Register the backup module with the application menu.
# Returns: 0
module_backup_init() {
  module_register "backup" "Backup" "module_backup_run"
}

# Module entrypoint — business logic not implemented yet.
# Returns: 0
module_backup_run() {
  ui_msgbox "Backup" "Backup module skeleton loaded. Business logic not implemented yet."
}
