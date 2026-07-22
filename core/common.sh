#!/usr/bin/env bash
# core/common.sh — project root and path primitives.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_COMMON_LOADED:-}" ]] && return 0
MARIADB_MANAGER_COMMON_LOADED=1

# Resolve absolute project root from this file location.
# Returns: sets MM_ROOT to the repository / install root.
mm_detect_root() {
  local source_path="${BASH_SOURCE[0]}"
  local dir

  dir="$(cd "$(dirname "${source_path}")" && pwd)"
  MM_ROOT="$(cd "${dir}/.." && pwd)"
}

# Resolve a path relative to MM_ROOT when not absolute.
# Args: $1 = path
# Returns: echoes absolute path.
mm_resolve_path() {
  local path="${1:?path required}"

  if [[ "${path}" = /* ]]; then
    printf '%s\n' "${path}"
  else
    printf '%s/%s\n' "${MM_ROOT}" "${path}"
  fi
}

mm_detect_root
