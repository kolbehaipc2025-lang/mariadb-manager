# MariaDB Manager

# System Architecture

Version: 1.0

Status: Draft

Last Updated: 2026-07-22

---

# 1. Introduction

## 1.1 Purpose

This document defines the complete architecture of the MariaDB Manager project.

It describes how every subsystem interacts, where responsibilities belong,
how dependencies flow through the system, and which architectural principles
must never be violated.

This document is the primary architectural reference for all contributors.

Every implementation must comply with this document.

---

## 1.2 Scope

This document covers:

- System architecture
- Layer responsibilities
- Communication flow
- Component interaction
- Dependency rules
- Runtime lifecycle
- Extension points
- Driver abstraction
- Plugin architecture
- Theme architecture
- Configuration architecture
- Logging architecture
- Error handling architecture

Implementation details belong to SDK documents.

---

# 2. Architectural Goals

The architecture has six primary goals.

## Goal 1

High Maintainability

Every subsystem must be understandable independently.

No hidden dependencies.

---

## Goal 2

Replaceable Components

Every major subsystem should be replaceable without affecting unrelated code.

Examples:

Replace dialog with whiptail.

Replace MariaDB with MySQL.

Replace theme engine.

Replace logger.

---

## Goal 3

Scalability

The architecture must support future modules without requiring core redesign.

Examples:

Cluster Manager

Replication Manager

Scheduler

Health Monitor

Cloud Backup

---

## Goal 4

Security

Security is part of architecture.

Not an additional feature.

All sensitive operations pass through validation layers.

---

## Goal 5

Testability

Every subsystem must be testable independently.

Every dependency should be mockable.

---

## Goal 6

Predictability

The same action must always follow the same execution path.

No hidden behavior.

No unexpected side effects.

---

# 3. High Level Architecture

The application follows a layered architecture.

                    +----------------------+
                    |      UI Layer        |
                    +----------------------+
                               |
                               v
                    +----------------------+
                    |     Dispatcher       |
                    +----------------------+
                               |
                               v
                    +----------------------+
                    |   Business Modules   |
                    +----------------------+
                               |
                               v
                    +----------------------+
                    | Driver Interface API |
                    +----------------------+
                               |
                               v
                    +----------------------+
                    | MariaDB Driver Layer |
                    +----------------------+
                               |
                               v
                    +----------------------+
                    |    MariaDB Server    |
                    +----------------------+

Infrastructure services operate alongside these layers:

- Logger
- Config
- Theme
- Plugin Loader
- Bootstrap
- Validator

These services never bypass architectural boundaries.

---

# 4. Layer Responsibilities

## Presentation Layer

Responsible for:

- Menus
- Forms
- Dialogs
- Progress bars
- Messages
- User interaction

The Presentation Layer never:

- Executes SQL
- Reads configuration directly
- Implements business rules

---

## Dispatcher Layer

Responsible for:

- Routing commands
- Invoking modules
- Lifecycle management
- Context propagation

The Dispatcher is the only component allowed to invoke modules.

---

## Business Layer

Responsible for:

- Business rules
- Validation
- Workflows
- Permission checks

Business modules never communicate directly with database drivers.

---

## Driver Layer

Responsible for:

- Database connections
- SQL execution
- Escaping
- Transactions
- Server metadata

Drivers expose a stable interface.

---

## Infrastructure Layer

Provides shared services:

- Logging
- Configuration
- Themes
- Plugins
- Error handling
- Helper functions

Infrastructure services never contain business logic.

---

# 5. Dependency Direction

Allowed

Presentation

↓

Dispatcher

↓

Business Modules

↓

Driver Interface

↓

Driver

↓

MariaDB

Forbidden

Presentation → Driver

Presentation → SQL

Module → Module

Driver → UI

Logger → Driver

Theme → Database

Plugin → Core Internals

Any dependency violating these rules is considered an architectural defect.

---

# 6. Core Principles

The architecture follows these principles.

Single Responsibility Principle

Every component has one reason to change.

---

Dependency Inversion

Business logic depends on interfaces.

Never on implementations.

---

Open / Closed Principle

