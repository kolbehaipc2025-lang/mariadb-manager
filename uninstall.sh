#!/usr/bin/env bash
# uninstall.sh — remove a MariaDB Manager installation.
# shellcheck shell=bash

set -Eeuo pipefail

PREFIX="${PREFIX:-/usr/local}"
DEST_NAME="mariadb-manager"

# Print uninstaller usage.
# Returns: 0
uninstall_usage() {
  cat <<EOF
Usage: uninstall.sh [OPTIONS]

Remove MariaDB Manager from an install prefix.

Options:
  --prefix PATH    Install prefix (default: /usr/local)
  --user           Uninstall from ~/.local
  -h, --help       Show help

EOF
}

# Parse uninstaller arguments.
# Args: $@
# Returns: 0
uninstall_parse_args() {
  while (($# > 0)); do
    case "$1" in
      --prefix)
        PREFIX="${2:?--prefix requires a path}"
        shift 2
        ;;
      --user)
        PREFIX="${HOME}/.local"
        shift
        ;;
      -h | --help)
        uninstall_usage
        exit 0
        ;;
      *)
        printf 'Unknown option: %s\n' "$1" >&2
        uninstall_usage >&2
        exit 2
        ;;
    esac
  done
}

# Remove symlinks and install tree.
# Returns: 0
uninstall_remove() {
  local dest="${PREFIX}/lib/${DEST_NAME}"
  local link

  for link in "${PREFIX}/bin/mdbm" "${PREFIX}/bin/mariadb-manager" "${PREFIX}/bin/manager"; do
    if [[ -L "${link}" ]]; then
      rm -f "${link}"
      printf 'Removed %s\n' "${link}"
    fi
  done

  if [[ -d "${dest}" ]]; then
    rm -rf "${dest}"
    printf 'Removed %s\n' "${dest}"
  else
    printf 'Nothing to remove at %s\n' "${dest}"
  fi
}

# Main uninstaller entry.
# Args: $@
# Returns: exit status.
uninstall_main() {
  uninstall_parse_args "$@"
  uninstall_remove
  printf 'Uninstall complete.\n'
}

uninstall_main "$@"
