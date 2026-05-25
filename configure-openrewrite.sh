#!/bin/bash
#
# Add OpenRewrite Plugin to Project
#
# Usage:
#   ./configure-openrewrite.sh <project-dir>
#   ./configure-openrewrite.sh --all
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <project-dir>"
    echo "       $0 --all"
    exit 1
fi

OPENREWRITE_PLUGIN='
            <!-- OpenRewrite: Automated Refactoring -->
            <plugin>
                <groupId>org.openrewrite.maven</groupId>
                <artifactId>rewrite-maven-plugin</artifactId>
                <version>5.20.0</version>
                <configuration>
                    <activeRecipes>
                        <recipe>org.flossware.FlossWareStandards</recipe>
                    </activeRecipes>
                </configuration>
                <dependencies>
                    <dependency>
                        <groupId>org.openrewrite.recipe</groupId>
                        <artifactId>rewrite-java-format</artifactId>
                        <version>2.0.0</version>
                    </dependency>
                    <dependency>
                        <groupId>org.openrewrite.recipe</groupId>
                        <artifactId>rewrite-static-analysis</artifactId>
                        <version>1.0.0</version>
                    </dependency>
                </dependencies>
            </plugin>'

add_openrewrite() {
    local project_dir="$1"
    local pom_file="$project_dir/pom.xml"
    local project_name=$(basename "$project_dir")

    echo "📦 $project_name"

    if [[ ! -f "$pom_file" ]]; then
        echo "   ⚠️  No pom.xml found - SKIPPED"
        echo
        return
    fi

    if grep -q "rewrite-maven-plugin" "$pom_file"; then
        echo "   ℹ️  OpenRewrite already configured - SKIPPED"
        echo
        return
    fi

    # Backup
    cp "$pom_file" "$pom_file.backup"

    echo "   📝 Adding OpenRewrite configuration..."
    echo "   💾 Backed up to pom.xml.backup"
    echo
    echo "   ⚠️  Manual Step Required:"
    echo "   Add this plugin to <build><plugins> in $pom_file:"
    echo
    cat <<EOF
$OPENREWRITE_PLUGIN
EOF
    echo
    echo "   Or use your IDE to add the plugin"
    echo
}

if [[ "$1" == "--all" ]]; then
    echo "Configuring OpenRewrite for all projects..."
    echo

    find "$PARENT_DIR" -maxdepth 2 -name pom.xml -type f | while read -r pom; do
        project_dir="$(dirname "$pom")"

        if [[ "$project_dir" == "$SCRIPT_DIR" ]]; then
            continue
        fi

        add_openrewrite "$project_dir"
    done
else
    add_openrewrite "$1"
fi

echo "========================================"
echo "Configuration Instructions"
echo "========================================"
echo
echo "OpenRewrite plugin configuration shown above."
echo
echo "After adding the plugin:"
echo "  1. Test dry-run: mvn rewrite:dryRun"
echo "  2. Apply refactorings: mvn rewrite:run"
echo "  3. Review changes: git diff"
echo
echo "Or use the auto-refactor script:"
echo "  ./auto-refactor.sh ../your-project"
echo
echo "Documentation: AUTOMATED-REFACTORING.md"
