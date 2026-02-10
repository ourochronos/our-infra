# our-infra

Infrastructure and conventions for ourochronos bricks.

This repo is the source of truth for how ourochronos projects are structured, built, tested, and released. It provides:

- **Standards** — Documented conventions for naming, versioning, APIs, testing, and state ownership
- **Templates** — Ready-to-use scaffolds for new bricks and composed projects
- **Workflows** — Reusable GitHub Actions for CI/CD
- **Scripts** — Tooling to scaffold repos and check convention compliance

## Quick Start

### Create a new brick

```bash
./scripts/new-brick.sh our-mypackage "Description of what it does"
```

This creates a GitHub repo, applies the brick template, and pushes the initial commit.

### Check a repo against conventions

```bash
./scripts/check-conventions.sh ~/projects/our-mypackage
```

## Structure

```
our-infra/
├── standards/           # Convention documentation
│   ├── naming.md        # Repo, package, module naming rules
│   ├── versioning.md    # Semver, changelog, deprecation policy
│   ├── api-contracts.md # Interface design and versioning
│   ├── testing.md       # Test ownership, markers, coverage
│   └── state-ownership.md # One owner per shared resource
├── templates/
│   ├── brick/           # Template for our-* repos
│   └── composed/        # Template for composed projects
├── workflows/           # Reusable GitHub Actions
│   ├── lint.yml         # Linting workflow (ruff + mypy)
│   ├── test.yml         # Test workflow (with optional postgres)
│   └── release.yml      # Tag-based release workflow
└── scripts/
    ├── new-brick.sh     # Scaffold a new brick
    └── check-conventions.sh # Validate convention compliance
```

## Conventions Summary

| Scope | Convention | Example |
|-------|-----------|---------|
| Brick repos | `our-<name>` | `our-db`, `our-beliefs` |
| Composed projects | No prefix | `valence`, `bob` |
| Python packages | Underscore of repo name | `our_db` |
| Interfaces | Clean nouns | `Store`, `Client` |
| Implementations | Descriptive | `PostgresStore` |
| Versions | Semver with `v` prefix | `v1.2.3` |

## Tooling Decisions

- **Build backend**: hatchling (PEP 517, modern)
- **Dependency management**: uv in CI
- **Linting + formatting**: ruff (no separate black)
- **Type checking**: mypy with `disallow_untyped_defs = true`
- **Line length**: 120
- **Python**: >= 3.11
- **Testing**: pytest with asyncio_mode=auto
- **Pre-commit**: trailing-whitespace, ruff, mypy, bandit

## License

MIT
