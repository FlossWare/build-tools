#!/bin/bash
#
# Verify Cross-Project Dependencies Were Updated
#
# Checks that:
# 1. Maven dependencies use new artifact names (*-java)
# 2. Imports use new package names (org.flossware.{name})
#

PARENT_DIR="/home/sfloess/Development/github/FlossWare"

echo "========================================"
echo "Cross-Project Dependency Verification"
echo "========================================"
echo

# Check for old artifact names in POMs
echo "🔍 Checking for old artifact names in POMs..."
echo
for project in "$PARENT_DIR"/*-java; do
    if [[ -f "$project/pom.xml" ]]; then
        project_name=$(basename "$project")

        # Look for old j* artifact dependencies
        old_deps=$(grep -E '<artifactId>j(commons|collections|curses|classloader|cloudstorage|container|diskwipe|encrypt|eventbus|filetransfer|fs-watcher|messaging|nexus|platform|remote|resource-monitor|threadpool|vcs)</artifactId>' "$project/pom.xml" || true)

        if [[ -n "$old_deps" ]]; then
            echo "❌ $project_name has old j* dependencies:"
            echo "$old_deps"
            echo
        fi
    fi
done

# Check for old package imports in Java files
echo "🔍 Checking for old package imports in Java files..."
echo
for project in "$PARENT_DIR"/*-java; do
    if [[ -d "$project/src" ]]; then
        project_name=$(basename "$project")

        # Look for old org.flossware.j* imports
        old_imports=$(find "$project/src" -name "*.java" -exec grep -l "import org\.flossware\.j[a-z]" {} \; 2>/dev/null || true)

        if [[ -n "$old_imports" ]]; then
            echo "❌ $project_name has old org.flossware.j* imports:"
            echo "$old_imports"
            echo
        fi
    fi
done

# Find actual cross-project dependencies
echo "🔍 Finding projects with FlossWare dependencies..."
echo
for project in "$PARENT_DIR"/*-java; do
    if [[ -f "$project/pom.xml" ]]; then
        project_name=$(basename "$project")

        # Look for org.flossware dependencies
        flossware_deps=$(grep -A2 '<groupId>org\.flossware</groupId>' "$project/pom.xml" | grep '<artifactId>' | sed 's/.*<artifactId>\(.*\)<\/artifactId>.*/\1/' || true)

        if [[ -n "$flossware_deps" ]]; then
            echo "📦 $project_name depends on:"
            echo "$flossware_deps" | sed 's/^/   /'
            echo
        fi
    fi
done

echo "========================================"
echo "Summary"
echo "========================================"
echo "Check complete. Review output above for any issues."
echo
