# Changelog

All notable changes to MariaDB Manager are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned

- Module business logic (users, permissions, database, backup, restore, monitor, security)
- MariaDB driver connection and query implementation
- Plugin API documentation

## [0.3.0] - 2026-07-22

### Added

- Production Core Engine: config reload/env overrides, log rotation & components,
  error last-state, theme NO_COLOR, UI password prompts, plugin disable list
- Dispatcher-mediated driver gateway (`dispatcher_driver_*`)
- Phased bootstrap with health helpers
- `core/ui_plain.sh` split for modular UI

### Changed

- Modules must use `dispatcher_driver_*` (never `driver_*` directly)
- Architecture documentation updated for Core Engine contracts

## [0.2.0] - 2026-07-22

### Changed

- Enterprise modular architecture refactor
- MariaDB specifics moved to `drivers/mariadb.sh`
- `core/mariadb.sh` replaced by `core/driver.sh` facade
- Modules reorganized into `modules/<name>/module.sh` packages
- Primary entrypoint is now `bin/mdbm` (`manager` kept as shim)

### Added

- `core/error.sh`, `core/helpers.sh`, `core/validator.sh`, `core/version.sh`, `core/dispatcher.sh`
- `docs/architecture.md`
- File limit 350 lines / function limit 30 lines

## [0.1.0] - 2026-07-22

### Added

- Project skeleton and production architecture
- Core engines: config, logger, theme, UI, plugin loader, bootstrap
- Empty modules and installer
- Documentation baseline

[Unreleased]: https://github.com/example/mariadb-manager/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/example/mariadb-manager/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/example/mariadb-manager/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/example/mariadb-manager/releases/tag/v0.1.0
