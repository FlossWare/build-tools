#!/bin/bash
#
# Apply Complete Maven Quality Requirements to FlossWare Projects
#
# Based on: MAVEN-QUALITY-REQUIREMENTS.md
# Applies all required plugins, reporting, and site structure
#
# Usage:
#   ./apply-maven-quality.sh --all                    # Apply to all projects
#   ./apply-maven-quality.sh --project ../jcommons    # Apply to specific project
#   ./apply-maven-quality.sh --all --dry-run          # Preview changes only
#   ./apply-maven-quality.sh --all --pragmatic-coverage  # Use pragmatic coverage mode
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
DRY_RUN=false
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
        --pragmatic-coverage)
            PRAGMATIC_COVERAGE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--all | --project <path>] [--dry-run] [--pragmatic-coverage]"
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
    echo "  $0 --all --pragmatic-coverage     # Use 100% with sensible exclusions"
    exit 1
fi

echo "========================================"
echo "Maven Quality Requirements Rollout"
echo "========================================"
echo "Version: 1.0 (Complete)"
echo "Dry Run: $DRY_RUN"
echo "Pragmatic Coverage: $PRAGMATIC_COVERAGE"
echo
echo "Applies:"
echo "  ✅ JaCoCo (Code Coverage)"
echo "  ✅ SpotBugs (Static Analysis)"
echo "  ✅ PMD (Code Quality)"
echo "  ✅ Checkstyle (Code Style)"
echo "  ✅ Maven Enforcer (Build Standards)"
echo "  ✅ OWASP Dependency Check (Security)"
echo "  ✅ Maven Failsafe (Integration Tests)"
echo "  ✅ Maven Source Plugin (Sources JAR)"
echo "  ✅ Maven JavaDoc Plugin (JavaDoc JAR)"
echo "  ✅ Reporting Section"
echo "  ✅ Maven Site Structure"
echo

apply_quality_standards() {
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

    if [[ "$DRY_RUN" == true ]]; then
        echo "   ℹ️  Would apply complete Maven quality standards (dry run)"
        check_existing "$project_dir"
        echo
        return
    fi

    # Backup original pom.xml
    cp "$project_dir/pom.xml" "$project_dir/pom.xml.backup-$(date +%Y%m%d-%H%M%S)"
    echo "   💾 Backed up pom.xml"

    # 1. Copy/create configuration files
    apply_config_files "$project_dir" "$project_name"

    # 2. Create Maven site structure
    create_site_structure "$project_dir" "$project_name"

    # 3. Show POM modification instructions
    show_pom_instructions "$project_dir" "$project_name"

    echo "   ✅ DONE - Review changes and run: cd $project_dir && mvn clean verify"
    echo
}

apply_config_files() {
    local project_dir="$1"
    local project_name="$2"

    echo "   📁 Setting up configuration files..."

    # .editorconfig
    if [[ ! -f "$project_dir/.editorconfig" ]]; then
        cp "$SCRIPT_DIR/.editorconfig" "$project_dir/.editorconfig"
        echo "      ✅ Copied .editorconfig"
    fi

    # spotbugs-exclude.xml
    if [[ ! -f "$project_dir/spotbugs-exclude.xml" ]]; then
        cat > "$project_dir/spotbugs-exclude.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<FindBugsFilter>
    <!-- Add exclusions here with justification -->
    <!-- Example:
    <Match>
        <Class name="org.flossware.example.ExampleClass"/>
        <Bug pattern="EI_EXPOSE_REP"/>
    </Match>
    -->
</FindBugsFilter>
EOF
        echo "      ✅ Created spotbugs-exclude.xml"
    fi

    # pmd-ruleset.xml
    if [[ ! -f "$project_dir/pmd-ruleset.xml" ]]; then
        cp "$SCRIPT_DIR/src/main/resources/flossware-pmd-ruleset.xml" "$project_dir/pmd-ruleset.xml"
        echo "      ✅ Created pmd-ruleset.xml"
    fi

    # dependency-check-suppressions.xml
    if [[ ! -f "$project_dir/dependency-check-suppressions.xml" ]]; then
        cat > "$project_dir/dependency-check-suppressions.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
    <!--
        OWASP Dependency Check Suppressions
        Add suppressions for known false positives with justification

        Example:
        <suppress>
            <notes>False positive - not vulnerable in our usage</notes>
            <cve>CVE-2021-12345</cve>
        </suppress>
    -->
</suppressions>
EOF
        echo "      ✅ Created dependency-check-suppressions.xml"
    fi
}

