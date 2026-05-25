# FlossWare Build Tools - Quick Start

## What You Now Have

✅ **Shared build standards artifact** (`flossware-build-tools:1.3`)  
✅ **X.Y version enforcement** (no X.Y.Z allowed)  
✅ **No wildcard imports** (Checkstyle blocks `import java.util.*`)  
✅ **Final variables required** (all parameters and non-reassigned locals)  
✅ **100% test coverage** (JaCoCo enforces all metrics)  
✅ **PackageCloud.io integration** (ready to publish)  
✅ **Version bump script** (auto-increment major/minor)  
✅ **Complete project template** (copy-paste ready)  
✅ **IDE support** (IntelliJ, Eclipse, NetBeans, VS Code)

## Files Created

```
flossware-build-tools/
├── README.md                           # Full documentation
├── PACKAGECLOUD-SETUP.md               # Publishing setup guide
├── QUICK-START.md                      # This file
├── pom.xml                             # Build-tools artifact (v1.0)
├── src/main/resources/
│   ├── flossware-checkstyle.xml        # NO wildcards + style rules
│   ├── flossware-pmd-ruleset.xml       # Code quality rules
│   └── flossware-spotbugs-exclude.xml  # Bug detection config
├── .editorconfig                        # IDE formatting
├── flossware-project-template.xml      # Complete POM template
├── example-project-pom-snippet.xml     # Quick copy-paste snippet
├── bump-version.sh                     # Version increment tool
└── distribute-editorconfig.sh          # Copy .editorconfig to all projects
```

## Quick Start: Apply to Your Projects

### Option 1: Automated Refactoring (Easiest) ⭐ NEW

**Automatically transform your code to FlossWare standards:**

```bash
cd flossware-build-tools

# Auto-refactor: inline variables, fix imports, format code
./auto-refactor.sh ../jcommons

# Preview changes without applying
./auto-refactor.sh --dry-run ../jcommons

# Refactor all projects at once
./auto-refactor.sh --all

# Only fix imports
./auto-refactor.sh --imports-only ../jcommons

# Only method chaining
./auto-refactor.sh --method-chaining ../jcommons
```

**What gets automated:**
- Converts `final String x = y.trim(); return x;` → `return y.trim();`
- Removes `import java.util.*;` → specific imports
- Adds missing `@Override`, formats code, and more

**See [AUTOMATED-REFACTORING.md](AUTOMATED-REFACTORING.md) for full automation guide.**

### Option 2: Apply Configuration (Manual Fix)

```bash
# Apply FlossWare standards configuration
./rollout-standards.sh --all

# Or specific project
./rollout-standards.sh --project ../jcommons

# Preview first
./rollout-standards.sh --all --dry-run
```

**See [ROLLOUT-GUIDE.md](ROLLOUT-GUIDE.md) for complete step-by-step instructions.**

### Option 2: Create New Project with Standards

```bash
# Create a new project with all standards pre-configured
./create-new-project.sh jcache "FlossWare Caching Library"

cd ../jcache
mvn clean verify  # Should pass immediately!
```

### Option 3: Manual Setup (Existing Project)

```bash
# 1. Copy the snippet content into your pom.xml
cat flossware-build-tools/example-project-pom-snippet.xml

# 2. Paste into your project's pom.xml:
#    - <distributionManagement> goes at the top level
#    - <plugins> goes inside <build><plugins>
#    - <extensions> goes inside <build><extensions>

# 3. Copy .editorconfig
cp flossware-build-tools/.editorconfig yourproject/

# 4. Test it
cd yourproject
mvn clean verify
```

## Key FlossWare Standards

### ✓ Version Format: X.Y

```xml
<version>1.0</version>   <!-- ✓ GOOD -->
<version>1.0.0</version> <!-- ✗ FAILS BUILD -->
```

The enforcer plugin will fail builds that don't follow X.Y format.

### ✓ No Wildcard Imports