Existing modules should remain unchanged when new functionality is added.

---

Interface First

Interfaces are designed before implementations.

---

Composition over Coupling

Subsystems communicate through contracts.

Never through implementation details.

---

Least Knowledge

Each subsystem only knows what it absolutely needs.

---

Fail Fast

Errors should be detected immediately.

Never continue after invalid state.

---

Deterministic Behavior

Given the same input,
the system should produce the same output.

Always.
---

# 7. Runtime Lifecycle

The MariaDB Manager application follows a deterministic startup and shutdown lifecycle.

Each phase has a single responsibility.

No component may execute before its dependencies are initialized.

---

## Startup Sequence

Application Startup

↓

Bootstrap

↓

Environment Validation

↓

Configuration Loading

↓

Logger Initialization

↓

Theme Loading

↓

Driver Registration

↓

Plugin Discovery

↓

Plugin Loading

↓

Module Registration

↓

Dispatcher Initialization

↓

UI Initialization

↓

Application Ready

---

## Bootstrap

Bootstrap is responsible for:

- verifying runtime environment
- checking Bash version
- validating required commands
- creating runtime directories
- initializing global context
- loading core libraries

Bootstrap MUST NOT:

- connect to MariaDB
- load plugins
- execute business logic

---

## Environment Validation

The validator performs startup checks.

Required checks include:

- Bash version
- Required binaries
- Writable directories
- Configuration syntax
- Locale
- Temporary directory
- File permissions

Startup immediately stops if validation fails.

---

## Configuration Loading

The Config Engine loads configuration in this order.

1. defaults.conf

↓

2. config.conf

↓

3. Environment Variables

↓

4. Runtime Overrides

Later sources always override earlier sources.

Modules never read configuration files directly.

---

## Logger Initialization

Logger starts before any module.

Every startup event must be logged.

Example:

INFO

Application Started

↓

Configuration Loaded

↓

Driver Registered

↓

Plugins Loaded

↓

Ready

---

## Theme Loading

Theme engine loads visual configuration.

Theme loading includes:

- colors
- borders
- unicode symbols
- menu style
- icons

Theme loading never affects application logic.

---

## Driver Registration

Driver Loader discovers available drivers.

Example

drivers/

mariadb.sh

mysql.sh

mock.sh

Only one driver becomes active.

The active driver must satisfy the Driver Interface.

---

## Plugin Discovery

Plugin Loader scans

plugins/

Every plugin is validated before loading.

Invalid plugins are ignored and logged.

Plugins never prevent application startup.

---

## Module Registration

Each module registers itself through the Module Loader.

Registration includes:

Module Name

Version

Dependencies

Commands

Permissions

Description

Dispatcher only communicates with registered modules.

---

## Dispatcher Initialization

Dispatcher creates routing table.

Routes are immutable after initialization unless explicitly reloaded.

Dispatcher becomes the central communication point.

---

## UI Initialization

The UI Engine determines available interface.

Priority

dialog

↓

whiptail

↓

terminal

Only one UI backend is active.

---

## Ready State

After initialization the application enters Ready State.

Allowed operations:

Open Menus

Execute Commands

Load Plugins

Execute Database Operations

Background Monitoring

Everything else must wait until Ready State.

---

# Shutdown Sequence

Application Exit

↓

Dispatcher Shutdown

↓

Plugin Shutdown

↓

Driver Disconnect

↓

Flush Logs

↓

Cleanup

↓

Exit

---

## Cleanup

Cleanup removes:

temporary files

temporary sockets

runtime cache

expired locks

Cleanup never removes:

configuration

backups

logs

plugins

---

## Failure During Startup

If initialization fails

Application

↓

Log Error

↓

Rollback Initialization

↓

Cleanup

↓

Exit

Application must never continue with partial initialization.

---

# Runtime States

UNINITIALIZED

↓

BOOTSTRAPPING

↓

READY

↓

RUNNING

↓

SHUTTING_DOWN

↓

STOPPED

Transitions outside these states are invalid.
---

# 9. Core Engine Architecture

The Core Engine is the foundation of the MariaDB Manager.

