#!/usr/bin/env bash
# core/ui.sh — UI engine with dialog → whiptail → plain fallbacks.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_UI_LOADED:-}" ]] && return 0
MARIADB_MANAGER_UI_LOADED=1

UI_BACKEND=""

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ui_plain.sh"

# Detect and select the active UI backend.
# Returns: 0 and sets UI_BACKEND.
ui_init() {
  local preferred="${UI_PREFERRED:-auto}"

  case "${preferred}" in
    dialog | whiptail) ui_try_preferred "${preferred}" ;;
    plain) UI_BACKEND="plain" ;;
    auto) ui_select_available ;;
    *)
      error_raise "${MM_ERR_UI}" "Unknown UI_PREFERRED: ${preferred}" || return $?
      ;;
  esac
  log_info "UI backend: ${UI_BACKEND}"
}

# Try a preferred backend, falling back when missing.
# Args: $1 = dialog|whiptail
# Returns: 0
ui_try_preferred() {
  local name="${1:?backend required}"

  if mm_command_exists "${name}"; then
    UI_BACKEND="${name}"
    return 0
  fi
  log_warn "${name} requested but not found; falling back"
  ui_select_available
}

# Choose the best available backend.
# Returns: 0 and sets UI_BACKEND.
ui_select_available() {
  if mm_command_exists dialog; then
    UI_BACKEND="dialog"
  elif mm_command_exists whiptail; then
    UI_BACKEND="whiptail"
  else
    UI_BACKEND="plain"
  fi
}

# Echo the active UI backend name.
# Returns: echoes backend.
ui_backend() {
  printf '%s\n' "${UI_BACKEND:-plain}"
}

# Shared backtitle helper for dialog/whiptail.
# Returns: echoes backtitle string.
ui_backtitle() {
  printf '%s' "${UI_BACKTITLE:-MariaDB Manager}"
}

# Display an informational message box.
# Args: $1 = title, $2 = message
# Returns: 0
ui_msgbox() {
  local title="${1:-Info}"
  local message="${2:-}"

  case "${UI_BACKEND}" in
    dialog)
      dialog --backtitle "$(ui_backtitle)" --title "${title}" \
        --msgbox "${message}" 10 60
      ;;
    whiptail)
      whiptail --backtitle "$(ui_backtitle)" --title "${title}" \
        --msgbox "${message}" 10 60
      ;;
    *) ui_plain_msgbox "${title}" "${message}" ;;
  esac
}

# Ask a yes/no question.
# Args: $1 = title, $2 = message
# Returns: 0 for yes, 1 for no.
ui_yesno() {
  local title="${1:-Confirm}"
  local message="${2:-Are you sure?}"

  case "${UI_BACKEND}" in
    dialog)
      dialog --backtitle "$(ui_backtitle)" --title "${title}" \
        --yesno "${message}" 10 60
      ;;
    whiptail)
      whiptail --backtitle "$(ui_backtitle)" --title "${title}" \
        --yesno "${message}" 10 60
      ;;
    *) ui_plain_yesno "${title}" "${message}" ;;
  esac
}

# Show a menu and capture the selected tag.
# Args: $1 = title, $2 = prompt, remaining = tag item pairs
# Returns: echoes selected tag; exit 0 on ok, 1 on cancel.
ui_menu() {
  local title="${1:?title required}"
  local prompt="${2:?prompt required}"
  shift 2
  local selected=""

  case "${UI_BACKEND}" in
    dialog)
      selected="$(dialog --backtitle "$(ui_backtitle)" --title "${title}" \
        --menu "${prompt}" 20 70 12 "$@" 3>&1 1>&2 2>&3)" || return 1
      ;;
    whiptail)
      selected="$(whiptail --backtitle "$(ui_backtitle)" --title "${title}" \
        --menu "${prompt}" 20 70 12 "$@" 3>&1 1>&2 2>&3)" || return 1
      ;;
    *)
      selected="$(ui_plain_menu "${title}" "${prompt}" "$@")" || return 1
      ;;
  esac
  printf '%s\n' "${selected}"
}

# Read a line of input from the user.
# Args: $1 = title, $2 = prompt, $3 = optional default
# Returns: echoes input; 1 on cancel.
ui_input() {
  local title="${1:-Input}"
  local prompt="${2:-Enter value:}"
  local default="${3:-}"
  local value=""

  case "${UI_BACKEND}" in
    dialog)
      value="$(dialog --backtitle "$(ui_backtitle)" --title "${title}" \
        --inputbox "${prompt}" 10 60 "${default}" 3>&1 1>&2 2>&3)" || return 1
      ;;
    whiptail)
      value="$(whiptail --backtitle "$(ui_backtitle)" --title "${title}" \
        --inputbox "${prompt}" 10 60 "${default}" 3>&1 1>&2 2>&3)" || return 1
      ;;
    *) value="$(ui_plain_input "${title}" "${prompt}" "${default}")" || return 1 ;;
  esac
  printf '%s\n' "${value}"
}

# Read a password (masked where supported).
# Args: $1 = title, $2 = prompt
# Returns: echoes password; 1 on cancel.
ui_password() {
  local title="${1:-Password}"
  local prompt="${2:-Enter password:}"
  local value=""

  case "${UI_BACKEND}" in
    dialog)
      value="$(dialog --backtitle "$(ui_backtitle)" --title "${title}" \
        --insecure --passwordbox "${prompt}" 10 60 3>&1 1>&2 2>&3)" || return 1
      ;;
    whiptail)
      value="$(whiptail --backtitle "$(ui_backtitle)" --title "${title}" \
        --passwordbox "${prompt}" 10 60 3>&1 1>&2 2>&3)" || return 1
      ;;
    *) value="$(ui_plain_password "${title}" "${prompt}")" || return 1 ;;
  esac
  printf '%s\n' "${value}"
}

# Re-initialize UI after config changes.
# Returns: 0
ui_reload() {
  ui_init
}
