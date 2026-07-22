# MariaDB Manager

# Architecture & Development Rules

Version: 1.0

Status: Active

Applies To:

- Cursor
- GitHub Copilot
- Human Contributors
- Future Maintainers

---

# Purpose

This document defines the mandatory engineering rules for the MariaDB Manager project.

These rules are considered project law.

Every generated source file, module, script, documentation, and test must comply with this document.

Violations should be considered defects.

---

# Project Vision

MariaDB Manager is not a Bash script.

MariaDB Manager is a modular application framework written in Bash.

The project must remain maintainable for many years.

Architecture is always more important than implementation speed.

---

# Golden Rules

These rules have the highest priority.

1. Security over convenience.

2. Readability over cleverness.

3. Maintainability over speed.

4. Explicit over implicit.

5. Small modules over large files.

6. Stable APIs over shortcuts.

7. Documentation before implementation.

8. Architecture before features.

9. Tests before release.

10. Never break backward compatibility without an ADR.

---

# Non Goals

The project MUST NOT become:

- a collection of random scripts
- a SQL playground
- a framework with hidden side effects
- dependent on Python
- dependent on PHP
- dependent on NodeJS
- dependent on SQLite
- tightly coupled to MariaDB

---

# Architecture Principles

The project follows:

- Layered Architecture
- Interface First Design
- Dependency Inversion
- Single Responsibility
- Open / Closed Principle
- Plugin Oriented Design
- Driver Abstraction
- Event Driven Extensions

---

# Layers

Presentation

↓

Dispatcher

↓

Modules

↓

Driver Interface

↓

Database Driver

↓

MariaDB

No layer may bypass another.

---

# Folder Rules

Every folder has one responsibility.

core/

Contains reusable infrastructure.

drivers/

Database implementations.

modules/

Business logic.

plugins/

Extensions.

themes/

Appearance only.

config/

Configuration.

tests/

Automated tests.

docs/

Documentation.

logs/

Runtime logs.

tmp/

Temporary runtime files.

backups/

Generated backups.

assets/

Static resources.

---

# File Rules

Maximum size:

350 lines

Preferred:

250 lines

If larger:

Split immediately.

---

# Function Rules

Maximum:

30 lines

Preferred:

15 lines

Functions must:

- perform one task
- return meaningful exit codes
- never print unexpected output
- avoid global state
- validate arguments

---

# Naming Rules

Directories

snake_case

Files

snake_case

Functions

snake_case

Variables

snake_case

Constants

UPPER_CASE

---

# Bash Rules

Always use

set -Eeuo pipefail

IFS must be safe.

Quote every variable.

Never rely on word splitting.

Avoid subshells unless necessary.

Prefer builtins over external commands.

---

# Driver Rules

Modules never execute SQL.

Modules never call mysql.

Modules never call mariadb.

All SQL goes through Driver Interface.

Every driver must implement:

driver_connect

driver_disconnect

driver_ping

driver_query

driver_execute

driver_escape

driver_begin

driver_commit

driver_rollback

driver_version

---

# Dispatcher Rules

Every module communicates through Dispatcher.

Dispatcher owns routing.

Modules never call each other directly.

---

# UI Rules

UI contains no business logic.

UI never executes SQL.

UI only displays information.

Supported interfaces:

dialog

↓

whiptail

↓

plain terminal

---

# Theme Rules

Themes define:

colors

icons

padding

borders

symbols

Business logic never depends on themes.

---

# Logger Rules

Everything is logged.

Supported Levels:

DEBUG

INFO

WARN

ERROR

FATAL

Passwords are never logged.

SQL containing secrets is never logged.

---

# Configuration Rules

Configuration is loaded once.

Modules never read configuration files directly.

Environment variables override configuration files.

---

# Plugin Rules

Plugins are isolated.

Plugins cannot modify Core.

Plugins communicate only through documented APIs.

Plugin metadata is mandatory.

---

# Error Handling

Every error has:

Error Code

User Message

Debug Message

Recovery Action

Never ignore errors.

Never hide failures.

---

# Security Rules

Never use eval.

Never trust user input.

Validate everything.

Escape SQL.

Mask passwords.

Require confirmation before destructive operations.

Protect temporary files.

Use least privilege.

---

# Performance Rules

Avoid unnecessary subprocesses.

Avoid repeated SQL queries.

Cache configuration.

Lazy-load modules.

Reuse database connections.

---

# Documentation Rules

Every exported function requires documentation.

Every module requires README.

Every architecture decision requires ADR.

Every feature requires Specification.

---

# Testing Rules

Every subsystem must be testable.

Unit tests

Integration tests

Mock driver tests

Regression tests

ShellCheck

shfmt

---

# Review Checklist

Before merge:

✓ ShellCheck passes

✓ shfmt passes

✓ No duplicated code

✓ Documentation updated

✓ Tests pass

✓ No TODO

✓ No FIXME

✓ Architecture respected

---

# Definition of Done

A feature is complete only when:

- implementation finished
- reviewed
- documented
- tested
- committed
- changelog updated
- version updated

---

# Commit Rules

One logical change per commit.

Meaningful commit message.

Never mix refactor and feature.

---

# Release Rules

Development

↓

Alpha

↓

Beta

↓

RC

↓

Stable

---

# Pull Request Rules

Every PR must contain:

Purpose

Implementation Summary

Testing

Breaking Changes

Documentation Impact

---

# Forbidden Practices

Never:

- hardcode passwords
- hardcode colors
- use eval
- bypass Dispatcher
- bypass Driver
- execute SQL in UI
- create giant files
- ignore exit codes
- suppress errors silently

---

# Final Principle

Architecture is permanent.

Implementation is replaceable.

When in doubt:

Choose the solution that improves maintainability.