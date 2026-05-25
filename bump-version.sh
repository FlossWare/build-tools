#!/bin/bash
#
# Bump version for FlossWare projects (X.Y format)
#
# Usage:
#   ./bump-version.sh <major|minor> [project-dir]
#
# Examples:
#   ./bump-version.sh minor          # Bump minor in current directory (1.0 -> 1.1)
#   ./bump-version.sh major ../jcommons  # Bump major in jcommons (1.5 -> 2.0)
#

set -e

BUMP_TYPE="${1:-}"
PROJECT_DIR="${2:-.}"

if [[ ! "$BUMP_TYPE" =~ ^(major|minor)$ ]]; then
    echo "Usage: $0 <major|minor> [project-dir]"
    echo
    echo "Examples:"
    echo "  $0 minor          # 1.0 -> 1.1"
    echo "  $0 major          # 1.5 -> 2.0"
    exit 1
fi

POM_FILE="$PROJECT_DIR/pom.xml"

if [[ ! -f "$POM_FILE" ]]; then
    echo "Error: pom.xml not found at $POM_FILE"
    exit 1
fi

# Extract current version
CURRENT_VERSION=$(grep -m1 '<version>' "$POM_FILE" | sed 's/.*<version>\(.*\)<\/version>.*/\1/' | tr -d ' ')

if [[ ! "$CURRENT_VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Current version '$CURRENT_VERSION' is not in X.Y format"
    exit 1
fi

MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)

if [[ "$BUMP_TYPE" == "major" ]]; then
    NEW_MAJOR=$((MAJOR + 1))
    NEW_VERSION="$NEW_MAJOR.0"
else
    NEW_MINOR=$((MINOR + 1))
    NEW_VERSION="$MAJOR.$NEW_MINOR"
fi

echo "Bumping version: $CURRENT_VERSION -> $NEW_VERSION"
echo "Project: $PROJECT_DIR"
echo

# Update version in pom.xml (first occurrence only - the project's own version)
sed -i "0,/<version>$CURRENT_VERSION<\/version>/s//<version>$NEW_VERSION<\/version>/" "$POM_FILE"

echo "✓ Updated $POM_FILE"
echo
echo "Next steps:"
echo "  1. Review changes: git diff $POM_FILE"
echo "  2. Build and test: cd $PROJECT_DIR && mvn clean verify"
echo "  3. Commit: git commit -am 'Bump version to $NEW_VERSION'"
echo "  4. Deploy: mvn deploy"