It provides all infrastructure services used by business modules.

Business modules must never replace or modify Core behavior.

Only documented extension points are allowed.

---

## Core Responsibilities

The Core is responsible for:

- Application lifecycle
- Service initialization
- Configuration
- Logging
- Driver management
- Dispatcher
- Module loading
- Plugin loading
- Theme loading
- Error management
- Runtime context

---

## Core Components

Bootstrap

↓

Configuration Manager

↓

Logger

↓

Theme Engine

↓

Driver Manager

↓

Plugin Loader

↓

Module Loader

↓

Dispatcher

↓

UI Engine

---

## Core Rules

The Core never contains:

Business Rules

SQL Statements

User Management

Permission Logic

Database Logic

Backup Logic

Those belong inside modules.

---

## Core Context

The Core maintains a runtime context.

Example:

Runtime State

Active Driver

Current Theme

Loaded Plugins

Loaded Modules

Configuration Cache

Application Version

Log Level

Session Information

---

## Initialization Ownership

Only the Core may initialize:

Logger

Driver

Configuration

Dispatcher

Plugins

Modules

UI

---

## Service Registry

Every infrastructure service registers itself.

Example

Logger

↓

Driver

↓

Theme

↓

Config

↓

Dispatcher

↓

Plugin Loader

↓

Module Loader

Services are accessed through the registry.

Never by file inclusion order.

---

## Runtime Events

The Core emits events.

Application.Start

Application.Ready

Application.Exit

Driver.Connected

Driver.Disconnected

Plugin.Loaded

Plugin.Unloaded

Module.Registered

Configuration.Reloaded

Theme.Changed

Future extensions listen to events instead of modifying Core.

---

## State Machine

BOOT

↓

INIT

↓

READY

↓

RUNNING

↓

SHUTDOWN

↓

EXIT

No other state transitions are allowed.

---

## Core Stability

Core APIs are considered stable.

Breaking changes require:

Architecture Review

↓

ADR

↓

Major Version

---

## Core Extension Policy

Core may be extended only by:

Plugins

Drivers

Modules

Themes

Direct modification is forbidden.
---

# 10. Driver Architecture

The Driver Layer isolates the application from the database engine.

Business modules never communicate directly with MariaDB.

Every operation passes through the Driver Interface.

---

## Design Goals

Database Independence

Testability

Replaceability

Connection Reuse

Transaction Support

Error Isolation

---

## Driver Stack

Business Module

↓

Driver Interface

↓

MariaDB Driver

↓

MariaDB Client

↓

MariaDB Server

---

## Supported Drivers

MariaDB

MySQL (future)

Mock Driver

Future Drivers

Every driver must expose exactly the same API.

---

## Driver Responsibilities

Open Connection

Close Connection

Reconnect

Ping Server

Execute Query

Execute Command

Escape Values

Transactions

Metadata

Health Check

Version Detection

Capability Detection

---

## Driver Interface

Mandatory Functions

driver_connect

driver_disconnect

driver_ping

driver_query

driver_execute

driver_escape

driver_begin

driver_commit

driver_rollback

driver_last_error

driver_last_errno

driver_version

driver_capabilities

driver_health

---

## Connection Lifecycle

Create

↓

Authenticate

↓

Validate

↓

Ready

↓

Reuse

↓

Disconnect

Connections should be reused whenever possible.

---

## Transactions

Supported

BEGIN

COMMIT

ROLLBACK

Nested transactions are not required.

---

## SQL Rules

SQL exists only inside drivers.

Forbidden

Modules executing SQL

Dispatcher executing SQL

UI executing SQL

Plugins executing SQL

---

## Driver Errors

Every driver returns

Exit Code

Error Code

Message

Debug Information

No raw mysql output reaches UI.

---

## Driver Discovery

Drivers are loaded dynamically.

Example

drivers/

mariadb.sh

mysql.sh

mock.sh

Driver selection is configuration driven.

---

## Driver Validation

Before activation the Core validates

Required Functions

Driver Version

Compatibility

Capabilities

Health

Invalid drivers are rejected.

---

## Mock Driver

A mock implementation is mandatory.

