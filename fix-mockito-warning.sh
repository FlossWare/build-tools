#!/bin/bash
#
# Fix Mockito JDK Agent Warning Across FlossWare Projects
#
# This script replaces mockito-core with mockito-inline to eliminate the warning:
# "This will no longer work in future releases of the JDK.
#  Please add Mockito as an agent to your build..."
#
# Usage:
#   ./fix-mockito-warning.sh [project-dir]
#
# Examples:
#   ./fix-mockito-warning.sh           # Fix all projects in parent directory
#   ./fix-mockito-warning.sh ../jcommons  # Fix specific project
#

set -e

PROJECT_DIR="${1:-..}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "Mockito Warning Fix for FlossWare"
echo "========================================"
echo
echo "Searching for projects with mockito-core in: $PROJECT_DIR"
echo

FIXED_COUNT=0
SKIPPED_COUNT=0

# Find all pom.xml files
find "$PROJECT_DIR" -name pom.xml -type f | while read -r pom; do
    # Skip the build-tools directory itself
    if [[ "$pom" == *"flossware-build-tools"* ]]; then
        continue
    fi

    # Check if this POM uses mockito-core
    if grep -q "<artifactId>mockito-core</artifactId>" "$pom"; then
        project_name=$(basename "$(dirname "$pom")")

        echo "📦 Found mockito-core in: $project_name"
        echo "   File: $pom"

        # Check if it's already using mockito-inline
        if grep -q "<artifactId>mockito-inline</artifactId>" "$pom"; then
            echo "   ⚠️  SKIPPED - Already has mockito-inline (check for duplicates)"
            SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
            echo
            continue
        fi

        # Create backup
        cp "$pom" "$pom.backup"

        # Replace mockito-core with mockito-inline
        sed -i 's/<artifactId>mockito-core<\/artifactId>/<artifactId>mockito-inline<\/artifactId>/g' "$pom"

        # Check if replacement was successful
        if grep -q "<artifactId>mockito-inline</artifactId>" "$pom"; then
            echo "   ✅ FIXED - Replaced mockito-core with mockito-inline"
            echo "   💾 Backup saved: $pom.backup"
            FIXED_COUNT=$((FIXED_COUNT + 1))
        else
            echo "   ❌ FAILED - Could not replace, restoring backup"
            mv "$pom.backup" "$pom"
        fi

        echo
    fi
done

echo "========================================"
echo "Summary"
echo "========================================"
echo "Projects fixed: $FIXED_COUNT"
echo "Projects skipped: $SKIPPED_COUNT"
echo
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Test each project: cd <project> && mvn clean test"
echo "  3. If successful, remove backups: find $PROJECT_DIR -name 'pom.xml.backup' -delete"
echo "  4. If problems, restore: for f in $PROJECT_DIR/*/pom.xml.backup; do mv \"\$f\" \"\${f%.backup}\"; done"
echo
echo "See MOCKITO-FIX.md for more information"
