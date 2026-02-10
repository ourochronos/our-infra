#!/usr/bin/env bash
set -euo pipefail

# Check a repo against our-infra conventions.
#
# Usage: check-conventions.sh [path]
# Defaults to current directory.

TARGET="${1:-.}"
ERRORS=0
WARNINGS=0

red()    { echo -e "\033[31m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
green()  { echo -e "\033[32m$1\033[0m"; }

error()   { red   "  ERROR: $1"; ERRORS=$((ERRORS + 1)); }
warning() { yellow "  WARN:  $1"; WARNINGS=$((WARNINGS + 1)); }
ok()      { green  "  OK:    $1"; }

echo "Checking conventions for: $TARGET"
echo ""

# --- File existence checks ---
echo "=== Required Files ==="

for f in pyproject.toml Makefile .gitignore CHANGELOG.md README.md; do
    if [ -f "$TARGET/$f" ]; then
        ok "$f exists"
    else
        error "$f missing"
    fi
done

if [ -f "$TARGET/.pre-commit-config.yaml" ]; then
    ok ".pre-commit-config.yaml exists"
else
    warning ".pre-commit-config.yaml missing"
fi

echo ""

# --- pyproject.toml checks ---
echo "=== pyproject.toml ==="

if [ -f "$TARGET/pyproject.toml" ]; then
    # Build backend
    if grep -q 'hatchling' "$TARGET/pyproject.toml"; then
        ok "Build backend: hatchling"
    else
        warning "Build backend is not hatchling"
    fi

    # Python version
    if grep -q '>=3.11' "$TARGET/pyproject.toml"; then
        ok "Python >=3.11 required"
    else
        warning "Python >=3.11 not found in requires-python"
    fi

    # Ruff config
    if grep -q 'tool.ruff' "$TARGET/pyproject.toml"; then
        ok "Ruff configured"
    else
        error "No [tool.ruff] section"
    fi

    # Line length
    if grep -q 'line-length = 120' "$TARGET/pyproject.toml"; then
        ok "Line length: 120"
    else
        warning "Line length is not 120"
    fi

    # MyPy
    if grep -q 'tool.mypy' "$TARGET/pyproject.toml"; then
        ok "MyPy configured"
    else
        error "No [tool.mypy] section"
    fi

    # Pytest
    if grep -q 'tool.pytest' "$TARGET/pyproject.toml"; then
        ok "Pytest configured"
    else
        error "No [tool.pytest.ini_options] section"
    fi

    # asyncio_mode
    if grep -q 'asyncio_mode.*auto' "$TARGET/pyproject.toml"; then
        ok "asyncio_mode = auto"
    else
        warning "asyncio_mode not set to auto"
    fi
fi

echo ""

# --- Source layout ---
echo "=== Source Layout ==="

if [ -d "$TARGET/src" ]; then
    ok "src/ directory exists"
    # Check for __init__.py with __version__
    INIT_FILES=$(find "$TARGET/src" -name "__init__.py" -maxdepth 2 2>/dev/null)
    if [ -n "$INIT_FILES" ]; then
        HAS_VERSION=false
        for init in $INIT_FILES; do
            if grep -q '__version__' "$init"; then
                HAS_VERSION=true
                ok "__version__ found in $(basename "$(dirname "$init")")/__init__.py"
            fi
        done
        if [ "$HAS_VERSION" = false ]; then
            warning "No __version__ found in any __init__.py"
        fi
    else
        error "No __init__.py found in src/"
    fi
else
    error "No src/ directory"
fi

echo ""

# --- Tests ---
echo "=== Tests ==="

if [ -d "$TARGET/tests" ]; then
    ok "tests/ directory exists"
    if [ -f "$TARGET/tests/conftest.py" ]; then
        ok "conftest.py exists"
    else
        warning "tests/conftest.py missing"
    fi
    TEST_COUNT=$(find "$TARGET/tests" -name "test_*.py" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$TEST_COUNT" -gt 0 ]; then
        ok "$TEST_COUNT test file(s) found"
    else
        warning "No test files found"
    fi
else
    error "No tests/ directory"
fi

echo ""

# --- Makefile targets ---
echo "=== Makefile Targets ==="

if [ -f "$TARGET/Makefile" ]; then
    for target in lint format test clean; do
        if grep -q "^$target:" "$TARGET/Makefile"; then
            ok "make $target defined"
        else
            error "make $target not defined"
        fi
    done
fi

echo ""

# --- CHANGELOG format ---
echo "=== Changelog ==="

if [ -f "$TARGET/CHANGELOG.md" ]; then
    if grep -q 'Keep a Changelog' "$TARGET/CHANGELOG.md"; then
        ok "Keep a Changelog format"
    else
        warning "Changelog doesn't reference Keep a Changelog format"
    fi
fi

echo ""

# --- Summary ---
echo "================================"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    green "All checks passed!"
elif [ $ERRORS -eq 0 ]; then
    yellow "$WARNINGS warning(s), 0 errors"
else
    red "$ERRORS error(s), $WARNINGS warning(s)"
fi

exit $ERRORS