Purpose

Unit Tests

CI

Offline Development

Regression Tests

Mock driver never connects to MariaDB.

---

## Driver Security

Passwords never appear in logs.

SQL parameters must be escaped.

TLS support should be transparent.

Temporary credentials are erased immediately.
---

# 11. Module Architecture

Modules contain all business logic.

Every feature is implemented as a module.

Modules are independent.

Modules never call each other directly.

---

## Responsibilities

Business Rules

Validation

Workflow

Permission Checks

Driver Requests

UI Responses

---

## Forbidden Responsibilities

Configuration Loading

Logging Implementation

Driver Initialization

Plugin Loading

Theme Loading

Application Startup

---

## Module Structure

module/

README.md

module.conf

module.sh

commands/

views/

validators/

helpers/

tests/

---

## Module Lifecycle

Discover

↓

Validate

↓

Register

↓

Initialize

↓

Ready

↓

Execute

↓

Unload

---

## Module Registration

Each module declares

Name

Version

Author

Description

Dependencies

Commands

Permissions

API Version

---

## Command Registration

Example

users.list

users.create

users.delete

users.edit

Dispatcher owns the routing table.

---

## Module Dependencies

Allowed

Module

↓

Dispatcher

↓

Driver

Forbidden

Module

↓

Module

Module

↓

Database

Module

↓

Configuration Files

---

## Module Communication

Modules exchange information only through:

Dispatcher Events

Shared APIs

Registered Services

Never through global variables.

---

## Validation

Every module validates

Arguments

Input

Permissions

Driver Responses

Business Constraints

Validation failures stop execution immediately.

---

## Module States

UNLOADED

↓

REGISTERED

↓

INITIALIZED

↓

READY

↓

RUNNING

↓

STOPPED

---

## Error Handling

Modules never print raw errors.

Modules return structured errors.

Core formats user messages.

---

## Testing

Each module contains

Unit Tests

Integration Tests

Mock Driver Tests

Fixtures

Coverage is required before release.

---

## Version Compatibility

Modules declare

Minimum API Version

Maximum API Version

Unsupported modules are rejected during startup.

---

## Future Modules

Users

Permissions

Databases

Backup

Restore

Replication

Scheduler

Security

Monitoring

Audit

Cluster

Health

Each follows exactly the same lifecycle.
---

# 12. Plugin Architecture

## Overview

Plugins extend the functionality of MariaDB Manager without modifying the Core.

The Core remains stable while plugins add optional capabilities.

Plugins are isolated components.

A plugin failure must never terminate the application.

---

## Goals

The Plugin System exists to:

- extend functionality
- avoid Core modifications
- allow third-party extensions
- support future enterprise modules
- simplify maintenance

---

## Plugin Lifecycle

Discover

↓

Validate

↓

Load

↓

Initialize

↓

Register Hooks

↓

Running

↓

Shutdown

↓

Unload

---

## Plugin Directory

plugins/

plugin_name/

plugin.sh

plugin.conf

README.md

LICENSE

assets/

tests/

---

## Plugin Metadata

Every plugin MUST declare:

Plugin Name

Plugin ID

Version

Description

Author

License

API Version

Minimum Core Version

Maximum Core Version

Dependencies

---

## Plugin API

Plugins interact with the Core only through public APIs.

Allowed APIs:

Logger API

Configuration API

Dispatcher API

Driver API

UI API

Theme API

Event API

Forbidden:

Direct file inclusion

Global variable manipulation

Calling private functions

Editing Core files

---

## Plugin Hooks

Supported lifecycle hooks:

plugin_init()

plugin_start()

plugin_ready()

plugin_shutdown()

plugin_cleanup()

---

## Event Hooks

Plugins may subscribe to:

Application.Start

Application.Ready

Driver.Connected

Driver.Disconnected

Module.Registered

Module.Executed

Backup.Created

User.Created

Database.Created

Theme.Changed

Configuration.Reloaded

Application.Exit

---

## Plugin Isolation

Plugins never:

Modify Dispatcher

Replace Logger

Override Driver

Change Configuration Files

Alter Core Behavior

