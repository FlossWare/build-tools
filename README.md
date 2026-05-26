# FlossWare Build Tools

Shared build configuration files for enforcing code standards across FlossWare Java projects.

## What's Included

- **Checkstyle** - Code style and formatting rules
  - ✓ NO wildcard imports
  - ✓ Final parameters required (NOT local variables)
  - ✓ Naming conventions, whitespace, braces
- **PMD** - Code quality and best practices
  - ✓ Detects unnecessary temporary variables
  - ✓ Enforces method chaining preference
- **SpotBugs** - Bug detection and security checks
- **JaCoCo** - 100% test coverage enforcement
  - ✓ Instruction coverage
  - ✓ Branch coverage
  - ✓ Line coverage
  - ✓ Class coverage
- **EditorConfig** - IDE formatting settings
- **Version Enforcement** - Enforces X.Y version format (no X.Y.Z)
- **PackageCloud Publishing** - Ready for packagecloud.io deployment
- **Mockito Fix** - Eliminates JDK agent warnings
- **IDE Support** - IntelliJ, Eclipse, NetBeans, VS Code

## Quick Start - Apply to Your Projects

### Option 1: Automated Refactoring (Easiest) ⭐ NEW

**Automatically converts your code to FlossWare standards:**

```bash
# Auto-refactor a project (inline variables, fix imports, format code)
cd flossware-build-tools
./auto-refactor.sh ../jcommons

# Preview changes first
./auto-refactor.sh --dry-run ../jcommons

# Refactor all projects
./auto-refactor.sh --all
```

**What gets automated:**
- ✅ Inline single-use variables → method chaining
- ✅ Remove wildcard imports
- ✅ Add missing @Override annotations
- ✅ Format code consistently
- ✅ Remove unused code

See [AUTOMATED-REFACTORING.md](AUTOMATED-REFACTORING.md) for details.

### Option 2: Apply Standards Configuration

```bash
# Apply FlossWare build configuration to projects
./rollout-standards.sh --all

# Or apply to specific project
./rollout-standards.sh --project ../jcommons

# Preview changes first (dry run)
./rollout-standards.sh --all --dry-run
```

See [ROLLOUT-GUIDE.md](ROLLOUT-GUIDE.md) for complete instructions.

### Manual Installation

#### Step 1: Install the Build Tools Artifact Locally

From this directory, run:

```bash
mvn clean install
```

This publishes the configuration files to your local Maven repository.

### Step 2: Add to Your Project's POM

Add these plugins to your project's `pom.xml`:

```xml
<build>
    <plugins>
        <!-- Checkstyle -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-checkstyle-plugin</artifactId>
            <version>3.3.1</version>
            <dependencies>
                <dependency>
                    <groupId>org.flossware</groupId>
                    <artifactId>flossware-build-tools</artifactId>
                    <version>1.0</version>
                </dependency>
                <dependency>
                    <groupId>com.puppycrawl.tools</groupId>
                    <artifactId>checkstyle</artifactId>
                    <version>10.12.5</version>
                </dependency>
            </dependencies>
            <configuration>
                <configLocation>flossware-checkstyle.xml</configLocation>
                <consoleOutput>true</consoleOutput>
                <failsOnError>true</failsOnError>
                <violationSeverity>warning</violationSeverity>
            </configuration>
            <executions>
                <execution>
                    <phase>validate</phase>
                    <goals>
                        <goal>check</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>

        <!-- PMD -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-pmd-plugin</artifactId>
            <version>3.21.2</version>
            <dependencies>
                <dependency>
                    <groupId>org.flossware</groupId>
                    <artifactId>flossware-build-tools</artifactId>
                    <version>1.0</version>
                </dependency>
            </dependencies>
            <configuration>
                <rulesets>
                    <ruleset>flossware-pmd-ruleset.xml</ruleset>
                </rulesets>
                <printFailingErrors>true</printFailingErrors>
                <failOnViolation>true</failOnViolation>
            </configuration>
            <executions>
                <execution>
                    <phase>validate</phase>
                    <goals>
                        <goal>check</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>

        <!-- SpotBugs -->
        <plugin>
            <groupId>com.github.spotbugs</groupId>
            <artifactId>spotbugs-maven-plugin</artifactId>
            <version>4.8.2.0</version>
            <dependencies>
                <dependency>
                    <groupId>org.flossware</groupId>
                    <artifactId>flossware-build-tools</artifactId>
                    <version>1.0</version>
                </dependency>
            </dependencies>
            <configuration>
                <excludeFilterFile>flossware-spotbugs-exclude.xml</excludeFilterFile>
                <effort>Max</effort>
                <threshold>Low</threshold>
                <failOnError>true</failOnError>
            </configuration>
            <executions>
                <execution>
                    <phase>verify</phase>
                    <goals>
                        <goal>check</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

### Step 3: Copy EditorConfig

Copy the `.editorconfig` file to the root of each project:

```bash
cp flossware-build-tools/.editorconfig /path/to/your-project/
```

## Usage

### Run All Checks

```bash
mvn clean verify
```

### Run Individual Checks

```bash
mvn checkstyle:check
mvn pmd:check
mvn spotbugs:check
```

### Generate Reports (without failing)

```bash
mvn checkstyle:checkstyle
mvn pmd:pmd
mvn spotbugs:spotbugs
```

Reports are generated in `target/site/`.

## Customization Per Project

If a project needs different rules, you can:

1. **Override specific rules** in the project's POM
2. **Create a local config file** that supplements the shared one
3. **Adjust severity levels** (`failOnViolation`, `violationSeverity`)

### Example: Make Checks Non-Blocking

```xml
<configuration>
    <failOnViolation>false</failOnViolation>
