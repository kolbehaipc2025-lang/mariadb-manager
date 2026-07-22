# MariaDB Manager

Project Blueprint

Version: 0.1.0

Status: Draft

Author: MariaDB Manager Team

---

# 1. Vision

MariaDB Manager is a production-grade terminal application designed to simplify
the administration of MariaDB servers while maintaining enterprise-level
security, extensibility, and maintainability.

The project is not intended to be a collection of Bash scripts.
Instead, it is designed as a modular application framework with clearly
defined layers, interfaces, and extension points.

The primary goal is to provide a professional alternative to manual SQL
administration for database administrators, DevOps engineers and system
administrators.

---

# 2. Mission

Build an open-source MariaDB management platform that is:

- Secure
- Modular
- Testable
- Extensible
- Well documented
- Plugin based
- Themeable
- Production Ready

---

# 3. Design Philosophy

The project follows several core principles.

## Simplicity

Simple solutions are preferred over clever solutions.

## Readability

Readable code is more valuable than short code.

## Security

Security always has higher priority than convenience.

## Consistency

Every module behaves the same way.

## Extensibility

Every subsystem should be replaceable without changing the core.

## Reliability

Failures should be predictable and recoverable.

---

# 4. Project Goals

The project SHALL provide:

✓ User management

✓ Database management

✓ Permission management

✓ Backup

✓ Restore

✓ Monitoring

✓ Server information

✓ Configuration management

✓ Security tools

✓ Plugin system

✓ Theme engine

✓ Logging system

✓ Configuration engine

✓ Driver abstraction

✓ Interactive TUI

---

# 5. Non Goals

The project will NOT include:

- Web Interface
- PHP
- Python runtime dependency
- NodeJS dependency
- SQLite backend
- Embedded database server
- Cloud management platform

---

# 6. Architecture Overview

The application follows a layered architecture.

                +--------------------+
                |      UI Layer      |
                +--------------------+
                         |
                +--------------------+
                |   Dispatcher       |
                +--------------------+
                         |
                +--------------------+
                |     Services       |
                +--------------------+
                         |
                +--------------------+
                | Driver Interface   |
                +--------------------+
                         |
                +--------------------+
                | MariaDB Driver     |
                +--------------------+

Every request passes through the Dispatcher.

Modules never communicate directly with drivers.

---

# 7. Layers

Presentation Layer

Responsible for:

- Menus
- Dialogs
- Progress bars
- Notifications

Business Layer

Responsible for:

- Validation
- Business Rules
- Permissions
- Workflow

Driver Layer

Responsible for:

- SQL
- Connections
- Transactions

Infrastructure Layer

Responsible for:

- Config
- Logger
- Plugin
- Theme

---

# 8. Module Communication

Allowed

UI

↓

Dispatcher

↓

Module

↓

Driver Interface

↓

MariaDB Driver

Forbidden

Module

↓

MariaDB Driver

Module

↓

Another Module

UI

↓

Database

---

# 9. Dependency Rules

Allowed

Core → Driver

Core → Logger

Core → Config

Module → Dispatcher

Module → UI

Forbidden

Module → Driver

Driver → UI

Logger → Driver

Theme → Database

---

# 10. Driver Abstraction

Every database engine implements the same interface.

Current Driver

MariaDB

Future Drivers

MySQL

PostgreSQL

Mock Driver

The Core never knows which driver is being used.

---

# 11. Plugin System

Plugins are loaded dynamically.

Plugins cannot modify Core.

Plugins communicate only through exposed APIs.

Every plugin must declare:

- Name
- Version
- Description
- Author
- Required API Version

---

# 12. Theme System

Themes control:

- Colors
- Icons
- Borders
- Menu styles
- Dialog appearance

Business logic never depends on themes.

---

# 13. Configuration System

All configuration is stored in configuration files.

Configuration is loaded only by the Config Engine.

No module reads configuration files directly.

---

# 14. Logging

Every operation is logged.

Supported levels:

DEBUG

INFO

WARN

ERROR

FATAL

Passwords must never appear in logs.

---

# 15. Error Handling

Every failure returns:

- Error Code
- Human Message
- Debug Message

Errors are never silently ignored.

---

# 16. Security Principles

Passwords are masked.

SQL is validated.

Input is sanitized.

Dangerous operations require confirmation.

Temporary files are protected.

---

# 17. Coding Principles

One responsibility per function.

One responsibility per module.

Small files.

Documented public APIs.

ShellCheck clean.

shfmt formatted.

---

# 18. Testing Strategy

Unit Tests

Integration Tests

Mock Driver Tests

Plugin Tests

Regression Tests

---

# 19. Release Strategy

Development

↓

Alpha

↓

Beta

↓

Release Candidate

↓

Stable

---

# 20. Roadmap

Phase 1

Core Engine

Phase 2

Driver Layer

Phase 3

User Management

Phase 4

Permission Management

Phase 5

Database Management

Phase 6

Backup & Restore

Phase 7

Monitoring

Phase 8

Plugin SDK

Phase 9

Theme SDK

Phase 10

Version 1.0

---

# 21. Success Criteria

The project is considered successful when:

- Every subsystem is modular.
- Every feature is documented.
- Every module is independently testable.
- Core has no MariaDB-specific business logic.
- New drivers can be added without modifying Core.
- Plugins can extend functionality safely.
- The project can be maintained by multiple contributors.

---

# 22. Future Vision

MariaDB Manager should become one of the best open-source terminal tools
for MariaDB administration.

The architecture must remain stable while allowing new modules,
drivers, themes, and plugins to evolve independently.