Only documented APIs may be used.

---

## Plugin Failure

Plugin failures must:

Log Error

Disable Plugin

Continue Application

Application stability has priority over plugin availability.

---

## Plugin Versioning

Every plugin declares:

API Version

Core Compatibility

Schema Version

The Plugin Loader rejects incompatible plugins.

---

## Future Plugin Types

Authentication

Monitoring

Notifications

Cloud Backup

Replication

Metrics

Slack Integration

Telegram Notifications

Email Alerts

Reporting
---

# 13. Theme Architecture

## Overview

Themes define visual appearance only.

Themes never contain business logic.

Changing themes must not affect application behavior.

---

## Responsibilities

Colors

Icons

Borders

Spacing

Tables

Dialog Layout

Progress Bars

Status Indicators

Unicode Symbols

---

## Theme Directory

themes/

default/

theme.conf

palette.conf

icons.conf

layout.conf

README.md

---

## Theme Components

Palette

Typography

Borders

Spacing

Icons

Animations (future)

---

## Color Roles

Primary

Secondary

Accent

Success

Warning

Danger

Info

Background

Foreground

Border

Disabled

Highlight

---

## UI Elements

Menus

Forms

Dialogs

Status Bars

Tables

Notifications

Progress

Spinner

Footer

Header

Every element receives colors from Theme Engine.

---

## Theme Loading

Theme

↓

Validation

↓

Palette

↓

Icons

↓

Layout

↓

Activate

Invalid themes are rejected.

---

## Runtime Theme Change

Supported.

Theme changes must refresh UI only.

Business modules remain unaffected.

---

## Theme Rules

Never hardcode colors.

Never hardcode Unicode symbols.

Never hardcode borders.

Everything comes from Theme Engine.
---

# 14. Configuration Architecture

## Goals

Centralized

Predictable

Cached

Reloadable

Validated

---

## Configuration Sources

defaults.conf

↓

config.conf

↓

Environment Variables

↓

CLI Options

↓

Runtime Overrides

---

## Configuration Ownership

Only Config Manager reads files.

Modules never access configuration directly.

---

## Configuration Categories

Application

Database

Driver

Logging

Theme

Plugin

Security

Backup

Monitoring

Network

---

## Configuration Cache

Configuration is cached after loading.

Repeated disk reads are forbidden.

---

## Runtime Reload

Supported.

Configuration.Reload event is emitted.

Modules may refresh internal state.

---

## Validation

Each configuration value has:

Type

Default

Validation Rule

Description

Invalid configuration aborts startup.

---

## Security

Passwords are stored separately.

Sensitive values are masked.

Secrets never appear in logs.
---

# 15. Logging Architecture

## Goals

Centralized

Structured

Searchable

Auditable

Secure

---

## Log Levels

TRACE

DEBUG

INFO

NOTICE

WARN

ERROR

FATAL

---

## Log Categories

Application

Driver

Module

Plugin

Security

Backup

Audit

Performance

---

## Log Format

Timestamp

Level

Component

Message

Context

---

## Sensitive Data

Never log:

Passwords

Tokens

Private Keys

Connection Strings

Secrets

---

## Log Rotation

Supported.

Old logs are archived.

Retention is configurable.

---

## Audit Logs

Security events produce audit entries.

Examples

User Created

Permission Changed

Database Dropped

Backup Deleted

Login Failed

Driver Changed

---

## Performance Logs

Slow operations are recorded.

Examples

Long Queries

Backup Duration

Plugin Startup Time

Module Execution Time
---

# 16. Error Handling Architecture

## Overview

Error handling is a first-class architectural concern.

Errors must never be ignored.

Every failure must be:

- detected
- classified
- logged
- reported
- recoverable when possible

---

## Error Lifecycle

Failure

↓

Detection

↓

Classification

↓

Logging

↓

Recovery

↓

Notification

↓

Exit or Continue

---

## Error Categories

Configuration Errors

Validation Errors

Driver Errors

Connection Errors

Authentication Errors

Authorization Errors

Plugin Errors

Module Errors

UI Errors

Filesystem Errors

Network Errors

