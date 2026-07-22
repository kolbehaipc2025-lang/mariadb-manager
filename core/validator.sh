#!/usr/bin/env bash
# core/validator.sh — input validation helpers (no business logic).
# shellcheck shell=bash

[[ -n "${MARIADB_MANAGER_VALIDATOR_LOADED:-}" ]] && return 0
MARIADB_MANAGER_VALIDATOR_LOADED=1

# Require a non-empty value.
# Args: $1 = label, $2 = value
# Returns: 0 if non-empty.
validator_require() {
  local label="${1:?label required}"
  local value="${2:-}"

  if [[ -z "${value}" ]]; then
    error_raise "${MM_ERR_VALIDATION}" "Missing required value: ${label}" || return $?
  fi
}

# Validate a SQL / object identifier.
# Args: $1 = identifier
# Returns: 0 if valid.
validator_identifier() {
  local ident="${1:-}"

  validator_require "identifier" "${ident}" || return $?
  if [[ ! "${ident}" =~ ^[A-Za-z0-9_$.]+$ ]]; then
    error_raise "${MM_ERR_VALIDATION}" "Invalid identifier: ${ident}" || return $?
  fi
}

# Validate a TCP port number.
# Args: $1 = port
# Returns: 0 if valid.
validator_port() {
  local port="${1:-}"

  validator_require "port" "${port}" || return $?
  if [[ ! "${port}" =~ ^[0-9]+$ ]] || ((port < 1 || port > 65535)); then
    error_raise "${MM_ERR_VALIDATION}" "Invalid port: ${port}" || return $?
  fi
}

# Validate a hostname or simple DNS label list.
# Args: $1 = host
# Returns: 0 if valid.
validator_host() {
  local host="${1:-}"

  validator_require "host" "${host}" || return $?
  if [[ ! "${host}" =~ ^[A-Za-z0-9._-]+$ ]]; then
    error_raise "${MM_ERR_VALIDATION}" "Invalid host: ${host}" || return $?
  fi
}

# Validate value is one of allowed tokens.
# Args: $1 = label, $2 = value, remaining = allowed values
# Returns: 0 if allowed.
validator_enum() {
  local label="${1:?label required}"
  local value="${2:-}"
  shift 2
  local allowed

  validator_require "${label}" "${value}" || return $?
  for allowed in "$@"; do
    if [[ "${value}" == "${allowed}" ]]; then
      return 0
    fi
  done
  error_raise "${MM_ERR_VALIDATION}" "Invalid ${label}: ${value}" || return $?
}

# Validate a relative or absolute filesystem path shape.
# Args: $1 = path
# Returns: 0 if non-empty and free of NULs.
validator_path() {
  local path="${1:-}"

  validator_require "path" "${path}" || return $?
  if [[ "${path}" == *$'\0'* ]]; then
    error_raise "${MM_ERR_VALIDATION}" "Invalid path" || return $?
  fi
}

# Validate a yes/no flag.
# Args: $1 = label, $2 = value
# Returns: 0 if yes or no.
validator_yes_no() {
  local label="${1:?label required}"
  local value="${2:-}"

  validator_enum "${label}" "${value}" yes no || return $?
}
