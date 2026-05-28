#!/bin/bash
#
# Reset All Renamed Projects to Version 1.0
#
# Since the renamed projects are essentially "new" artifacts
# (different artifactId, different packages), start at 1.0
#

set -e

PARENT_DIR="/home/sfloess/Development/github/FlossWare"

PROJECTS=(
    "commons-java"
    "collections-java"
    "curses-java"
    "classloader-java"
    "cloudstorage-java"
    "container-java"
    "diskwipe-java"
    "encrypt-java"
    "eventbus-java"
    "filetransfer-java"
    "fs-watcher-java"
    "messaging-java"
    "nexus-java"
    "platform-java"
    "remote-java"
    "resource-monitor-java"
    "threadpool-java"
    "vcs-java"
    "build-tools"
)

echo "========================================"
echo "Reset Version to 1.0"
echo "========================================"
echo "Updating ${#PROJECTS[@]} projects to version 1.0"
echo

for project in "${PROJECTS[@]}"; do
    project_dir="$PARENT_DIR/$project"

    echo "📦 $project"

    if [[ ! -d "$project_dir" ]]; then
        echo "   ⚠️  SKIPPED - Directory not found"
        echo
        continue
    fi

    cd "$project_dir"

    # Update version in POM using xmlstarlet
    xmlstarlet ed --inplace \
        -N pom="http://maven.apache.org/POM/4.0.0" \
        -u "/pom:project/pom:version" \
        -v "1.0" \
        pom.xml

    echo "   ✅ Version updated to 1.0"

    # Commit
    git add pom.xml
    git commit -m "Reset version to 1.0

The renamed artifact ($project) is essentially a new project
with a different artifactId and package names.

Starting at version 1.0 makes more sense than 2.0 since:
- New artifact name (different Maven coordinates)
- New package names (different imports)
- Treating as a fresh 1.0 release

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

    echo "   ✅ Committed"

    # Push
    if git push; then
        echo "   ✅ Pushed"
    else
        echo "   ⚠️  Push failed - may need manual push"
    fi

    echo
done

echo "========================================"
echo "Complete"
echo "========================================"
echo "All projects reset to version 1.0"
echo
echo "Rationale:"
echo "  - New artifact names = new artifacts"
echo "  - New package names = fresh start"
echo "  - Version 1.0 indicates initial release of *-java variants"
echo
