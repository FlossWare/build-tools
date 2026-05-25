#!/bin/bash
#
# Distribute .editorconfig to all FlossWare Java projects
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
EDITORCONFIG="$SCRIPT_DIR/.editorconfig"

if [[ ! -f "$EDITORCONFIG" ]]; then
    echo "Error: .editorconfig not found at $EDITORCONFIG"
    exit 1
fi

echo "Distributing .editorconfig to Java projects..."
echo

# Find all directories with pom.xml (excluding this build-tools project)
find "$PARENT_DIR" -name pom.xml -type f | while read -r pom; do
    project_dir="$(dirname "$pom")"

    # Skip the build-tools directory itself
    if [[ "$project_dir" == "$SCRIPT_DIR" ]]; then
        continue
    fi

    # Copy .editorconfig
    cp "$EDITORCONFIG" "$project_dir/.editorconfig"
    echo "✓ Copied to $(basename "$project_dir")"
done

echo
echo "Done! .editorconfig distributed to all Java projects."
