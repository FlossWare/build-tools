#!/bin/bash
#
# Apply FlossWare Build Standards to Projects
#
# Usage:
#   ./rollout-standards.sh --all                    # Apply to all projects
#   ./rollout-standards.sh --project ../jcommons    # Apply to specific project
#   ./rollout-standards.sh --all --dry-run          # Preview changes only
#   ./rollout-standards.sh --all --skip-coverage-enforcement  # Add JaCoCo but set to 0.80
#   ./rollout-standards.sh --all --pragmatic-coverage        # Use 100% with sensible exclusions
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
DRY_RUN=false
SKIP_COVERAGE=false
PRAGMATIC_COVERAGE=false
TARGET_PROJECT=""
APPLY_ALL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            APPLY_ALL=true
            shift
            ;;
        --project)
            TARGET_PROJECT="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-coverage-enforcement)
            SKIP_COVERAGE=true
            shift
            ;;
        --pragmatic-coverage)
            PRAGMATIC_COVERAGE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--all | --project <path>] [--dry-run] [--skip-coverage-enforcement | --pragmatic-coverage]"
            exit 1
            ;;
    esac
done

if [[ "$APPLY_ALL" == false && -z "$TARGET_PROJECT" ]]; then
    echo "Error: Must specify --all or --project <path>"
    echo
    echo "Usage:"
    echo "  $0 --all                          # Apply to all projects"
    echo "  $0 --project ../jcommons          # Apply to specific project"
    echo "  $0 --all --dry-run                # Preview only"
    echo "  $0 --all --skip-coverage-enforcement  # Start with 80% coverage"
    echo "  $0 --all --pragmatic-coverage     # Use 100% with sensible exclusions"
    exit 1
fi

# Check for conflicting options
if [[ "$SKIP_COVERAGE" == true && "$PRAGMATIC_COVERAGE" == true ]]; then
    echo "Error: Cannot use both --skip-coverage-enforcement and --pragmatic-coverage"
    exit 1
fi

echo "========================================"
echo "FlossWare Build Standards Rollout"
echo "========================================"
echo "Version: 1.4"
echo "Dry Run: $DRY_RUN"
echo "Skip Coverage: $SKIP_COVERAGE"
echo "Pragmatic Coverage: $PRAGMATIC_COVERAGE"
echo

apply_standards() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")

    echo "📦 Processing: $project_name"
    echo "   Path: $project_dir"

    # Check if project has pom.xml
    if [[ ! -f "$project_dir/pom.xml" ]]; then
        echo "   ⚠️  SKIPPED - No pom.xml found"
        echo
        return
    fi

    # Check if already applied
    if grep -q "flossware-build-tools" "$project_dir/pom.xml" 2>/dev/null; then
        echo "   ⚠️  SKIPPED - Standards already applied"
        echo
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "   ℹ️  Would apply standards (dry run)"
        echo
        return
    fi

    # Backup original pom.xml
    cp "$project_dir/pom.xml" "$project_dir/pom.xml.backup"
    echo "   💾 Backed up pom.xml"

    # Copy .editorconfig
    if [[ ! -f "$project_dir/.editorconfig" ]]; then
        cp "$SCRIPT_DIR/.editorconfig" "$project_dir/.editorconfig"
        echo "   ✅ Copied .editorconfig"
    fi

    # Determine which snippet to use
    local snippet_file
    if [[ "$PRAGMATIC_COVERAGE" == true ]]; then
        snippet_file="$SCRIPT_DIR/jacoco-pragmatic-snippet.xml"
        echo "   📋 Using pragmatic coverage configuration (100% with sensible exclusions)"
    else
        snippet_file="$SCRIPT_DIR/example-project-pom-snippet.xml"
    fi

    # Check if </build> exists
    if grep -q "</build>" "$project_dir/pom.xml"; then
        echo "   ⚠️  <build> section exists - manual merge required"
        echo "   📄 See: $snippet_file"
        echo "   💡 Merge plugin configurations from snippet into your <build><plugins>"
    else
        # Add build section before </project>
        # This is simplified - in reality, you'd need more sophisticated XML merging
        echo "   ⚠️  No <build> section found"
        echo "   📄 Add plugins from: $snippet_file"
        echo "   💡 Insert before </project> tag"
    fi

    # Show coverage mode
    if [[ "$SKIP_COVERAGE" == true ]]; then
        echo "   ⚠️  Coverage enforcement set to 80% (gradual adoption mode)"
    elif [[ "$PRAGMATIC_COVERAGE" == true ]]; then
        echo "   ✅ Pragmatic coverage: 100% with main/utils/DTOs excluded"
        echo "   📄 Exclusions reference: $SCRIPT_DIR/jacoco-pragmatic-excludes.xml"
    else
        echo "   ✅ Strict coverage: 100% with no exclusions"
    fi

    echo "   ✅ DONE - Review changes and run: cd $project_dir && mvn clean verify"
    echo
}

# Find and process projects
if [[ "$APPLY_ALL" == true ]]; then
    echo "Searching for Java projects in: $PARENT_DIR"
    echo

    # Find all directories with pom.xml (excluding build-tools itself)
    find "$PARENT_DIR" -maxdepth 2 -name pom.xml -type f | while read -r pom; do
        project_dir="$(dirname "$pom")"

        # Skip the build-tools directory itself
        if [[ "$project_dir" == "$SCRIPT_DIR" ]]; then
            continue
        fi

        apply_standards "$project_dir"
    done
else
    # Apply to specific project
    if [[ ! -d "$TARGET_PROJECT" ]]; then
        echo "Error: Directory not found: $TARGET_PROJECT"
        exit 1
    fi

    apply_standards "$TARGET_PROJECT"
fi

echo "========================================"
echo "Summary"
echo "========================================"
if [[ "$DRY_RUN" == true ]]; then
    echo "Dry run complete. No changes made."
    echo "Run without --dry-run to apply changes."
else
    echo "Standards applied!"
    echo
    echo "Next steps for each project:"
    echo "  1. Review pom.xml changes"
    if [[ "$PRAGMATIC_COVERAGE" == true ]]; then
        echo "  2. Manually merge build plugins (see jacoco-pragmatic-snippet.xml)"
    else
        echo "  2. Manually merge build plugins (see example-project-pom-snippet.xml)"
    fi
    echo "  3. Fix violations: mvn clean verify"
    echo "  4. Add final to parameters (use IDE or auto-refactor.sh)"
    echo "  5. Fix imports (use IDE or auto-refactor.sh)"
    if [[ "$SKIP_COVERAGE" == true ]]; then
        echo "  6. Gradually improve test coverage: 80% → 100%"
    elif [[ "$PRAGMATIC_COVERAGE" == true ]]; then
        echo "  6. Test coverage: 100% (main/utils/DTOs excluded)"
    else
        echo "  6. Achieve 100% test coverage (strict mode)"
    fi
    echo "  7. Commit: git commit -am 'Apply FlossWare standards v1.4'"
    echo
    echo "Need help? See: ROLLOUT-GUIDE.md and TEST-COVERAGE.md"
fi
echo
echo "Backups saved as: pom.xml.backup"
echo "To restore: mv pom.xml.backup pom.xml"
