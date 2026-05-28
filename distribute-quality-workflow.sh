#!/bin/bash
#
# Distribute Quality Gate Workflow to All FlossWare Projects
#
# Usage:
#   ./distribute-quality-workflow.sh --all
#   ./distribute-quality-workflow.sh --project ../jcommons
#   ./distribute-quality-workflow.sh --all --dry-run
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
DRY_RUN=false
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
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--all | --project <path>] [--dry-run]"
            exit 1
            ;;
    esac
done

if [[ "$APPLY_ALL" == false && -z "$TARGET_PROJECT" ]]; then
    echo "Error: Must specify --all or --project <path>"
    exit 1
fi

echo "========================================"
echo "Quality Gate Workflow Distribution"
echo "========================================"
echo "Dry Run: $DRY_RUN"
echo
echo "Distributes GitHub Actions workflow:"
echo "  ✅ Automated quality monitoring"
echo "  ✅ Auto-creates issues for failures"
echo "  ✅ PR comments with quality metrics"
echo "  ✅ Daily security scans"
echo

distribute_workflow() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")

    echo "📦 Processing: $project_name"

    # Check if project has pom.xml
    if [[ ! -f "$project_dir/pom.xml" ]]; then
        echo "   ⚠️  SKIPPED - Not a Maven project"
        echo
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "   ℹ️  Would copy quality-gate.yml (dry run)"
        if [[ -f "$project_dir/.github/workflows/quality-gate.yml" ]]; then
            echo "   ⚠️  Workflow already exists (would overwrite)"
        fi
        echo
        return
    fi

    # Create .github/workflows directory
    mkdir -p "$project_dir/.github/workflows"

    # Copy workflow
    cp "$SCRIPT_DIR/.github/workflows/quality-gate.yml" "$project_dir/.github/workflows/quality-gate.yml"
    echo "   ✅ Copied quality-gate.yml"

    # Create README in .github directory
    cat > "$project_dir/.github/README.md" <<'EOF'
# GitHub Workflows

## quality-gate.yml

Automated quality monitoring for FlossWare projects.

### What It Does

- ✅ Runs on every push/PR
- ✅ Executes all Maven quality checks
- ✅ Comments quality metrics on PRs
- ✅ Automatically creates issues when quality gates fail:
  - Code coverage drops below threshold
  - SpotBugs finds bugs
  - PMD detects violations
  - Checkstyle errors
  - Security vulnerabilities (OWASP)
- ✅ Daily security scans (2 AM UTC)

### Quality Gates

| Tool | Threshold | Fail Condition |
|------|-----------|---------------|
| JaCoCo | 93% instruction, 86% branch | Below threshold |
| SpotBugs | 0 bugs | Any bugs found |
| PMD | 0 violations | Any violations |
| Checkstyle | 0 errors | Any errors |
| OWASP | 0 critical/high | Critical or high vulnerabilities |

### Issue Labels

Auto-created issues are tagged with:
- `quality-gate` - All quality gate issues
- `automated` - Auto-created
- Specific: `coverage`, `spotbugs`, `pmd`, `checkstyle`, `security`

### Configuration

Edit `quality-gate.yml` to:
- Adjust coverage thresholds
- Change schedule
- Modify issue templates
- Add custom checks

### Resources

- [Maven Quality Requirements](../build-tools/MAVEN-QUALITY-REQUIREMENTS.md)
- [Test Coverage Guide](../build-tools/TEST-COVERAGE.md)
- [FlossWare Build Tools](https://github.com/FlossWare/build-tools)
EOF
    echo "   ✅ Created .github/README.md"

    echo "   ✅ DONE"
    echo
}

# Find and process projects
if [[ "$APPLY_ALL" == true ]]; then
    echo "Searching for Maven projects in: $PARENT_DIR"
    echo

    find "$PARENT_DIR" -maxdepth 2 -name pom.xml -type f | while read -r pom; do
        project_dir="$(dirname "$pom")"

        # Skip build-tools itself
        if [[ "$project_dir" == "$SCRIPT_DIR" ]]; then
            continue
        fi

        distribute_workflow "$project_dir"
    done
else
    # Apply to specific project
    if [[ ! -d "$TARGET_PROJECT" ]]; then
        echo "Error: Directory not found: $TARGET_PROJECT"
        exit 1
    fi

    distribute_workflow "$TARGET_PROJECT"
fi

echo "========================================"
echo "Summary"
echo "========================================"
if [[ "$DRY_RUN" == true ]]; then
    echo "Dry run complete. No changes made."
else
    echo "Quality gate workflow distributed!"
    echo
    echo "📋 What Was Added:"
    echo "  - .github/workflows/quality-gate.yml"
    echo "  - .github/README.md"
    echo
    echo "📋 Next Steps:"
    echo "  1. Review workflow in each project"
    echo "  2. Commit and push to enable:"
    echo "     git add .github/"
    echo "     git commit -m 'Add automated quality gate workflow'"
    echo "     git push"
    echo "  3. GitHub Actions will run automatically on next push"
    echo "  4. Issues will be auto-created when quality gates fail"
    echo
    echo "💡 Tips:"
    echo "  - View workflow runs: GitHub → Actions tab"
    echo "  - Auto-created issues have 'quality-gate' label"
    echo "  - Daily security scans run at 2 AM UTC"
    echo "  - PR comments show quality metrics"
fi
echo
