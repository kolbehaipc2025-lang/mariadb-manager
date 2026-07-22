# Contributing to MariaDB Manager

Thank you for your interest in contributing to MariaDB Manager.

This document defines the engineering workflow, contribution process,
coding expectations, review requirements, and release workflow.

Every contributor is expected to follow these guidelines.

---

# 1. Philosophy

MariaDB Manager values:

• Stability over speed

• Readability over cleverness

• Security over convenience

• Documentation over assumptions

• Architecture over shortcuts

Every contribution should improve the project without increasing
technical debt.

---

# 2. Before You Start

Before writing any code you should read:

PROJECT_BLUEPRINT.md

architecture.md

ARCHITECT.md

coding-style.md

driver-sdk.md

module-sdk.md

plugin-sdk.md

logger-sdk.md

ui-sdk.md

config-sdk.md

Understanding these documents is mandatory.

---

# 3. Development Workflow

Every feature follows this workflow.

Idea

↓

Discussion

↓

ADR (if architecture changes)

↓

Specification

↓

Implementation

↓

Tests

↓

Documentation

↓

Review

↓

Merge

↓

Release

Skipping steps is not allowed.

---

# 4. Branch Strategy

Main Branch

main

Always stable.

Development Branch

develop

Receives reviewed features.

Feature Branch

feature/<feature-name>

Bug Fix

bugfix/<issue-id>

Hotfix

hotfix/<issue-id>

Release

release/<version>

---

# 5. Commit Convention

Commit messages must follow Conventional Commits.

Examples

feat(users): add create user module

fix(driver): reconnect after timeout

docs(core): update architecture

refactor(logger): simplify formatting

test(plugin): add loader tests

ci(actions): improve shellcheck

chore(release): bump version

---

# 6. Pull Request Process

Every Pull Request must include:

Purpose

Implementation Summary

Related Issue

Testing Performed

Documentation Updated

Breaking Changes

Screenshots (if UI changed)

Checklist

PRs without complete information may be rejected.

---

# 7. Coding Requirements

Every new code must:

Pass ShellCheck

Pass shfmt

Contain documentation

Avoid duplicated logic

Respect architecture

Respect interfaces

Avoid global mutable state

Follow naming rules

---

# 8. Documentation Requirements

Every feature must update:

README (if applicable)

Specification

SDK (if API changes)

Architecture (if needed)

Changelog

Examples

Documentation is part of the feature.

---

# 9. Testing Requirements

Every feature requires tests.

Minimum:

Unit Tests

Integration Tests

Mock Driver Tests

Regression Tests (if applicable)

No feature is complete without tests.

---

# 10. Review Guidelines

Reviewers verify:

Architecture

Security

Readability

Performance

Maintainability

Compatibility

Error Handling

Documentation

Tests

Any issue blocks merge.

---

# 11. Architecture Rules

Never bypass Dispatcher.

Never bypass Driver Interface.

Never execute SQL inside modules.

Never hardcode configuration.

Never hardcode colors.

Never access internal Core state directly.

Never modify another module's private data.

---

# 12. Security Checklist

Before merge verify:

No passwords logged

No secrets committed

No unsafe rm commands

No eval

Proper quoting

Input validation

Permission checks

Safe temporary files

---

# 13. Performance Checklist

Avoid unnecessary forks.

Avoid unnecessary subprocesses.

Avoid repeated SQL queries.

Cache configuration.

Reuse connections.

Prefer Bash builtins.

---

# 14. Documentation Style

Documentation should be:

Clear

Complete

Versioned

Consistent

Example Driven

Avoid ambiguous wording.

---

# 15. Code Ownership

Core

Maintainers

Drivers

Database Team

Modules

Feature Owners

Plugins

Plugin Authors

Themes

UI Team

Infrastructure

Core Team

Ownership helps maintain quality.

---

# 16. Breaking Changes

Breaking changes require:

Architecture Review

ADR

Major Version

Migration Guide

Release Notes

Breaking changes are never merged silently.

---

# 17. Issue Labels

feature

bug

documentation

security

performance

refactor

testing

ci

discussion

good first issue

help wanted

question

duplicate

wontfix

invalid

---

# 18. Release Workflow

Feature Freeze

↓

Final Review

↓

Documentation Review

↓

Testing

↓

Release Candidate

↓

Stable Release

---

# 19. Contributor Checklist

Before opening a PR ensure:

✓ Code compiles

✓ Tests pass

✓ ShellCheck clean

✓ shfmt applied

✓ Documentation updated

✓ Changelog updated

✓ Architecture respected

✓ No TODO

✓ No FIXME

✓ No dead code

---

# 20. Reporting Bugs

Bug reports should include:

Version

Environment

Operating System

MariaDB Version

Steps to Reproduce

Expected Result

Actual Result

Logs

Screenshots (if applicable)

---

# 21. Feature Requests

Every feature request should include:

Problem Statement

Motivation

Possible Solution

Alternatives Considered

Architecture Impact

User Benefit

---

# 22. Security Reports

Security vulnerabilities should not be reported publicly.

Please contact the maintainers privately.

Include:

Description

Impact

Affected Version

Proof of Concept

Suggested Mitigation

---

# 23. Style Expectations

Readable code.

Small functions.

Small files.

Descriptive names.

Explicit logic.

Consistent formatting.

No unnecessary comments.

Document exported APIs.

---

# 24. Definition of Done

A task is complete only when:

✓ Implementation complete

✓ Reviewed

✓ Tested

✓ Documented

✓ Version updated

✓ Changelog updated

✓ No architecture violations

✓ Approved

---

# 25. Community Principles

Be respectful.

Be constructive.

Be professional.

Assume good intent.

Discuss ideas, not people.

Welcome newcomers.

Encourage learning.

---

# 26. Project Motto

Build software that your future self
will enjoy maintaining.

Architecture is permanent.

Implementation is temporary.

Thank you for contributing to MariaDB Manager.