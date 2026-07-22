#!/usr/bin/env bash
# core/theme.sh — theme engine; all colors come from theme files.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_THEME_LOADED:-}" ]] && return 0
MARIADB_MANAGER_THEME_LOADED=1

MM_THEME_LOADED=0

# Load a theme file by name from THEME_DIR.
# Args: $1 = theme name (without .conf)
# Returns: 0 on success, 1 on failure.
theme_load() {
  local name="${1:-${THEME_NAME:-default}}"
  local theme_dir
  local theme_file

  if [[ ! "${name}" =~ ^[A-Za-z0-9_-]+$ ]]; then
    error_raise "${MM_ERR_THEME}" "Invalid theme name: ${name}" || return $?
  fi
  theme_dir="$(mm_resolve_path "${THEME_DIR:-themes}")"
  theme_file="${theme_dir}/${name}.conf"
  if [[ ! -f "${theme_file}" ]]; then
    error_raise "${MM_ERR_THEME}" "Theme not found: ${theme_file}" || return $?
  fi
  # shellcheck disable=SC1090
  source "${theme_file}"
  THEME_NAME="${name}"
  theme_apply_fallbacks
  MM_THEME_LOADED=1
  log_info "Theme loaded: ${THEME_NAME}"
}

# Reload the active theme from disk.
# Returns: 0 on success.
theme_reload() {
  theme_load "${THEME_NAME:-default}"
}

# Ensure required color keys exist after sourcing a theme.
# Returns: 0
theme_apply_fallbacks() {
  COLOR_RESET="${COLOR_RESET:-0}"
  COLOR_FG="${COLOR_FG:-7}"
  COLOR_BG="${COLOR_BG:-0}"
  COLOR_PRIMARY="${COLOR_PRIMARY:-4}"
  COLOR_SUCCESS="${COLOR_SUCCESS:-2}"
  COLOR_WARN="${COLOR_WARN:-3}"
  COLOR_ERROR="${COLOR_ERROR:-1}"
  COLOR_INFO="${COLOR_INFO:-4}"
  COLOR_DEBUG="${COLOR_DEBUG:-5}"
  COLOR_MUTED="${COLOR_MUTED:-8}"
  COLOR_TITLE="${COLOR_TITLE:-14}"
  COLOR_MENU="${COLOR_MENU:-7}"
  COLOR_PROMPT="${COLOR_PROMPT:-6}"
  COLOR_LOG_INFO="${COLOR_LOG_INFO:-${COLOR_INFO}}"
  COLOR_LOG_WARN="${COLOR_LOG_WARN:-${COLOR_WARN}}"
  COLOR_LOG_ERROR="${COLOR_LOG_ERROR:-${COLOR_ERROR}}"
  COLOR_LOG_DEBUG="${COLOR_LOG_DEBUG:-${COLOR_DEBUG}}"
}

# Return whether ANSI colors should be emitted.
# Returns: 0 if colors enabled.
theme_color_enabled() {
  if [[ -n "${NO_COLOR:-}" ]]; then
    return 1
  fi
  [[ -t 1 ]] || [[ -t 2 ]]
}

# Build an ANSI escape sequence for a color code.
# Args: $1 = color number / SGR code
# Returns: echoes escape sequence (empty when disabled).
theme_ansi() {
  local code="${1:?color code required}"

  if ! theme_color_enabled; then
    printf ''
    return 0
  fi
  printf '\033[%sm' "${code}"
}

# Paint text with a theme color code.
# Args: $1 = color code, $2 = text
# Returns: echoes colored text with reset.
theme_paint() {
  local code="${1:?color code required}"
  local text="${2:-}"
  local start reset

  start="$(theme_ansi "${code}")"
  reset="$(theme_ansi "${COLOR_RESET:-0}")"
  printf '%s%s%s' "${start}" "${text}" "${reset}"
}

# Paint text using a named theme color variable.
# Args: $1 = COLOR_* variable name, $2 = text
# Returns: echoes colored text.
theme_paint_named() {
  local name="${1:?color name required}"
  local text="${2:-}"
  local code="${!name:-}"

  if [[ -z "${code}" ]]; then
    printf '%s' "${text}"
    return 0
  fi
  theme_paint "${code}" "${text}"
}

# Read a theme color value by COLOR_* name.
# Args: $1 = COLOR_* variable name
# Returns: echoes code; 1 if unset.
theme_get() {
  local name="${1:?color name required}"
  local code="${!name:-}"

  if [[ -z "${code}" ]]; then
    return 1
  fi
  printf '%s\n' "${code}"
}

# Echo the active theme name.
# Returns: echoes theme name.
theme_current() {
  printf '%s\n' "${THEME_NAME:-default}"
}

# List available theme names.
# Returns: echoes one theme name per line.
theme_list() {
  local theme_dir
  local file

  theme_dir="$(mm_resolve_path "${THEME_DIR:-themes}")"
  shopt -s nullglob
  for file in "${theme_dir}"/*.conf; do
    basename "${file}" .conf
  done
  shopt -u nullglob
}
