# State Ownership

## Principle

**One owner per shared resource.** If multiple bricks need access to the same state (database table, config, external service), exactly one brick owns it. All others go through that brick's interface.

## Why

- Prevents hidden coupling between bricks
- Makes dependencies explicit and auditable
- Enables independent evolution of storage internals
- Eliminates "who writes to this table?" confusion

## Rules

### 1. The owner defines the schema

If `our-db` owns connection pooling, only `our-db` creates and manages connection pools. If `our-beliefs` owns the beliefs table, only `our-beliefs` runs migrations on it.

### 2. Consumers use the interface

```python
# Good — go through the interface
from our_beliefs import BeliefStore
beliefs = await store.query("some topic")

# Bad — reach into another brick's internals
import asyncpg
conn = await asyncpg.connect(...)
rows = await conn.fetch("SELECT * FROM beliefs WHERE ...")
```

### 3. No shared mutable state between bricks

Bricks communicate through:
- Function calls (direct dependency)
- Defined interfaces (abstracted dependency)
- Message passing (loose coupling, when needed)

Never through:
- Shared global variables
- Direct database access to another brick's tables
- Filesystem paths that multiple bricks write to

### 4. Ownership is documented

Each brick's README states what state it owns:

```markdown
## State Ownership

This brick owns:
- `beliefs` table and related indexes
- `belief_embeddings` vector store
- Belief cache (in-memory, per-instance)
```

### 5. Migration ownership

The state owner is responsible for:
- Schema migrations
- Data migrations
- Backwards compatibility of stored data (within their semver contract)

## Composed Projects

Composed projects (like `valence`) wire bricks together. They may:
- Pass configuration to bricks
- Set up shared infrastructure (database connections) and inject them
- Define integration-level state (like session management across bricks)

But they should not bypass brick interfaces to manipulate brick-owned state directly.
