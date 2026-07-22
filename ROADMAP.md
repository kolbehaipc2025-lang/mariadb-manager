# Roadmap

MariaDB Manager aims to become the best open-source terminal MariaDB management tool.

## Phase 0 — Skeleton

- [x] Directory layout and core architecture
- [x] Config, logger, theme engine, UI engine, plugin loader
- [x] Empty modules and installer
- [x] Documentation baseline

## Phase 0.2 — Enterprise modular refactor

- [x] `drivers/` + `core/driver.sh` separation
- [x] Module packages under `modules/<name>/`
- [x] Core libs: error, helpers, validator, version, dispatcher
- [x] `bin/mdbm` entrypoint
- [x] Architecture documentation

## Phase 0.3 — Core Engine

- [x] Production config loader (dynamic + env)
- [x] Production logger (rotation, components)
- [x] Error engine with last-error state
- [x] Theme + UI engines (dialog → whiptail → plain)
- [x] Driver interface with hook verification
- [x] Dispatcher as sole module→driver gateway
- [x] Plugin loader filters and validation
- [x] Phased bootstrap

## Phase 1 — Core MariaDB layer

- [ ] Secure connection handling (socket, TCP, defaults-file)
- [ ] Identifier escaping and input validation (driver-backed)
- [ ] Query execution API used only via `driver_*`
- [ ] Password masking in logs
- [ ] Connection health checks

## Phase 2 — Essential modules

- [ ] Users: create, drop, rename, password reset
- [ ] Permissions: grant, revoke, show grants
- [ ] Database: create, drop, list, charset/collation
- [ ] Settings: runtime config editor with validation

## Phase 3 — Operations

- [ ] Backup: logical dumps, compression, retention
- [ ] Restore: interactive restore with confirmation
- [ ] Monitor: process list, status, resource snapshots
- [ ] Security: hardening checklist inspired by mysql_secure_installation

## Phase 4 — Extensibility and polish

- [ ] Stable plugin API and autoload contracts
- [ ] Additional themes and accessibility options
- [ ] ShellCheck/shfmt CI, module unit tests
- [ ] Packaging (deb/rpm), man pages, docs site

## Phase 5 — Excellence

- [ ] Performance tuning helpers
- [ ] Replication awareness
- [ ] Multi-instance profiles
- [ ] Offline-friendly docs and examples

## Non-goals

- Replacing full GUI clients (phpMyAdmin, DBeaver)
- Shipping plaintext credentials
- Coupling modules directly to `mysql`/`mariadb` clients
