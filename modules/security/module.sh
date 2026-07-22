#!/usr/bin/env bash
# modules/security/module.sh — security hardening module (skeleton).
# shellcheck shell=bash

# Register the security module with the application menu.
# Returns: 0
module_security_init() {
  module_register "security" "Security" "module_security_run"
}

# Module entrypoint — business logic not implemented yet.
# Returns: 0
module_security_run() {
  ui_msgbox "Security" \
    "Security module skeleton loaded. Business logic not implemented yet."
}