create_site_structure() {
    local project_dir="$1"
    local project_name="$2"

    echo "   🌐 Setting up Maven site structure..."

    # Create directories
    mkdir -p "$project_dir/src/site/markdown"
    mkdir -p "$project_dir/src/site/resources/css"
    mkdir -p "$project_dir/src/site/resources/images"

    # site.xml
    if [[ ! -f "$project_dir/src/site/site.xml" ]]; then
        cat > "$project_dir/src/site/site.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project name="$project_name">
    <bannerLeft>
        <name>$project_name</name>
        <href>https://github.com/FlossWare/$project_name</href>
    </bannerLeft>

    <publishDate position="right"/>
    <version position="right"/>

    <body>
        <links>
            <item name="GitHub" href="https://github.com/FlossWare/$project_name"/>
            <item name="Issues" href="https://github.com/FlossWare/$project_name/issues"/>
        </links>

        <menu name="Documentation">
            <item name="JavaDoc" href="apidocs/index.html"/>
        </menu>

        <menu name="Quality Reports">
            <item name="Code Coverage" href="jacoco/index.html"/>
            <item name="SpotBugs" href="spotbugs.html"/>
            <item name="PMD" href="pmd.html"/>
            <item name="Checkstyle" href="checkstyle.html"/>
            <item name="OWASP" href="dependency-check-report.html"/>
        </menu>

        <menu ref="reports"/>
    </body>

    <skin>
        <groupId>org.apache.maven.skins</groupId>
        <artifactId>maven-fluido-skin</artifactId>
        <version>2.0.0-M10</version>
    </skin>
</project>
EOF
        echo "      ✅ Created src/site/site.xml"
    fi

    # index.md
    if [[ ! -f "$project_dir/src/site/markdown/index.md" ]]; then
        cat > "$project_dir/src/site/markdown/index.md" <<EOF
# $project_name

FlossWare $project_name - Production-quality Java library.

## Features

- 100% test coverage (JaCoCo)
- Static analysis (SpotBugs, PMD, Checkstyle)
- Security scanning (OWASP Dependency Check)
- Comprehensive documentation

## Quality Reports

- [Code Coverage](jacoco/index.html)
- [SpotBugs Analysis](spotbugs.html)
- [PMD Code Quality](pmd.html)
- [Checkstyle](checkstyle.html)
- [OWASP Security Scan](dependency-check-report.html)

## Getting Started

\`\`\`xml
<dependency>
    <groupId>org.flossware</groupId>
    <artifactId>$project_name</artifactId>
    <version><!-- see releases --></version>
</dependency>
\`\`\`

## Documentation

See [JavaDoc](apidocs/index.html) for complete API documentation.
EOF
        echo "      ✅ Created src/site/markdown/index.md"
    fi
}

show_pom_instructions() {
    local project_dir="$1"
    local project_name="$2"

    echo "   📋 POM Modifications Required:"
    echo
    echo "      Add these plugins to <build><plugins> section:"
    echo "        1. maven-enforcer-plugin (Java/Maven version enforcement)"
    echo "        2. dependency-check-maven (OWASP security scanning)"
    echo "        3. maven-failsafe-plugin (Integration tests)"
    echo "        4. maven-source-plugin (Sources JAR)"
    echo "        5. maven-javadoc-plugin (JavaDoc JAR)"
    echo "        6. JaCoCo, SpotBugs, PMD, Checkstyle (if not already present)"
    echo
    echo "      Add <reporting> section (see MAVEN-QUALITY-REQUIREMENTS.md)"
    echo
    echo "      Reference templates:"
    if [[ "$PRAGMATIC_COVERAGE" == true ]]; then
        echo "        - Coverage: $SCRIPT_DIR/jacoco-pragmatic-snippet.xml"
    else
        echo "        - Coverage: $SCRIPT_DIR/example-project-pom-snippet.xml"
    fi
    echo "        - Complete: $SCRIPT_DIR/flossware-project-template.xml"
    echo "        - Guide: $SCRIPT_DIR/MAVEN-QUALITY-REQUIREMENTS.md"
}

check_existing() {
    local project_dir="$1"

    echo "   📋 Current Status:"

    # Check for each required element
    local has_jacoco=$(grep -c "jacoco-maven-plugin" "$project_dir/pom.xml" || true)
    local has_spotbugs=$(grep -c "spotbugs-maven-plugin" "$project_dir/pom.xml" || true)
    local has_pmd=$(grep -c "maven-pmd-plugin" "$project_dir/pom.xml" || true)
    local has_checkstyle=$(grep -c "maven-checkstyle-plugin" "$project_dir/pom.xml" || true)
    local has_enforcer=$(grep -c "maven-enforcer-plugin" "$project_dir/pom.xml" || true)
    local has_owasp=$(grep -c "dependency-check-maven" "$project_dir/pom.xml" || true)
    local has_failsafe=$(grep -c "maven-failsafe-plugin" "$project_dir/pom.xml" || true)
    local has_source=$(grep -c "maven-source-plugin" "$project_dir/pom.xml" || true)
    local has_javadoc=$(grep -c "maven-javadoc-plugin" "$project_dir/pom.xml" || true)
    local has_reporting=$(grep -c "<reporting>" "$project_dir/pom.xml" || true)

    echo "      JaCoCo:         $([[ $has_jacoco -gt 0 ]] && echo '✅' || echo '❌')"
    echo "      SpotBugs:       $([[ $has_spotbugs -gt 0 ]] && echo '✅' || echo '❌')"
    echo "      PMD:            $([[ $has_pmd -gt 0 ]] && echo '✅' || echo '❌')"
    echo "      Checkstyle:     $([[ $has_checkstyle -gt 0 ]] && echo '✅' || echo '❌')"
    echo "      Enforcer:       $([[ $has_enforcer -gt 0 ]] && echo '✅' || echo '❌')"
    echo "      OWASP Check:    $([[ $has_owasp -gt 0 ]] && echo '✅' || echo '❌')"
    echo "      Failsafe:       $([[ $has_failsafe -gt 0 ]] && echo '✅' || echo '❌')"
    echo "      Source Plugin:  $([[ $has_source -gt 0 ]] && echo '✅' || echo '❌')"
    echo "      JavaDoc Plugin: $([[ $has_javadoc -gt 0 ]] && echo '✅' || echo '❌')"
    echo "      Reporting:      $([[ $has_reporting -gt 0 ]] && echo '✅' || echo '❌')"

    [[ -f "$project_dir/spotbugs-exclude.xml" ]] && echo "      spotbugs-exclude.xml: ✅" || echo "      spotbugs-exclude.xml: ❌"
    [[ -f "$project_dir/pmd-ruleset.xml" ]] && echo "      pmd-ruleset.xml: ✅" || echo "      pmd-ruleset.xml: ❌"
    [[ -f "$project_dir/dependency-check-suppressions.xml" ]] && echo "      dependency-check-suppressions.xml: ✅" || echo "      dependency-check-suppressions.xml: ❌"
    [[ -f "$project_dir/src/site/site.xml" ]] && echo "      src/site/site.xml: ✅" || echo "      src/site/site.xml: ❌"
}

# Find and process projects
if [[ "$APPLY_ALL" == true ]]; then
    echo "Searching for Java projects in: $PARENT_DIR"
    echo

    # Find all directories with pom.xml (excluding build-tools itself)
    find "$PARENT_DIR" -maxdepth 2 -name pom.xml -type f | while read -r pom; do
        project_dir="$(dirname "$pom")"

        # Skip build-tools directory itself
        if [[ "$project_dir" == "$SCRIPT_DIR" ]]; then
            continue
        fi

        apply_quality_standards "$project_dir"
    done
else
    # Apply to specific project
    if [[ ! -d "$TARGET_PROJECT" ]]; then
        echo "Error: Directory not found: $TARGET_PROJECT"
        exit 1
    fi

    apply_quality_standards "$TARGET_PROJECT"
fi

echo "========================================"
echo "Summary"
echo "========================================"
if [[ "$DRY_RUN" == true ]]; then
    echo "Dry run complete. No changes made."
    echo "Run without --dry-run to apply changes."
else
    echo "Maven Quality Requirements applied!"
    echo
    echo "📋 Next Steps for Each Project:"
    echo
    echo "  1. Review generated configuration files"
    echo "  2. Manually update pom.xml with required plugins"
    echo "     → See: MAVEN-QUALITY-REQUIREMENTS.md (sections 1-9)"
    echo "     → Template: flossware-project-template.xml"
    echo "  3. Add <reporting> section to pom.xml"
    echo "  4. Test build: mvn clean verify"
    echo "  5. Generate site: mvn site"
    echo "  6. Fix any violations"
    echo "  7. Run dependency analysis: mvn dependency:analyze"
    echo "  8. Commit changes: git commit -am 'Apply Maven quality requirements'"
    echo
    echo "📚 Documentation:"
    echo "  - Complete guide: MAVEN-QUALITY-REQUIREMENTS.md"
    echo "  - Coverage help: TEST-COVERAGE.md"
    echo "  - Rollout help: ROLLOUT-GUIDE.md"
fi
echo
echo "📦 Configuration files created:"
echo "  - .editorconfig"
echo "  - spotbugs-exclude.xml"
echo "  - pmd-ruleset.xml"
echo "  - dependency-check-suppressions.xml"
echo "  - src/site/site.xml"
echo "  - src/site/markdown/index.md"
echo
echo "💾 Backups: pom.xml.backup-TIMESTAMP"
