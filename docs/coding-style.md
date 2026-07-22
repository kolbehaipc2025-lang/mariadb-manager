# MariaDB Manager

Coding Style Guide

Version: 1.0

Status: Draft

Applies To

- Core
- Drivers
- Modules
- Plugins
- Themes
- Tests
- Scripts

---

# 1. Purpose

This document defines the coding standards for the MariaDB Manager project.

Every source file must comply with these rules.

Consistency is more important than personal preference.

---

# 2. Philosophy

Good code is:

Readable

Predictable

Maintainable

Secure

Testable

Documented

Simple

---

## Simplicity

Prefer simple code.

Avoid clever tricks.

If a junior developer cannot understand a function,
the function should probably be rewritten.

---

## Readability

Code is written for humans.

Computers execute it.

Humans maintain it.

Always optimize for readability.

---

## Explicitness

Never rely on implicit behavior.

Always be explicit.

Examples

Good

if [[ -f "$file" ]]

Bad

[ -f $file ]

---

## Consistency

The same problem should always be solved
using the same coding style.

Do not mix styles.

---

## Maintainability

Every function should be easy to modify.

Every module should be replaceable.

Every file should have a clear purpose.

---

## Security

Never sacrifice security
to reduce code size.

Security always wins.

---

## Documentation

Every exported function requires documentation.

Complex logic requires explanation.

Obvious code requires no comments.
---

# 3. File Organization

Every file has exactly one responsibility.

Maximum recommended size:

250 lines

Maximum allowed size:

350 lines

If a file grows beyond this limit,
split it immediately.

---

## File Header

Every source file begins with:

#!/usr/bin/env bash

set -Eeuo pipefail

IFS=$'\n\t'

Project header

License

Description

---

## Include Order

1. Constants

2. Imports

3. Global Variables

4. Private Functions

5. Public Functions

6. Main Entry Point

Never mix this order.

---

## One Responsibility

Examples

Good

user_create.sh

backup_restore.sh

driver_connection.sh

Bad

utils_everything.sh

common.sh

misc.sh

helpers2.sh
---

# 4. Naming Conventions

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

Booleans

is_enabled

has_permission

can_connect

Private Functions

_prefix

Public Functions

driver_connect

module_register

logger_info

Avoid abbreviations.

Bad

usr

cfg

dbm

tmp2

Good

user

configuration

database

temporary_directory
---

# 5. Formatting

Indentation

4 Spaces

Never use Tabs.

Maximum line length

100 Characters

Blank lines

One blank line between functions.

Two blank lines between logical sections.

Spaces

Good

if [[ "$value" == "yes" ]]

Bad

if [["$value"=="yes"]]

Braces

Opening brace on same line.

Closing brace on new line.

Always quote variables.

Correct

"$variable"

Incorrect

$variable
---

# 6. Functions

Functions should do one thing.

Preferred size:

15 Lines

Maximum:

30 Lines

Maximum parameters:

5

Return values

Use return codes.

Do not echo unexpected values.

Function names must describe behavior.

Good

backup_database

validate_username

driver_execute

Bad

run

execute

process

do_it
---

# 7. Variables

Prefer local variables.

Avoid globals.

Use readonly where possible.

Initialize variables immediately.

Bad

local result

...

result="OK"

Good

local result="OK"

Constants

readonly VERSION="1.0.0"

Boolean values

true

false

Never

1

0

yes

no

unless interacting with external commands.
---

# 8. Bash Best Practices

The project targets Bash 5+.

Always assume strict mode.

Every source file begins with:

#!/usr/bin/env bash

set -Eeuo pipefail

IFS=$'\n\t'

---

## Strict Mode

Always enable:

- errexit
- nounset
- pipefail
- errtrace

Never disable strict mode globally.

If required, disable it only inside a very small scope.

---

## Command Substitution

Preferred

value="$(command)"

Never

value=`command`

---

## Tests

Preferred

[[ ]]

Avoid

[ ]

unless POSIX compatibility is explicitly required.

---

## Arithmetic

Preferred

