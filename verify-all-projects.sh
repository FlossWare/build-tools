#!/bin/bash
#
# Verify FlossWare Standards Compliance Across All Projects
#
# Usage:
#   ./verify-all-projects.sh                    # Check all projects
#   ./verify-all-projects.sh --verbose          # Show detailed output
#   ./verify-all-projects.sh --report report.md # Save report to file
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
VERBOSE=false
REPORT_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --report)
            REPORT_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--verbose] [--report <file>]"
            exit 1
            ;;
    esac
done

echo "========================================"
echo "FlossWare Standards Compliance Check"
echo "========================================"
echo "Checking projects in: $PARENT_DIR"
echo

TOTAL=0
PASSING=0
FAILING=0

# Initialize report file if requested
if [[ -n "$REPORT_FILE" ]]; then
    cat > "$REPORT_FILE" <<EOF
# FlossWare Standards Compliance Report

Generated: $(date)

| Project | Status | Coverage | Issues |
|---------|--------|----------|--------|
EOF
fi

verify_project() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")

    TOTAL=$((TOTAL + 1))

    echo "📦 $project_name"

    # Check if has pom.xml
    if [[ ! -f "$project_dir/pom.xml" ]]; then
        echo "   ⚠️  No pom.xml - SKIPPED"
        echo
        return
    fi

    # Check if standards applied
    if ! grep -q "flossware-build-tools" "$project_dir/pom.xml" 2>/dev/null; then
        echo "   ❌ Standards not applied"
        FAILING=$((FAILING + 1))

        if [[ -n "$REPORT_FILE" ]]; then
            echo "| $project_name | ❌ Not Applied | N/A | Standards not configured |" >> "$REPORT_FILE"
        fi
        echo
        return
    fi

    # Run verification
    echo "   🔍 Running: mvn clean verify..."

    if [[ "$VERBOSE" == true ]]; then
        cd "$project_dir" && mvn clean verify
        BUILD_RESULT=$?
    else
        cd "$project_dir" && mvn clean verify > /tmp/mvn-verify-$project_name.log 2>&1
        BUILD_RESULT=$?
    fi

    # Parse results
    local coverage="N/A"
    local issues=""

    if [[ -f "$project_dir/target/site/jacoco/index.html" ]]; then
        # Extract coverage from JaCoCo report
        coverage=$(grep -oP 'Total.*?(\d+)%' "$project_dir/target/site/jacoco/index.html" | grep -oP '\d+%' | head -1 || echo "N/A")
    fi

    if [[ $BUILD_RESULT -eq 0 ]]; then
        echo "   ✅ PASS - All checks passed"
        echo "   📊 Coverage: $coverage"
        PASSING=$((PASSING + 1))

        if [[ -n "$REPORT_FILE" ]]; then
            echo "| $project_name | ✅ PASS | $coverage | None |" >> "$REPORT_FILE"
        fi
    else
        echo "   ❌ FAIL - Checks failed"
        echo "   📊 Coverage: $coverage"

        # Parse common issues
        if grep -q "Checkstyle violations" /tmp/mvn-verify-$project_name.log 2>/dev/null; then
            issues+="Checkstyle, "
        fi
        if grep -q "PMD violations" /tmp/mvn-verify-$project_name.log 2>/dev/null; then
            issues+="PMD, "
        fi
        if grep -q "Coverage check failed" /tmp/mvn-verify-$project_name.log 2>/dev/null; then
            issues+="Coverage, "
        fi
        if grep -q "SpotBugs violations" /tmp/mvn-verify-$project_name.log 2>/dev/null; then
            issues+="SpotBugs, "
        fi

        # Remove trailing comma
        issues=${issues%, }

        if [[ -z "$issues" ]]; then
            issues="Build failure (see log)"
        fi

        echo "   ⚠️  Issues: $issues"
        echo "   📄 Log: /tmp/mvn-verify-$project_name.log"
        FAILING=$((FAILING + 1))

        if [[ -n "$REPORT_FILE" ]]; then
            echo "| $project_name | ❌ FAIL | $coverage | $issues |" >> "$REPORT_FILE"
        fi
    fi

    echo
}

# Find and verify all projects
find "$PARENT_DIR" -maxdepth 2 -name pom.xml -type f | while read -r pom; do
    project_dir="$(dirname "$pom")"

    # Skip the build-tools directory itself
    if [[ "$project_dir" == "$SCRIPT_DIR" ]]; then
        continue
    fi

    verify_project "$project_dir"
done

echo "========================================"
echo "Summary"
echo "========================================"
echo "Total Projects: $TOTAL"
echo "✅ Passing: $PASSING"
echo "❌ Failing: $FAILING"

if [[ $FAILING -eq 0 ]]; then
    echo
    echo "🎉 All projects comply with FlossWare standards!"
else
    echo
    echo "⚠️  $FAILING project(s) need attention"
    echo
    echo "To fix failures:"
    echo "  1. Check logs in /tmp/mvn-verify-*.log"
    echo "  2. Run 'mvn clean verify' in each failing project"
    echo "  3. See ROLLOUT-GUIDE.md for help"
fi

if [[ -n "$REPORT_FILE" ]]; then
    echo
    cat >> "$REPORT_FILE" <<EOF

## Summary

- Total Projects: $TOTAL
- ✅ Passing: $PASSING
- ❌ Failing: $FAILING

$(if [[ $FAILING -eq 0 ]]; then echo "🎉 All projects compliant!"; else echo "⚠️ $FAILING project(s) need fixes"; fi)
EOF
    echo "📊 Report saved to: $REPORT_FILE"
fi

# Exit with failure if any projects failing
if [[ $FAILING -gt 0 ]]; then
    exit 1
fi
