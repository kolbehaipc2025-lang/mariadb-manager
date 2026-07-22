# Architecture

MariaDB Manager is an enterprise-grade modular Bash 5+ terminal application.

## Design principles

- **Core owns infrastructure** — config, logging, UI, themes, validation, dispatch, drivers
- **Dispatcher mediates drivers** — modules never call `driver_*` directly
- **Drivers own database dialects** — MariaDB specifics live only in `drivers/`
- **Modules own one responsibility** — never call `mysql`/`mariadb` clients
- **Plugins extend** — autoloaded from `plugins/*.plugin.sh`
- **Strict limits** — ≤350 lines/file, ≤30 lines/function, `set -Eeuo pipefail`

## Layout

```
mariadb-manage/
├── bin/mdbm
├── manager                    # shim → bin/mdbm
├── config/config.conf
├── core/
│   ├── bootstrap.sh           # phased Core Engine startup
│   ├── common.sh
│   ├── config.sh              # dynamic config + env overrides
│   ├── dispatcher.sh          # menu + driver gateway
│   ├── driver.sh              # driver facade (internal)
│   ├── error.sh
│   ├── helpers.sh
│   ├── logger.sh
│   ├── module_loader.sh
│   ├── plugin_loader.sh
│   ├── theme.sh
│   ├── ui.sh / ui_plain.sh
│   ├── validator.sh
│   └── version.sh
├── drivers/mariadb.sh
├── modules/<name>/module.sh
├── plugins/ themes/ …
```

## Runtime flow

1. `bin/mdbm` parses CLI flags
2. `bootstrap_init` phases: foundation → config → services → extensions
3. `dispatcher_run` presents the main menu
4. Modules run under dispatcher context (`MM_DISPATCH_MODULE`)
5. Database work: `module → dispatcher_driver_* → driver_* → drivers/mariadb.sh`

## Core Engine map

| Engine | File | Production features |
|--------|------|---------------------|
| Bootstrap | `bootstrap.sh` | Phased init, health, shutdown |
| Config | `config.sh` | File + local + `MDBM_*` env, reload, get/set |
| Logger | `logger.sh` | Levels, components, masking, rotation, console modes |
| Error | `error.sh` | Strict mode, codes, last-error, warn/raise/exit |
| Theme | `theme.sh` | File themes, `NO_COLOR`, get/list/reload |
| UI | `ui.sh` | dialog → whiptail → plain; menu/input/password |
| Driver | `driver.sh` | Hook verification, load/ready guards (stubs OK) |
| Dispatcher | `dispatcher.sh` | Menu loop + **only** driver gateway for modules |
| Plugins | `plugin_loader.sh` | Autoload, disable list, name validation |

## Dispatcher driver API (modules)

| API | Purpose |
|-----|---------|
| `dispatcher_driver_ping` | Connectivity probe |
| `dispatcher_driver_query` | Query execution |
| `dispatcher_driver_escape` | Literal escaping |
| `dispatcher_driver_quote` | Identifier quoting |
| `dispatcher_driver_status` | Readiness |
| `dispatcher_driver_name` | Active driver name |
| `dispatcher_driver_client_available` | Client binary present |

Privileged calls require an active module context (inside `dispatcher_dispatch`).

## Module package contract

```bash
module_<id>_init() { module_register "<id>" "Label" "module_<id>_run"; }
module_<id>_run()  {
  # UI: ui_*
  # DB: dispatcher_driver_*   # NEVER driver_* or mysql/mariadb
}
```

## Security boundaries

- No plaintext passwords in logs (`MASK_PASSWORDS=yes`)
- Dangerous ops require confirmation (`CONFIRM_DANGEROUS=yes`)
- Identifiers validated before quoting
- Modules cannot reach the driver outside dispatcher context
