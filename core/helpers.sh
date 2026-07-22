#!/usr/bin/env bash
# core/helpers.sh — shared filesystem and safety helpers.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_HELPERS_LOADED:-}" ]] && return 0
MARIADB_MANAGER_HELPERS_LOADED=1

# Ensure a directory exists with safe permissions.
# Args: $1 = directory path, $2 = optional mode (default 0750).
# Returns: 0 on success.
mm_ensure_dir() {
  local path="${1:?directory path required}"
  local mode="${2:-0750}"

  if [[ ! -d "${path}" ]]; then
    mkdir -p "${path}"
    chmod "${mode}" "${path}"
  fi
}

# Return whether a command exists in PATH.
# Args: $1 = command name
# Returns: 0 if found, 1 otherwise.
mm_command_exists() {
  command -v "${1:?command required}" >/dev/null 2>&1
}

# Mask sensitive tokens in a string for safe logging.
# Args: $1 = input text
# Returns: echoes masked text.
mm_mask_secrets() {
  local text="${1:-}"

  text="${text//password=*/password=***}"
  text="${text//PASSWORD=*/PASSWORD=***}"
  text="${text//--password=*/--password=***}"
  text="${text//-p[^ ]*/-p***}"
  printf '%s\n' "${text}"
}

# Confirm a dangerous operation when configured to do so.
# Args: $1 = prompt message
# Returns: 0 if confirmed, 1 if declined.
mm_confirm_dangerous() {
  local message="${1:?confirmation message required}"

  if [[ "${CONFIRM_DANGEROUS:-yes}" != "yes" ]]; then
    return 0
  fi
  if declare -F ui_yesno >/dev/null 2>&1; then
    ui_yesno "Confirm" "${message}"
    return $?
  fi
  mm_confirm_dangerous_plain "${message}"
}

# Plain-terminal confirmation fallback.
# Args: $1 = prompt message
# Returns: 0 if confirmed, 1 if declined.
mm_confirm_dangerous_plain() {
  local message="${1:?confirmation message required}"
  local answer=""

  printf '%s [y/N]: ' "${message}"
  read -r answer || return 1
  [[ "${answer}" =~ ^[Yy]$ ]]
}

# Join arguments with a delimiter.
# Args: $1 = delimiter, remaining = parts
# Returns: echoes joined string.
mm_join() {
  local delim="${1:?delimiter required}"
  shift
  local out=""
  local part

  for part in "$@"; do
    if [[ -z "${out}" ]]; then
      out="${part}"
    else
      out="${out}${delim}${part}"
    fi
  done
  printf '%s\n' "${out}"
}

# Trim leading and trailing whitespace.
# Args: $1 = input
# Returns: echoes trimmed text.
mm_trim() {
  local text="${1:-}"

  text="${text#"${text%%[![:space:]]*}"}"
  text="${text%"${text##*[![:space:]]}"}"
  printf '%s\n' "${text}"
}

# Return whether a yes/no config flag is affirmative.
# Args: $1 = value
# Returns: 0 for yes/true/1.
mm_is_yes() {
  case "${1:-}" in
    yes | YES | true | TRUE | 1) return 0 ;;
    *) return 1 ;;
  esac
}

# Return byte size of a file, or 0 if missing.
# Args: $1 = path
# Returns: echoes integer size.
mm_file_size() {
  local path="${1:?path required}"

  if [[ ! -f "${path}" ]]; then
    printf '0\n'
    return 0
  fi
  wc -c <"${path}" | tr -d '[:space:]'
  printf '\n'
}

# Split a comma-separated list into lines.
# Args: $1 = csv string
# Returns: echoes one item per line.
mm_csv_to_lines() {
  local csv="${1:-}"
  local IFS=,
  local -a items
  local item

  read -r -a items <<<"${csv}"
  for item in "${items[@]}"; do
    item="$(mm_trim "${item}")"
    if [[ -n "${item}" ]]; then
      printf '%s\n' "${item}"
    fi
  done
}
