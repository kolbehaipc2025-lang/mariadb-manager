#!/usr/bin/env bash
# core/ui_plain.sh — plain-terminal UI backend helpers.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_UI_PLAIN_LOADED:-}" ]] && return 0
MARIADB_MANAGER_UI_PLAIN_LOADED=1

# Plain-terminal message box.
# Args: $1 = title, $2 = message
# Returns: 0
ui_plain_msgbox() {
  local title="${1:-Info}"
  local message="${2:-}"

  printf '\n%s\n%s\n\n' "$(theme_paint_named COLOR_TITLE "${title}")" "${message}" >&2
  printf 'Press Enter to continue...' >&2
  read -r _ || true
}

# Plain-terminal yes/no prompt.
# Args: $1 = title, $2 = message
# Returns: 0 for yes, 1 for no.
ui_plain_yesno() {
  local title="${1:-Confirm}"
  local message="${2:-Are you sure?}"
  local answer=""

  printf '\n%s\n%s\n' "$(theme_paint_named COLOR_TITLE "${title}")" "${message}" >&2
  printf '%s [y/N]: ' "$(theme_paint_named COLOR_PROMPT "Confirm")" >&2
  read -r answer || return 1
  [[ "${answer}" =~ ^[Yy]$ ]]
}

# Plain-terminal menu implementation.
# Args: $1 = title, $2 = prompt, remaining = tag item pairs
# Returns: echoes selected tag; 1 on cancel.
ui_plain_menu() {
  local title="${1:?title required}"
  local prompt="${2:?prompt required}"
  shift 2
  local -a tags=()
  local -a labels=()
  local choice=""

  ui_plain_menu_parse_items tags labels "$@"
  ui_plain_menu_render "${title}" "${prompt}" tags labels
  read -r choice || return 1
  ui_plain_menu_select choice tags
}

# Parse tag/label pairs into nameref arrays.
# Args: $1 = tags nameref, $2 = labels nameref, remaining = pairs
# Returns: 0
ui_plain_menu_parse_items() {
  local -n _tags_ref="${1:?tags nameref required}"
  local -n _labels_ref="${2:?labels nameref required}"
  shift 2

  _tags_ref=()
  _labels_ref=()
  while (($# >= 2)); do
    _tags_ref+=("$1")
    _labels_ref+=("$2")
    shift 2
  done
}

# Render a plain menu to stderr.
# Args: $1 = title, $2 = prompt, $3 = tags nameref, $4 = labels nameref
# Returns: 0
ui_plain_menu_render() {
  local title="${1:?title required}"
  local prompt="${2:?prompt required}"
  local -n _tags_ref="${3:?tags nameref required}"
  local -n _labels_ref="${4:?labels nameref required}"
  local i=0

  printf '\n%s\n%s\n\n' "$(theme_paint_named COLOR_TITLE "${title}")" "${prompt}" >&2
  for ((i = 0; i < ${#_tags_ref[@]}; i++)); do
    printf '  %2d) %s\n' "$((i + 1))" \
      "$(theme_paint_named COLOR_MENU "${_labels_ref[i]}")" >&2
  done
  printf '  %2d) %s\n' "0" "Cancel" >&2
  printf '\n%s ' "$(theme_paint_named COLOR_PROMPT "Select:")" >&2
}

# Resolve a numeric menu choice to a tag.
# Args: $1 = choice nameref, $2 = tags nameref
# Returns: echoes tag; 1 on cancel/invalid.
ui_plain_menu_select() {
  local -n _choice_ref="${1:?choice nameref required}"
  local -n _tags_ref="${2:?tags nameref required}"

  if [[ "${_choice_ref}" == "0" ]]; then
    return 1
  fi
  if ! [[ "${_choice_ref}" =~ ^[0-9]+$ ]] \
    || ((_choice_ref < 1 || _choice_ref > ${#_tags_ref[@]})); then
    return 1
  fi
  printf '%s\n' "${_tags_ref[_choice_ref - 1]}"
}

# Plain-terminal input prompt.
# Args: $1 = title, $2 = prompt, $3 = default
# Returns: echoes value; 1 on EOF.
ui_plain_input() {
  local title="${1:-Input}"
  local prompt="${2:-Enter value:}"
  local default="${3:-}"
  local value=""

  printf '\n%s\n%s [%s]: ' \
    "$(theme_paint_named COLOR_TITLE "${title}")" \
    "$(theme_paint_named COLOR_PROMPT "${prompt}")" \
    "${default}" >&2
  read -r value || return 1
  printf '%s\n' "${value:-${default}}"
}

# Plain-terminal password prompt (input hidden when supported).
# Args: $1 = title, $2 = prompt
# Returns: echoes value; 1 on EOF.
ui_plain_password() {
  local title="${1:-Password}"
  local prompt="${2:-Enter password:}"
  local value=""

  printf '\n%s\n%s ' \
    "$(theme_paint_named COLOR_TITLE "${title}")" \
    "$(theme_paint_named COLOR_PROMPT "${prompt}")" >&2
  if [[ -t 0 ]]; then
    read -r -s value || return 1
    printf '\n' >&2
  else
    read -r value || return 1
  fi
  printf '%s\n' "${value}"
}
