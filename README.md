# MariaDB Manager

Production-grade terminal MariaDB management tool.

Inspired by `mysql_secure_installation`, `nmtui`, `htop`, and `lazydocker`.

## Status

**v0.3.0 — Core Engine.** Production-ready Core (config, logger, error, theme, UI, driver facade, dispatcher, plugins, bootstrap). Modules remain skeletons. No MariaDB business logic yet.

## Architecture (summary)

```
bin/mdbm → bootstrap → dispatcher → modules/*/module.sh
                         ↘ dispatcher_driver_* → driver_* → drivers/mariadb.sh
```

- Modules never call MariaDB clients or `driver_*` directly
- All DB access goes through `dispatcher_driver_*`
- UI: `dialog` → `whiptail` → plain terminal
- Themes supply all colors; logging goes to `logs/manager.log`

Full detail: [docs/architecture.md](docs/architecture.md)

## Requirements

- Bash 5+
- Optional: `dialog` or `whiptail`
- Optional: `rsync` for faster `install.sh` (falls back to `cp`)
- MariaDB client tools (for later driver connection work)

## Quick start

```bash
chmod +x bin/mdbm manager install.sh uninstall.sh
./bin/mdbm --help
./bin/mdbm --version
./bin/mdbm --ui plain
```

Compatibility shim:

```bash
./manager --ui plain --once
```

## Install

```bash
sudo ./install.sh --prefix /usr/local
# or
./install.sh --user
```

```bash
mdbm --help
```

Uninstall:

```bash
sudo ./uninstall.sh --prefix /usr/local
./uninstall.sh --user
```

## Layout

```
bin/mdbm
manager                 # shim → bin/mdbm
config/
core/                   # bootstrap, driver facade, UI, logger, …
drivers/mariadb.sh      # MariaDB backend only
modules/<name>/module.sh
plugins/ themes/ assets/ docs/ tests/
logs/ tmp/ backups/
install.sh uninstall.sh
```

## Modules

| Package       | Responsibility             | Status   |
|---------------|----------------------------|----------|
| users         | Account management         | Skeleton |
| permissions   | Grants / privileges        | Skeleton |
| database      | Database lifecycle         | Skeleton |
| backup        | Backups                    | Skeleton |
| restore       | Restore workflows          | Skeleton |
| monitor       | Live status                | Skeleton |
| security      | Hardening checklist        | Skeleton |
| settings      | App configuration UI       | Skeleton |
| plugins       | Plugin listing             | Skeleton |
| theme         | Theme selection            | Skeleton |

## Configuration

Edit `config/config.conf` (optional `config/config.local.conf`).

Important keys:

- `DRIVER_NAME` / `DRIVER_DIR` — active database driver
- `UI_PREFERRED` — `auto|dialog|whiptail|plain`
- `THEME_NAME` — `default|dark`
- `LOG_LEVEL` — `DEBUG|INFO|WARN|ERROR`

## Driver API

Modules call only dispatcher-mediated APIs:

- `dispatcher_driver_ping` / `dispatcher_driver_query`
- `dispatcher_driver_escape` / `dispatcher_driver_quote`
- `dispatcher_driver_status` / `dispatcher_driver_name`
- `dispatcher_driver_client_available`

Do not call `driver_*` from modules.

## Plugins

Place `name.plugin.sh` in `plugins/` with `plugin_<name>_register`. Autoloaded at startup.

## Limits

- Max **350** lines per file
- Max **30** lines per function
- `snake_case`, ShellCheck-clean, documented public functions

## Development

```bash
shellcheck bin/mdbm manager install.sh uninstall.sh core/*.sh drivers/*.sh modules/*/module.sh
shfmt -w -i 2 -ci -bn bin core drivers modules
```

See [ROADMAP.md](ROADMAP.md) and [CHANGELOG.md](CHANGELOG.md).

## License

MIT — see [LICENSE](LICENSE).