</configuration>
```

## Updating Standards

1. Edit the configuration files in `src/main/resources/`
2. Increment the version in `pom.xml`
3. Run `mvn clean install`
4. Update the version in dependent projects

## FlossWare Standards

### Version Format: X.Y Only

All FlossWare projects use **X.Y** versioning (e.g., 1.0, 2.5), **NOT** X.Y.Z.

The enforcer plugin will fail your build if you use the wrong format:

```bash
# ✓ Valid versions
1.0
2.5
10.3

# ✗ Invalid versions  
1.0.0
2.5.1
1.0-SNAPSHOT  # For snapshots, use in distributionManagement instead
```

### Wildcard Imports Blocked

Checkstyle enforces explicit imports. This will fail:

```java
import java.util.*;  // ✗ FAILS
```

Use specific imports:

```java
import java.util.List;     // ✓ PASSES
import java.util.ArrayList; // ✓ PASSES
```

### Final Parameters Required

All method parameters must be `final`:

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

### Method Chaining Preferred

Prefer chaining methods over single-use temporary variables:

```java
// ✓ PREFERRED - Method chaining
public String normalize(final String input) {
    return input.trim()
                .toLowerCase()
                .replaceAll("\\s+", " ");
}

// ✗ AVOID - Unnecessary temporaries
public String normalize(final String input) {
    final String trimmed = input.trim();
    final String lower = trimmed.toLowerCase();
    return lower.replaceAll("\\s+", " ");
}
```

See [METHOD-CHAINING.md](METHOD-CHAINING.md) for complete style guide.

### 100% Test Coverage Required

JaCoCo enforces 100% test coverage on all metrics:

```bash
mvn clean verify  # Fails if coverage < 100%
```

Coverage report: `target/site/jacoco/index.html`

**Metrics checked:**
- Instruction coverage: 100%
- Branch coverage: 100%
- Line coverage: 100%
- Class coverage: 0 missed

See [TEST-COVERAGE.md](TEST-COVERAGE.md) for:
- How to achieve 100% coverage
- Common testing patterns
- Gradual adoption strategies
- IDE integration

### Mockito Configuration (No Agent Warning)

**Problem:** "This will no longer work in future releases of the JDK. Please add Mockito as an agent..."

**Solution:** Use `mockito-inline` instead of `mockito-core`:

```xml
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-inline</artifactId>
    <version>5.2.0</version>
    <scope>test</scope>
</dependency>
```

**Bulk Fix Across All Projects:**

```bash
./flossware-build-tools/fix-mockito-warning.sh
```

See [MOCKITO-FIX.md](MOCKITO-FIX.md) for detailed instructions and alternatives.

## Version Management

### Bump Version

Use the provided script to increment versions:

```bash
# Bump minor version (1.0 -> 1.1)
./flossware-build-tools/bump-version.sh minor path/to/project

# Bump major version (1.5 -> 2.0)
./flossware-build-tools/bump-version.sh major path/to/project

