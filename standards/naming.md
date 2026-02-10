# Naming Conventions

## Repository Names

| Scope | Convention | Example |
|-------|-----------|---------|
| Brick repos | `our-<name>` | `our-db`, `our-beliefs`, `our-infra` |
| Composed project repos | No prefix | `valence`, `bob` |

Bricks are small, focused, reusable components. Composed projects combine bricks into deployable systems.

## Python Packages

- Package name = underscore version of repo name
- `our-db` → `our_db`
- `our-beliefs` → `our_beliefs`

## Internal Modules

- Use `package.module` structure
- `our_db.connection`, `our_beliefs.store`
- Keep modules focused — one clear responsibility each

## Interfaces and Implementations

| Kind | Convention | Example |
|------|-----------|---------|
| Interfaces / ABCs | Clean nouns | `Store`, `Client`, `Transport` |
| Implementations | Descriptive prefix | `PostgresStore`, `HttpClient`, `NatsTransport` |

Interfaces live in the brick's top-level or `interface.py`. Implementations live in their own modules.

## Import Style

```python
# Public API — import from package root
from our_db import Store, PostgresStore

# Internal — import from module
from our_db.connection import ConnectionPool
```

## File Naming

- Python files: `snake_case.py`
- No abbreviations in filenames unless universally understood (`db` is fine, `blf` is not)
- Test files: `test_<module>.py`
- Config files: standard names (`pyproject.toml`, `Makefile`, etc.)
