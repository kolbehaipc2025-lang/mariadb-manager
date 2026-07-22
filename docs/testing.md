# Tests

Module and Core tests live in this directory.

Skeleton phase: no business logic to test yet.

Suggested layout:

```
tests/
├── core/
│   ├── test_driver.sh
│   ├── test_validator.sh
│   ├── test_logger.sh
│   └── test_dispatcher.sh
├── drivers/
│   └── test_mariadb.sh
└── modules/
```

Manual smoke:

```bash
./bin/mdbm --version
./bin/mdbm --ui plain --once
```