# From within a project directory
cd jcommons
../flossware-build-tools/bump-version.sh minor
```

The script automatically:
- Validates current version format
- Updates `pom.xml`
- Provides next-step instructions

## Publishing to PackageCloud.io

FlossWare projects are configured to publish to PackageCloud.io.

### First-Time Setup

See [PACKAGECLOUD-SETUP.md](PACKAGECLOUD-SETUP.md) for detailed instructions.

Quick setup:

```bash
# Add to ~/.m2/settings.xml
<server>
  <id>packagecloud-flossware</id>
  <password>YOUR_PACKAGECLOUD_API_TOKEN</password>
</server>
```

### Deploy

```bash
# Deploy to PackageCloud
mvn clean deploy
```

## IDE Support

FlossWare standards work with all major Java IDEs:

- **IntelliJ IDEA** - Full support with auto-fix
- **Eclipse** - Full support with save actions
- **NetBeans** - Full support with hints and quick fix - See [NETBEANS-SETUP.md](NETBEANS-SETUP.md)
- **VS Code** - Full support with Java extensions

Each IDE can auto-add `final` modifiers, format code, and show coverage inline.

## Configuration Files

### Code Quality
- `flossware-checkstyle.xml` - Style rules (naming, formatting, NO wildcards, final enforcement)
- `flossware-pmd-ruleset.xml` - Code quality rules
- `flossware-spotbugs-exclude.xml` - Bug patterns to ignore
- `.editorconfig` - IDE formatting preferences

### Project Templates
- `flossware-project-template.xml` - Complete project template with all standards (includes JaCoCo)
- `example-project-pom-snippet.xml` - Quick copy-paste snippet (strict 100% coverage)
- **`jacoco-pragmatic-snippet.xml`** - **⭐ NEW: JaCoCo with sensible exclusions (pragmatic 100%)**
- **`jacoco-pragmatic-excludes.xml`** - **⭐ NEW: Reference list of standard exclusions**

### Scripts
- `bump-version.sh` - Version increment script
- `distribute-editorconfig.sh` - Copy .editorconfig to all projects
- `fix-mockito-warning.sh` - Bulk fix Mockito agent warnings
- `rollout-standards.sh` - Apply standards to projects (supports `--pragmatic-coverage`)
- `auto-refactor.sh` - Automated code refactoring
- `verify-all-projects.sh` - Check compliance across all projects
- `create-new-project.sh` - Generate new projects with standards

### Other
- `mockito-agent-config.xml` - Mockito agent configuration options

## Documentation

- `README.md` - This file, complete usage guide
- `QUICK-START.md` - Quick reference
- `CHANGELOG.md` - Version history
- **`AUTOMATED-REFACTORING.md`** - **⭐ Automated code transformations (NEW!)**
- **`COVERAGE-RECOMMENDATIONS.md`** - **⭐ Project-specific coverage guidelines (NEW!)**
- `ROLLOUT-GUIDE.md` - Organization rollout guide
- `METHOD-CHAINING.md` - Method chaining style guide (prefer chaining over temporaries)
- `FINAL-VARIABLES.md` - Final parameters standard (parameters only, not locals)
- `TEST-COVERAGE.md` - 100% coverage guide and best practices
- `NETBEANS-SETUP.md` - NetBeans IDE configuration
- `MOCKITO-FIX.md` - Fix Mockito JDK agent warnings
- `PACKAGECLOUD-SETUP.md` - Publishing to PackageCloud.io

## Contributing

We welcome contributions to FlossWare Build Tools! Whether you're reporting bugs, suggesting features, or submitting code improvements, your input helps make this project better for everyone.

### How to Contribute

1. **Report Issues** - Found a bug or have a feature request? Open an issue on GitHub
2. **Submit Pull Requests** - Fork the repository, make your changes, and submit a PR
3. **Improve Documentation** - Help clarify setup guides, add examples, or fix typos
4. **Share Feedback** - Let us know how you're using these tools in your projects

### Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold this code. Please report unacceptable behavior to scot.floess@gmail.com.

### Development Guidelines

- Follow the same FlossWare standards that this project enforces
- Add tests for new functionality
- Update documentation for user-facing changes
- Run `mvn clean verify` before submitting PRs

## License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE](LICENSE) file for details.

**What this means:**
- ✓ You can freely use, modify, and distribute this software
- ✓ You can use it in commercial projects
- ✓ Any modifications must also be licensed under GPL v3.0
- ✓ You must include the license and copyright notice

For more information, visit [https://www.gnu.org/licenses/gpl-3.0.html](https://www.gnu.org/licenses/gpl-3.0.html)