```java
import java.util.*;           // ✗ FAILS Checkstyle
import java.util.List;        // ✓ PASSES
import java.util.ArrayList;   // ✓ PASSES
```

### ✓ Final Parameters

```java
// ✗ FAILS - Missing final
public void process(String input) {
    // ...
}

// ✓ PASSES - Parameters are final
public void process(final String input) {
    // ...
}
```

### ✓ Method Chaining Over Temporaries

```java
// ✓ PREFERRED - Method chaining
return input.trim().toLowerCase().replaceAll("\\s+", " ");

// ✗ AVOID - Single-use temporaries
final String trimmed = input.trim();
final String lower = trimmed.toLowerCase();
return lower.replaceAll("\\s+", " ");
```

**Note:** See [METHOD-CHAINING.md](METHOD-CHAINING.md) for when to chain vs use variables.

### ✓ 100% Test Coverage

```bash
mvn clean verify  # Fails if coverage < 100%
```

JaCoCo enforces 100% on all metrics:
- Instruction coverage: 100%
- Branch coverage: 100%
- Line coverage: 100%
- Class coverage: 0 missed

View report: `open target/site/jacoco/index.html`

See [TEST-COVERAGE.md](TEST-COVERAGE.md) for testing patterns and gradual adoption.

### ✓ Version Bumping

```bash
# Bump minor: 1.0 -> 1.1
./flossware-build-tools/bump-version.sh minor yourproject

# Bump major: 1.5 -> 2.0
./flossware-build-tools/bump-version.sh major yourproject
```

## Publishing to PackageCloud.io

### 1. First-Time Setup

Add to `~/.m2/settings.xml`:

```xml
<settings>
  <servers>
    <server>
      <id>packagecloud-flossware</id>
      <password>YOUR_PACKAGECLOUD_API_TOKEN</password>
    </server>
  </servers>
</settings>
```

See [PACKAGECLOUD-SETUP.md](PACKAGECLOUD-SETUP.md) for details.

### 2. Deploy

```bash
mvn clean deploy
```

## Testing the Standards

```bash
# Run all checks
mvn clean verify

# Individual checks
mvn checkstyle:check    # Code style (including wildcard imports)
mvn pmd:check          # Code quality
mvn spotbugs:check     # Bug detection

# Generate reports (non-blocking)
mvn site
# Reports in: target/site/
```

## Making Standards Less Strict (Gradual Adoption)

If you have many existing violations, start with warnings instead of failures:

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-checkstyle-plugin</artifactId>
  <configuration>
    <failOnViolation>false</failOnViolation>  <!-- Just warn -->
  </configuration>
</plugin>
```

Fix violations gradually, then re-enable `<failOnViolation>true</failOnViolation>`.

## Distribute .editorconfig to All Projects

```bash
./flossware-build-tools/distribute-editorconfig.sh
```

This copies `.editorconfig` to every Java project, enabling IDE auto-formatting.

## Fix Mockito Agent Warning

If you see this warning when running tests:

```
This will no longer work in future releases of the JDK.
Please add Mockito as an agent to your build...
```

**Quick Fix - Run the auto-fix script:**

```bash
./flossware-build-tools/fix-mockito-warning.sh
```

This replaces `mockito-core` with `mockito-inline` across all projects.

See [MOCKITO-FIX.md](MOCKITO-FIX.md) for details.

## Next Steps

1. **Try it on one project first** (e.g., jcommons)
2. **Fix any violations** or adjust `failOnViolation` temporarily
3. **Set up PackageCloud credentials** (see PACKAGECLOUD-SETUP.md)
4. **Roll out to other projects** when comfortable
5. **Test publishing** with `mvn deploy`

## Questions?

- Full docs: [README.md](README.md)
- PackageCloud setup: [PACKAGECLOUD-SETUP.md](PACKAGECLOUD-SETUP.md)
- Version bumping: `./bump-version.sh --help`