(( counter++ ))

Avoid

expr

let

external utilities

---

## Loops

Preferred

for

while

read

Avoid parsing ls output.

Bad

for file in $(ls)

Good

for file in *.sql

---

## Reading Files

Always use

while IFS= read -r line

Never

for line in $(cat file)

---

## Quoting

Always quote variables.

Correct

"$filename"

Incorrect

$filename

---

## Exit Codes

0

Success

Non-zero

Failure

Never invent custom meanings.

---

## Trap

Cleanup handlers should use

trap cleanup EXIT

Signal handlers

trap terminate SIGINT SIGTERM
---

# 9. Error Handling

Errors must never be ignored.

---

## Good

if ! driver_connect; then
    logger_error "Unable to connect"
    return 1
fi

---

## Bad

driver_connect

---

Always verify

File operations

Network operations

SQL execution

Command execution

---

## Never Ignore

Bad

rm file

Good

rm file || return 1

---

## Fail Fast

Stop immediately after unrecoverable errors.

Never continue with invalid state.

---

## Retry Policy

Only retry when:

Connection timeout

Temporary network error

Deadlock

Never retry

Authentication failures

Permission failures

Configuration errors
---

# 10. Logging Style

Never use echo for diagnostics.

Always use Logger API.

Correct

logger_info

logger_warn

logger_error

logger_debug

logger_fatal

---

## Message Style

Good

Database backup completed successfully.

Bad

Done

---

## Log Context

Every important log includes

Component

Operation

Object

Duration (if applicable)

---

## Sensitive Information

Never log

Passwords

Tokens

Certificates

Private Keys

Connection Strings
---

# 11. Comment Style

Comments explain WHY.

Code explains HOW.

Never comment obvious code.

Bad

# increment counter
counter=$((counter+1))

Good

# MariaDB requires reconnect after timeout
# because idle sessions may be terminated.
reconnect_if_needed

---

## Function Header

Every public function requires

Purpose

Arguments

Returns

Side Effects

Example

############################################################

# Create database

#
# Args:
#
#   database_name
#
# Returns:
#
#   0 success
#
#   non-zero failure

############################################################
---

# 12. Documentation

Every module requires README.md

Every public API requires documentation.

Every exported function requires documentation.

Complex algorithms require explanation.

Avoid documenting obvious code.

Documentation should answer

What

Why

When

Not

How
---

# 13. SQL Rules

SQL belongs only inside drivers.

Modules never contain SQL.

---

## Formatting

Keywords

UPPERCASE

Identifiers

lowercase

One clause per line.

Example

SELECT

user

FROM

mysql.user

WHERE

host='localhost'

---

## Escaping

Always escape parameters.

Never concatenate SQL strings.

Preferred

driver_execute

Forbidden

mysql -e "SELECT ... $value"

---

## Transactions

Always rollback on failure.

Never leave transactions open.
---

# 14. Module Rules

Each module implements one feature.

Every module contains

README

tests

validators

helpers

commands

views

Modules never access database directly.

Modules communicate only through Dispatcher.

Modules never depend on another module.
---

# 15. Driver Rules

Drivers hide implementation details.

Drivers expose stable APIs.

Every driver implements

connect

disconnect

execute

query

escape

transaction

health

version

No UI code inside drivers.

No business rules inside drivers.
---

# 16. Plugin Rules

Plugins extend functionality.

Plugins never modify Core.

Plugins never override drivers.

Plugins communicate through public APIs only.

Every plugin contains

README

License

Metadata

Tests

Version
---

# 17. UI Rules

UI contains no business logic.

UI contains no SQL.

UI displays information only.

Supported interfaces

dialog

whiptail

terminal

Theme controls appearance.

UI never hardcodes colors.
---

# 18. Testing Standards

Testing is mandatory.

No feature is considered complete without automated tests.

---

## Test Types

Unit Tests

Integration Tests

Regression Tests

Mock Driver Tests

Performance Tests

Security Tests

---

## Test Naming

test_driver_connect

test_create_user

test_backup_database

