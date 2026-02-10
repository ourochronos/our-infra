#!/usr/bin/env bash
set -euo pipefail

# Scaffold a new our-* brick from the template.
#
# Usage: new-brick.sh <brick-name> [description]
# Example: new-brick.sh our-db "Database connectivity brick"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$INFRA_DIR/templates/brick"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <brick-name> [description]"
    echo "Example: $0 our-db \"Database connectivity brick\""
    exit 1
fi

PROJECT_NAME="$1"
DESCRIPTION="${2:-An ourochronos brick}"
PACKAGE_NAME="${PROJECT_NAME//-/_}"

# Validate naming
if [[ ! "$PROJECT_NAME" =~ ^our- ]]; then
    echo "ERROR: Brick repos must be named our-<name>"
    exit 1
fi

TARGET_DIR="${PROJECTS_DIR:-$HOME/projects}/$PROJECT_NAME"

if [ -d "$TARGET_DIR" ]; then
    echo "ERROR: $TARGET_DIR already exists"
    exit 1
fi

echo "Creating brick: $PROJECT_NAME"
echo "  Package: $PACKAGE_NAME"
echo "  Target: $TARGET_DIR"
echo "  Description: $DESCRIPTION"
echo ""

# Create GitHub repo
echo "Creating GitHub repo ourochronos/$PROJECT_NAME..."
PARENT_DIR="$(dirname "$TARGET_DIR")"
cd "$PARENT_DIR"
gh repo create "ourochronos/$PROJECT_NAME" --public --description "$DESCRIPTION" --clone

# Copy template files (non-directory)
echo "Applying brick template..."

# Copy standard files
for f in pyproject.toml Makefile .pre-commit-config.yaml CHANGELOG.md README.md .gitignore; do
    if [ -f "$TEMPLATE_DIR/$f" ]; then
        sed -e "s/{{project_name}}/$PROJECT_NAME/g" \
            -e "s/{{package_name}}/$PACKAGE_NAME/g" \
            -e "s/{{description}}/$DESCRIPTION/g" \
            "$TEMPLATE_DIR/$f" > "$TARGET_DIR/$f"
    fi
done

# Copy GitHub workflows
mkdir -p "$TARGET_DIR/.github/workflows"
for f in "$TEMPLATE_DIR/.github/workflows/"*; do
    if [ -f "$f" ]; then
        sed -e "s/{{project_name}}/$PROJECT_NAME/g" \
            -e "s/{{package_name}}/$PACKAGE_NAME/g" \
            -e "s/{{description}}/$DESCRIPTION/g" \
            "$f" > "$TARGET_DIR/.github/workflows/$(basename "$f")"
    fi
done

# Create source directory
mkdir -p "$TARGET_DIR/src/$PACKAGE_NAME"
for f in "$TEMPLATE_DIR/src/{{package_name}}/"*; do
    if [ -f "$f" ]; then
        sed -e "s/{{project_name}}/$PROJECT_NAME/g" \
            -e "s/{{package_name}}/$PACKAGE_NAME/g" \
            -e "s/{{description}}/$DESCRIPTION/g" \
            "$f" > "$TARGET_DIR/src/$PACKAGE_NAME/$(basename "$f")"
    fi
done

# Create tests directory
mkdir -p "$TARGET_DIR/tests"
for f in "$TEMPLATE_DIR/tests/"*; do
    if [ -f "$f" ]; then
        sed -e "s/{{project_name}}/$PROJECT_NAME/g" \
            -e "s/{{package_name}}/$PACKAGE_NAME/g" \
            -e "s/{{description}}/$DESCRIPTION/g" \
            "$f" > "$TARGET_DIR/tests/$(basename "$f")"
    fi
done

# Initial commit
cd "$TARGET_DIR"
git add -A
git commit -m "Initial brick scaffold from our-infra template

Project: $PROJECT_NAME
Package: $PACKAGE_NAME"
git branch -m master main 2>/dev/null || true
git push -u origin main

echo ""
echo "Brick $PROJECT_NAME created successfully!"
echo "  Repo: https://github.com/ourochronos/$PROJECT_NAME"
echo "  Local: $TARGET_DIR"
echo ""
echo "Next steps:"
echo "  cd $TARGET_DIR"
echo "  make dev"
echo "  make test"
