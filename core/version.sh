#!/usr/bin/env bash
# core/version.sh — application version helpers.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_VERSION_LOADED:-}" ]] && return 0
MARIADB_MANAGER_VERSION_LOADED=1

# Print application name and version.
# Returns: echoes "name version" to stdout.
version_string() {
  printf '%s %s\n' "${APP_NAME:-MariaDB Manager}" "${APP_VERSION:-0.0.0}"
}

# Compatibility alias used by older call sites.
# Returns: echoes version string.
mm_version_string() {
  version_string
}

# Print version only.
# Returns: echoes APP_VERSION.
version_number() {
  printf '%s\n' "${APP_VERSION:-0.0.0}"
}

# Compare two dotted numeric versions.
# Args: $1 = left, $2 = right
# Returns: 0 if equal, 1 if left>right, 2 if left<right.
version_compare() {
  local left="${1:?left version required}"
  local right="${2:?right version required}"
  local IFS=.
  local -a a b
  local i

  read -r -a a <<<"${left}"
  read -r -a b <<<"${right}"
  for ((i = 0; i < 3; i++)); do
    local av="${a[i]:-0}"
    local bv="${b[i]:-0}"
    if ((av > bv)); then
      return 1
    fi
    if ((av < bv)); then
      return 2
    fi
  done
  return 0
}