test_restore_database

---

## Test Independence

Every test must be:

Independent

Repeatable

Deterministic

Self-cleaning

Tests must never depend on execution order.

---

## Fixtures

Test fixtures belong in

tests/fixtures/

Never duplicate fixture data.

---

## Assertions

Every test must verify:

Expected Result

Exit Code

Error Handling

Logs (when applicable)

Side Effects
---

# 19. ShellCheck Compliance

All code must pass ShellCheck.

CI rejects code with ShellCheck errors.

---

## Required Rules

Quote Variables

Avoid Useless cat

Use $( )

Avoid Word Splitting

Avoid Unsafe rm

Use local Variables

Quote Command Substitution

---

## Exceptions

Exceptions require:

Documentation

Reason

Reference

ShellCheck disable directives should be rare.
---

# 20. Performance Guidelines

Performance improvements must never reduce readability.

---

## Avoid

Repeated SQL

Repeated Config Reads

Repeated File Reads

Repeated Forks

Repeated grep/sed/awk chains

---

## Prefer

Builtins

Caching

Connection Reuse

Lazy Loading

Reusable Functions

---

## Measure

Before optimizing.

Never optimize blindly.
---

# 21. Security Rules

Security is mandatory.

---

## Forbidden

eval

Hardcoded Passwords

Unsafe rm

Temporary Files Without Permissions

Command Injection

SQL Injection

Word Splitting

Unchecked User Input

---

## Required

Input Validation

Output Escaping

Permission Verification

Secure Defaults

Least Privilege

Sensitive Data Masking

---

## File Permissions

Configuration

600

Private Keys

600

Directories

700

Executables

755
---

# 22. Code Review Checklist

Reviewers verify:

Architecture

Documentation

Naming

Formatting

Security

Performance

Testing

Logging

Error Handling

Compatibility

Maintainability

---

## Merge Criteria

ShellCheck Clean

Tests Passing

Documentation Updated

Architecture Respected

Approved Review

No TODO

No FIXME

No Dead Code
---

# 23. Anti-Patterns

Avoid these practices.

---

## God Files

Files containing multiple responsibilities.

---

## God Functions

Functions exceeding 30 lines.

---

## Hidden Dependencies

Modules depending on implementation details.

---

## Copy & Paste

Duplicate code should be refactored.

---

## Silent Failures

Ignoring exit codes.

Ignoring SQL errors.

Ignoring filesystem errors.

---

## Global State

Avoid mutable globals.

Prefer explicit parameters.

---

## Magic Numbers

Bad

timeout=17

Good

readonly CONNECTION_TIMEOUT=30

---

## Hardcoded Values

Never hardcode:

Colors

Paths

Ports

Usernames

Passwords

Database Names
---

# 24. Examples

## Variables

Bad

name=$1

Good

local username="$1"

---

## Conditions

Bad

if [ $x = yes ]

Good

if [[ "$answer" == "yes" ]]

---

## Loops

Bad

for file in $(ls)

Good

for file in *.sql

---

## Errors

Bad

mysql ...

Good

if ! driver_execute "..."; then
    logger_error "Query failed"
    return 1
fi

---

## Logging

Bad

echo "done"

Good

logger_info "Database backup completed."
---

# 25. Definition of Clean Code

Clean code is:

Readable

Small

Predictable

Secure

Documented

Tested

Consistent

Portable

Reusable

Maintainable

If code is difficult to explain,

rewrite it.
---

# 26. Final Checklist

Before committing verify:

✓ File size acceptable

✓ Function size acceptable

✓ Variables quoted

✓ ShellCheck clean

✓ shfmt applied

✓ Tests pass

✓ Documentation updated

✓ No duplicated logic

✓ No architecture violations

✓ Security reviewed

✓ Performance acceptable

✓ Meaningful commit message

---

# Conclusion

This coding style guide exists to ensure that every contribution to MariaDB Manager is consistent, maintainable, secure, and production-ready.

Following these standards keeps the codebase approachable for contributors and reduces long-term maintenance costs.

End of Document.