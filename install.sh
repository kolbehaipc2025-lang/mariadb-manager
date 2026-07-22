#!/usr/bin/env bash
# install.sh — install MariaDB Manager system-wide or to a custom prefix.
# shellcheck shell=bash

set -Eeuo pipefail

INSTALL_SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${PREFIX:-/usr/local}"
DEST_NAME="mariadb-manager"

# Print installer usage.
# Returns: 0
install_usage() {
  cat <<EOF
Usage: install.sh [OPTIONS]

Install MariaDB Manager.

Options:
  --prefix PATH    Install prefix (default: /usr/local)
  --user           Install to ~/.local
  -h, --help       Show help

Environment:
  PREFIX           Same as --prefix

EOF
}

# Parse installer arguments.
# Args: $@
# Returns: 0
install_parse_args() {
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
        install_usage
        exit 0
        ;;
      *)
        printf 'Unknown option: %s\n' "$1" >&2
        install_usage >&2
        exit 2
        ;;
    esac
  done
}

# Verify required source files exist before copying.
# Returns: 0 on success, 1 on failure.
install_preflight() {
  local required

  for required in bin/mdbm install.sh uninstall.sh config/config.conf core/bootstrap.sh drivers/mariadb.sh; do
    if [[ ! -e "${INSTALL_SELF}/${required}" ]]; then
      printf 'ERROR: missing required file: %s\n' "${required}" >&2
      return 1
    fi
  done
}

# Copy project tree into the destination directory.
# Args: $1 = destination root
# Returns: 0
install_copy_tree() {
  local dest="${1:?destination required}"

  mkdir -p "${dest}"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a \
      --exclude '.git/' \
      --exclude 'logs/*' \
      --exclude 'tmp/*' \
      --exclude 'backups/*' \
      --exclude '.cursor/' \
      "${INSTALL_SELF}/" "${dest}/"
  else
    install_copy_tree_cp "${dest}"
  fi
  mkdir -p "${dest}/logs" "${dest}/tmp" "${dest}/backups"
  chmod 0755 "${dest}/bin/mdbm" "${dest}/manager" \
    "${dest}/install.sh" "${dest}/uninstall.sh"
}

# Fallback copy when rsync is unavailable.
# Args: $1 = destination root
# Returns: 0
install_copy_tree_cp() {
  local dest="${1:?destination required}"
  local item

  for item in \
    bin config core drivers modules plugins themes assets docs tests \
    manager install.sh uninstall.sh \
    README.md CHANGELOG.md ROADMAP.md LICENSE .gitignore; do
    if [[ -e "${INSTALL_SELF}/${item}" ]]; then
      cp -a "${INSTALL_SELF}/${item}" "${dest}/"
    fi
  done
}

# Install symlinks into PREFIX/bin.
# Args: $1 = destination root
# Returns: 0
install_link_bin() {
  local dest="${1:?destination required}"
  local bin_dir="${PREFIX}/bin"

  mkdir -p "${bin_dir}"
  ln -sfn "${dest}/bin/mdbm" "${bin_dir}/mdbm"
  ln -sfn "${dest}/bin/mdbm" "${bin_dir}/mariadb-manager"
  ln -sfn "${dest}/manager" "${bin_dir}/manager"
}

# Main installer entry.
# Args: $@
# Returns: exit status.
install_main() {
  local dest

  install_parse_args "$@"
  install_preflight
  dest="${PREFIX}/lib/${DEST_NAME}"
  printf 'Installing MariaDB Manager to %s\n' "${dest}"
  install_copy_tree "${dest}"
  install_link_bin "${dest}"
  printf 'Installed. Run: mdbm --help\n'
}

install_main "$@"
