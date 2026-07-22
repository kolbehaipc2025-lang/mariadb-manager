#!/usr/bin/env bash
# drivers/mariadb.sh — MariaDB-specific driver backend (stubs only).
# Loaded exclusively by core/driver.sh. Modules never source this file.
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_DRIVER_MARIADB_LOADED:-}" ]] && return 0
MARIADB_MANAGER_DRIVER_MARIADB_LOADED=1

MM_MARIADB_READY=0

# Apply MariaDB connection defaults from configuration.
# Returns: 0
driver_backend_setup() {
  MARIADB_HOST="${MARIADB_HOST:-localhost}"
  MARIADB_PORT="${MARIADB_PORT:-3306}"
  MARIADB_SOCKET="${MARIADB_SOCKET:-/run/mysqld/mysqld.sock}"
  MARIADB_USER="${MARIADB_USER:-root}"
  MM_MARIADB_READY=0
  log_debug "MariaDB driver setup complete (stub)"
}

# Escape a SQL string literal for MariaDB.
# Args: $1 = raw value
# Returns: echoes escaped value without surrounding quotes.
driver_backend_escape_string() {
  local value="${1:-}"

  value="${value//'\'/'\\'}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//\'/\'\'}"
  printf '%s' "${value}"
}

# Quote a SQL identifier with backticks.
# Args: $1 = validated identifier
# Returns: echoes backtick-quoted identifier.
driver_backend_quote_identifier() {
  local ident="${1:?identifier required}"

  ident="${ident//\`/\`\`}"
  printf '`%s`' "${ident}"
}

# Probe whether a MariaDB/MySQL client binary exists.
# Returns: 0 if found.
driver_backend_client_available() {
  mm_command_exists mariadb || mm_command_exists mysql
}

# Connection check stub — business logic not implemented yet.
# Returns: 1
driver_backend_ping() {
  log_warn "MariaDB driver ping: not implemented yet"
  MM_MARIADB_READY=0
  return 1
}

# Query execution stub — business logic not implemented yet.
# Args: $@ = unused
# Returns: 1
driver_backend_query() {
  log_warn "MariaDB driver query: not implemented yet"
  return 1
}

# Report MariaDB backend readiness.
# Returns: echoes ready|not_ready
driver_backend_status() {
  if ((MM_MARIADB_READY == 1)); then
    printf 'ready\n'
  else
    printf 'not_ready\n'
  fi
}
