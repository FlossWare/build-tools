#!/bin/bash
#
# Auto-Refactor FlossWare Projects
#
# Usage:
#   ./auto-refactor.sh [options] <project-dir>
#
# Options:
#   --all                 Refactor all projects
#   --dry-run             Preview changes without applying
#   --imports-only        Only fix imports
#   --format-only         Only format code
#   --method-chaining     Focus on method chaining refactorings
#
# Examples:
#   ./auto-refactor.sh ../jcommons
#   ./auto-refactor.sh --all --dry-run
#   ./auto-refactor.sh --imports-only ../jcommons
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

DRY_RUN=false
IMPORTS_ONLY=false
FORMAT_ONLY=false
METHOD_CHAINING_ONLY=false
ALL_PROJECTS=false
TARGET_DIR=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            ALL_PROJECTS=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --imports-only)
            IMPORTS_ONLY=true
            shift
            ;;
        --format-only)
            FORMAT_ONLY=true
            shift
            ;;
        --method-chaining)
            METHOD_CHAINING_ONLY=true
            shift
            ;;
        --help|-h)
            cat <<EOF
FlossWare Auto-Refactor

Usage: $0 [options] <project-dir>

Options:
  --all                 Refactor all projects in parent directory
  --dry-run             Preview changes without applying them
  --imports-only        Only fix import statements
  --format-only         Only apply code formatting
  --method-chaining     Focus on method chaining refactorings
  --help, -h            Show this help message

Examples:
  $0 ../jcommons                    # Refactor jcommons
  $0 --all                          # Refactor all projects
  $0 --all --dry-run                # Preview all changes
  $0 --imports-only ../jcommons     # Just fix imports
  $0 --method-chaining ../jcommons  # Just inline variables

What gets refactored:
  ✓ Inline single-use variables (method chaining)
  ✓ Remove wildcard imports
  ✓ Remove unused imports
  ✓ Add @Override annotations
  ✓ Simplify boolean expressions
  ✓ Format code consistently
  ✓ Remove trailing whitespace
EOF
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

if [[ "$ALL_PROJECTS" == false && -z "$TARGET_DIR" ]]; then
    echo "Error: Must specify project directory or --all"
    echo "Usage: $0 [options] <project-dir>"
    echo "       $0 --help for more information"
    exit 1
fi

echo "========================================"
echo "FlossWare Auto-Refactor"
echo "========================================"
echo "Dry Run: $DRY_RUN"
echo

add_rewrite_plugin() {
    local pom_file="$1"

    # Check if rewrite plugin already exists
    if grep -q "rewrite-maven-plugin" "$pom_file"; then
        return 0
    fi

    echo "   📝 Adding OpenRewrite plugin to pom.xml..."

    # This is a simplified version - in production, use proper XML manipulation
    echo "   ⚠️  Please manually add OpenRewrite plugin to pom.xml"
    echo "   See: AUTOMATED-REFACTORING.md"
}

refactor_project() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")

    echo "📦 $project_name"
    echo "   Path: $project_dir"

    if [[ ! -f "$project_dir/pom.xml" ]]; then
        echo "   ⚠️  SKIPPED - No pom.xml found"
        echo
        return
    fi

    cd "$project_dir"

    # Determine which recipes to run
    local recipes=""

    if [[ "$IMPORTS_ONLY" == true ]]; then
        recipes="org.flossware.Imports"
        echo "   🔍 Mode: Imports only"
    elif [[ "$FORMAT_ONLY" == true ]]; then
        recipes="org.flossware.Formatting"
        echo "   🔍 Mode: Formatting only"
    elif [[ "$METHOD_CHAINING_ONLY" == true ]]; then
        recipes="org.flossware.MethodChaining"
        echo "   🔍 Mode: Method chaining only"
    else
        recipes="org.flossware.FlossWareStandards"
        echo "   🔍 Mode: Full refactoring"
    fi

    # Check if OpenRewrite plugin exists
    if ! grep -q "rewrite-maven-plugin" "$project_dir/pom.xml"; then
        echo "   ⚠️  OpenRewrite plugin not configured"
        echo "   💡 Add plugin configuration from AUTOMATED-REFACTORING.md"
        echo "   💡 Or run: ./configure-openrewrite.sh $project_dir"
        echo
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "   🔍 Running dry-run..."
        if mvn rewrite:dryRun -Drewrite.activeRecipes="$recipes" -q; then
            echo "   ✅ Dry-run complete"
        else
            echo "   ❌ Dry-run had issues"
        fi
    else
        echo "   🔧 Applying refactorings..."
        if mvn rewrite:run -Drewrite.activeRecipes="$recipes" -q; then
            echo "   ✅ Refactoring complete"

            # Check if there were changes
            if [[ -n $(git status -s) ]]; then
                echo "   📊 Changes made - review with: git diff"
            else
                echo "   ℹ️  No changes needed"
            fi
        else
            echo "   ❌ Refactoring failed"
        fi
    fi

    echo
}

# Process projects
if [[ "$ALL_PROJECTS" == true ]]; then
    echo "Refactoring all projects in: $PARENT_DIR"
    echo

    find "$PARENT_DIR" -maxdepth 2 -name pom.xml -type f | while read -r pom; do
        project_dir="$(dirname "$pom")"

        # Skip build-tools itself
        if [[ "$project_dir" == "$SCRIPT_DIR" ]]; then
            continue
        fi

        refactor_project "$project_dir"
    done
else
    if [[ ! -d "$TARGET_DIR" ]]; then
        echo "Error: Directory not found: $TARGET_DIR"
        exit 1
    fi

    refactor_project "$TARGET_DIR"
fi

echo "========================================"
echo "Summary"
echo "========================================"

if [[ "$DRY_RUN" == true ]]; then
    echo "Dry-run complete!"
    echo "Run without --dry-run to apply changes."
else
    echo "Refactoring complete!"
    echo
    echo "Next steps:"
    echo "  1. Review changes: git diff"
    echo "  2. Run tests: mvn clean verify"
    echo "  3. Commit: git commit -am 'Apply automated refactorings'"
fi
echo
echo "Documentation: AUTOMATED-REFACTORING.md"