Internal Errors

---

## Error Object

Every error contains:

Error Code

Severity

Component

Message

Debug Message

Timestamp

Recovery Action

Reference ID

---

## Severity Levels

INFO

WARNING

ERROR

CRITICAL

FATAL

---

## Recovery Policy

Recover Automatically

Retry

Ask User

Rollback

Abort

Every error must define its recovery policy.

---

## User Messages

Users receive concise messages.

Debug information is written only to logs.

Never expose stack traces.

Never expose SQL.

Never expose credentials.
---

# 17. Security Architecture

## Security Model

Security is implemented in every layer.

No layer may bypass security validation.

---

## Security Principles

Least Privilege

Fail Secure

Input Validation

Output Escaping

Secure Defaults

Defense in Depth

---

## Authentication

Supported methods:

Username / Password

Socket Authentication

Future:

LDAP

PAM

OAuth

---

## Authorization

Permissions are role based.

Every operation validates permissions before execution.

---

## Sensitive Data

Passwords

Private Keys

Access Tokens

Certificates

Secrets

Connection Credentials

Sensitive data must:

Never be logged

Never be echoed

Never be stored unencrypted

---

## Temporary Files

Temporary files must:

Use secure permissions

Be removed after use

Never contain secrets in plain text

---

## SQL Security

Every SQL parameter must be escaped.

No SQL string concatenation inside modules.

Parameterized execution should be preferred whenever possible.

---

## Plugin Security

Plugins execute with limited privileges.

Plugins cannot:

Modify Core

Replace Drivers

Access internal state

Read private configuration

Unless explicitly allowed through public APIs.
---

# 18. Execution Flow

## Example: Create User

User

↓

UI

↓

Dispatcher

↓

Users Module

↓

Validation

↓

Driver Interface

↓

MariaDB Driver

↓

MariaDB Server

↓

Result

↓

Logger

↓

UI

---

## Example: Backup

User

↓

UI

↓

Dispatcher

↓

Backup Module

↓

Driver

↓

Filesystem

↓

Logger

↓

UI

---

## Example: Plugin Startup

Application

↓

Plugin Loader

↓

Plugin Validation

↓

Plugin Init

↓

Plugin Ready

↓

Dispatcher Event
---

# 19. Dependency Matrix

| Component | UI | Dispatcher | Module | Driver | Logger | Config |
|------------|----|------------|---------|---------|---------|---------|
| UI | ✓ | ✓ | ✗ | ✗ | ✓ | ✓ |
| Dispatcher | ✗ | ✓ | ✓ | ✗ | ✓ | ✓ |
| Module | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ |
| Driver | ✗ | ✗ | ✗ | ✓ | ✓ | ✓ |
| Logger | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ |
| Config | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |

Rules:

Dependencies must always flow downward.

Circular dependencies are forbidden.
---

# 20. Architecture Decision Records

Major architectural changes require an ADR.

Each ADR must include:

Title

Status

Context

Decision

Consequences

Alternatives Considered

Related Issues

Related Specifications

ADR files are stored in:

docs/adr/

Example:

0001-driver-abstraction.md

0002-plugin-system.md

0003-dispatcher.md

0004-theme-engine.md
---

# 21. Future Evolution

The architecture is intentionally designed to support future growth.

Potential future subsystems include:

Cluster Management

Replication Management

Remote Hosts

Scheduling

REST API

Terminal Dashboard

High Availability

Metrics

Notification Center

Cloud Storage

Each new subsystem must comply with existing architectural rules.
---

# 22. Glossary

Core

Infrastructure responsible for application lifecycle.

Driver

Database implementation layer.

Dispatcher

Central routing component.

Module

Business logic component.

Plugin

Optional extension.

Theme

Visual appearance package.

SDK

Developer interface specification.

ADR

Architecture Decision Record.

TUI

Terminal User Interface.

API

Public interface between components.
---

# Conclusion

This document defines the architectural foundation of MariaDB Manager.

All future development must comply with the principles, constraints, and contracts described here.

Architecture changes are controlled through ADRs and versioned specifications to ensure long-term stability and maintainability.

End of Document