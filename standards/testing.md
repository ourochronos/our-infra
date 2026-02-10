# Testing

## Test Ownership

| Project type | Primary test focus | Secondary |
|-------------|-------------------|-----------|
| Bricks (`our-*`) | Unit tests | Narrow integration tests for their own dependencies |
| Composed projects | Integration tests | End-to-end tests |

Bricks test their own logic thoroughly. Composed projects test that bricks work together correctly.

## Test Structure

```
tests/
├── conftest.py          # Shared fixtures
├── test_interface.py    # Tests for the public contract
├── test_postgres.py     # Tests for specific implementations
└── integration/
    └── test_lifecycle.py  # Integration tests (require external services)
```

## Markers

All repos use these standard pytest markers:

```python
# conftest.py
import pytest

def pytest_configure(config):
    config.addinivalue_line("markers", "unit: Unit tests (no external deps)")
    config.addinivalue_line("markers", "integration: Integration tests (require services)")
    config.addinivalue_line("markers", "slow: Slow tests (>5s)")
```

Default test run executes unit tests only:

```bash
make test        # Unit tests only
make test-int    # Integration tests only
make test-all    # Everything
```

## Fixtures

### Brick-level fixtures

Each brick provides fixtures for its own testing in `conftest.py`. These fixtures are also available to composed projects that depend on the brick.

### Common patterns

```python
@pytest.fixture
async def store():
    """In-memory store for unit tests."""
    return InMemoryStore()

@pytest.fixture
async def pg_store(database_url):
    """Real postgres store for integration tests."""
    store = PostgresStore(database_url)
    await store.connect()
    yield store
    await store.disconnect()
```

## Coverage

- Branch coverage enabled (`branch = true`)
- Coverage reports show missing lines (`show_missing = true`)
- No global coverage threshold enforced — bricks set their own based on maturity
- New code should have tests; coverage is a guideline, not a gate

## Async Testing

All repos use `pytest-asyncio` with `asyncio_mode = "auto"`:

```python
# This just works — no @pytest.mark.asyncio needed
async def test_get_returns_none_for_missing_key(store):
    result = await store.get("nonexistent")
    assert result is None
```

## Test Naming

- Test files: `test_<module>.py`
- Test functions: `test_<behavior>` — describe what's being tested, not how
- Good: `test_get_returns_none_for_missing_key`
- Bad: `test_get_1`, `test_store`

## What Not to Test

- Don't test implementation details that could change without affecting behavior
- Don't test third-party library behavior
- Don't write tests that just duplicate the implementation logic
