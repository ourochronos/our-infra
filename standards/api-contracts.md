# API Contracts

## Public Interface

Every brick defines its public API through:

1. **`interface.py`** — Abstract base classes (ABCs) defining the contract
2. **`__init__.py`** — Re-exports of the public API

```python
# src/our_db/interface.py
from abc import ABC, abstractmethod

class Store(ABC):
    """The public contract for data storage."""

    @abstractmethod
    async def get(self, key: str) -> dict | None: ...

    @abstractmethod
    async def put(self, key: str, value: dict) -> None: ...
```

```python
# src/our_db/__init__.py
from our_db.interface import Store
from our_db.postgres import PostgresStore

__all__ = ["Store", "PostgresStore"]
```

## Rules

### What's public is explicit

- Only names in `__all__` are public API
- Everything else is internal and may change without notice

### Interfaces use clean nouns

- `Store`, not `IStore` or `AbstractStore` or `StoreInterface`
- `Client`, not `BaseClient`

### Type hints are mandatory on public interfaces

```python
# Good
async def get(self, key: str) -> dict | None: ...

# Bad
async def get(self, key): ...
```

### Async by default

New interfaces should be async unless there's a clear reason not to be. Synchronous wrappers can be provided as separate implementations.

### No optional dependencies in interfaces

The interface module must not import implementation-specific dependencies. This keeps the contract light:

```python
# interface.py — only stdlib + typing imports
from abc import ABC, abstractmethod

class Store(ABC): ...
```

```python
# postgres.py — implementation imports what it needs
import asyncpg
from our_db.interface import Store

class PostgresStore(Store): ...
```

## Versioning Interfaces

When an interface needs to change:

- **Adding methods**: Add with a default implementation if possible (minor version bump)
- **Changing signatures**: Major version bump, clean break
- **Removing methods**: Major version bump, no deprecation shims

## Cross-Brick Dependencies

Bricks may depend on other bricks' interfaces:

```toml
# our-beliefs/pyproject.toml
dependencies = [
    "our-db>=1.0,<2.0",
]
```

Pin to major version ranges. Bricks own their interfaces and consumers trust the semver contract.
