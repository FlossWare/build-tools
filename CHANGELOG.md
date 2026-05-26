# FlossWare Build Tools - Changelog

## Version 1.4 (Unreleased)

### Added - Pragmatic Coverage (Major Feature) ⭐
- **Added** [COVERAGE-RECOMMENDATIONS.md](COVERAGE-RECOMMENDATIONS.md) - Project-specific coverage guidelines
  - Analyzes all FlossWare projects
  - Recommends Strict 100%, Pragmatic 100%, or 90-95% per project
  - Explains when to use each coverage approach
  - Provides specific commands for each project
- **Added** `jacoco-pragmatic-snippet.xml` - JaCoCo configuration with sensible exclusions
  - Maintains 100% coverage on business logic
  - Excludes main methods, utility constructors, pure DTOs
  - Pre-configured for CLI applications and abstraction libraries
- **Added** `jacoco-pragmatic-excludes.xml` - Reference list of standard exclusions
  - Application entry points (*Application, Main, *CLI)
  - Utility class constructors (*Utils, *Helper, *Constants)
  - Pure data classes (DTOs, Records, Entities)
  - Generated code (builders, Lombok)
- **Added** `--pragmatic-coverage` flag to `rollout-standards.sh`
  - Applies pragmatic coverage configuration automatically
  - Alternative to `--skip-coverage-enforcement` for gradual adoption
  - Maintains high standards while acknowledging practical limitations
- **Updated** [TEST-COVERAGE.md](TEST-COVERAGE.md) - Added pragmatic coverage guidance
  - Coverage philosophy section (Strict vs Pragmatic vs Gradual)
  - When to use exclusions vs full 100%
  - Safe exclusion patterns
  - Examples for CLI applications

### Added - Community & Licensing
- **Added** [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - Contributor Covenant Code of Conduct v2.1
  - Establishes community guidelines for contributions
  - Contact: scot.floess@gmail.com for reporting issues
- **Added** [LICENSE](LICENSE) - GNU General Public License v3.0
  - Clarifies licensing terms for using and distributing build tools
  - Ensures open-source compliance for all users
- **Updated** [README.md](README.md) - Added Contributing and License sections
  - How to contribute to the project
  - Code of conduct reference
  - GPL v3.0 license summary
- **Updated** [QUICK-START.md](QUICK-START.md) - Added contributing and license information

## Version 1.3 (2026-05-24)

### Added - **Automated Refactoring** ⭐ Major Feature
- **Added** [AUTOMATED-REFACTORING.md](AUTOMATED-REFACTORING.md) - Complete guide to automated code transformations
  - OpenRewrite integration for safe, automated refactoring
  - Inline single-use variables into method chains
  - Remove wildcard imports automatically
  - Add missing @Override annotations
  - Format code consistently
  - Multiple refactoring modes (full, imports-only, format-only, method-chaining)
- **Added** `auto-refactor.sh` - Automated refactoring script
  - `--dry-run` for preview
  - `--all` for all projects
  - `--imports-only`, `--format-only`, `--method-chaining` for targeted refactoring
- **Added** `configure-openrewrite.sh` - Helper to set up OpenRewrite in projects
- **Added** OpenRewrite recipe definitions in `src/main/resources/META-INF/rewrite/flossware.yml`
  - `org.flossware.FlossWareStandards` - Full FlossWare refactoring
  - `org.flossware.MethodChaining` - Method chaining focus
  - `org.flossware.Imports` - Import fixes
  - `org.flossware.Formatting` - Code formatting

### Added - Organization Rollout Tools
- **Added** [ROLLOUT-GUIDE.md](ROLLOUT-GUIDE.md) - Complete guide to applying standards across your org
  - Big Bang vs Gradual rollout strategies
  - Step-by-step instructions per project
  - CI/CD integration examples
  - Troubleshooting guide
- **Added** `rollout-standards.sh` - Automate applying standards to projects
  - `--all` mode for all projects
  - `--project` mode for specific project
  - `--dry-run` for preview
  - `--skip-coverage-enforcement` for gradual adoption
- **Added** `verify-all-projects.sh` - Check compliance across all projects
  - Generates compliance report
  - Shows coverage and issues per project
- **Added** `create-new-project.sh` - Generate new projects with standards pre-configured
  - Complete Maven project structure
  - All standards already applied
  - Sample code with 100% coverage
  - Git repository initialized

### Changed - **BREAKING CHANGE**: Method Chaining Philosophy
- **Removed** `FinalLocalVariables` requirement - local variables no longer require `final`
- **Added** method chaining preference - prefer dotted method calls over single-use temporaries
- **Kept** `FinalParameters` requirement - all method/constructor/catch parameters still must be `final`
- **Added** PMD rules to detect unnecessary temporaries:
  - `UnnecessaryLocalBeforeReturn` - flags single-use variables before return
  - `UnusedLocalVariable` - flags unused variables
- **Added** [METHOD-CHAINING.md](METHOD-CHAINING.md) - Complete style guide
- **Updated** FINAL-VARIABLES.md to reflect parameters-only approach

### Philosophy Shift

**Before (v1.1-1.2):** Every non-reassigned variable must be `final`
```java
final String trimmed = input.trim();
final String lower = trimmed.toLowerCase();
return lower;
```

**After (v1.3):** Prefer method chaining, `final` on parameters only
```java
return input.trim().toLowerCase();
```

This promotes more fluent, readable code with less visual clutter.

See [METHOD-CHAINING.md](METHOD-CHAINING.md) for complete guide on when to chain vs when to use variables.

---

## Version 1.2 (2026-05-24)

### Added
- **100% Test Coverage Enforcement** - JaCoCo plugin configured to require 100% coverage
  - Instruction coverage: 100%
  - Branch coverage: 100%
  - Line coverage: 100%
  - Class coverage: 0 missed
  - See [TEST-COVERAGE.md](TEST-COVERAGE.md) for guide and best practices
- **NetBeans IDE Support** - Complete NetBeans configuration guide
  - Code templates with `final` modifiers
  - Checkstyle hints configuration
  - JaCoCo coverage visualization
  - Maven integration
  - See [NETBEANS-SETUP.md](NETBEANS-SETUP.md)
- **Enhanced IDE Documentation** - Updated FINAL-VARIABLES.md with NetBeans and VS Code setup

### Changed
- Updated all example files and templates to reference version 1.2
- Template and snippet now include JaCoCo plugin configuration
- Enhanced README with coverage and IDE support sections
- Enhanced QUICK-START with coverage examples

---

## Version 1.1 (2026-05-24)

### Added
- **Final Variables Enforcement** - Checkstyle now requires `final` on all parameters and non-reassigned local variables
  - `FinalParameters` rule for method/constructor/catch/foreach parameters
  - `FinalLocalVariables` rule for local variables
  - See [FINAL-VARIABLES.md](FINAL-VARIABLES.md) for details and IDE setup
- **Mockito Agent Warning Fix** - Documentation and tooling to eliminate JDK agent warnings
  - Added [MOCKITO-FIX.md](MOCKITO-FIX.md) with solutions
  - Added `fix-mockito-warning.sh` script for bulk fixes
  - Added `mockito-agent-config.xml` with configuration examples
  - Template updated to use `mockito-inline` by default

### Changed
- Updated all example files and templates to reference version 1.1
- Enhanced README with final variables and Mockito sections
- Enhanced QUICK-START with final variables examples

### Notes
- **Breaking Change**: Existing code may have many violations due to final variable enforcement
- See [FINAL-VARIABLES.md](FINAL-VARIABLES.md) for gradual adoption strategies
- IDE auto-fix can handle most violations automatically

---

## Version 1.0 (2026-05-24)

### Initial Release

#### Features
- **Checkstyle Configuration** - Code style enforcement
  - NO wildcard imports (AvoidStarImport)
  - Naming conventions
  - Whitespace and formatting rules
  - Method/parameter size limits
- **PMD Configuration** - Code quality rules
  - Best practices
  - Design patterns
  - Error-prone code detection
- **SpotBugs Configuration** - Bug detection
  - Security issues
  - Null pointer bugs
  - Resource leaks
- **Version Enforcement** - X.Y format required (no X.Y.Z)
  - Maven enforcer plugin configuration
  - `bump-version.sh` script for version management
- **PackageCloud.io Integration** - Publishing support
  - Distribution management pre-configured
  - Wagon extension included
  - Documentation in [PACKAGECLOUD-SETUP.md](PACKAGECLOUD-SETUP.md)
- **EditorConfig** - IDE formatting settings
  - `distribute-editorconfig.sh` script to deploy across projects

#### Documentation
- [README.md](README.md) - Complete usage documentation
- [QUICK-START.md](QUICK-START.md) - Quick reference guide
- [PACKAGECLOUD-SETUP.md](PACKAGECLOUD-SETUP.md) - Publishing setup

#### Templates
- `flossware-project-template.xml` - Complete project POM template
- `example-project-pom-snippet.xml` - Quick copy-paste snippet

#### Scripts
- `bump-version.sh` - Increment major/minor versions
- `distribute-editorconfig.sh` - Deploy .editorconfig to all projects

---

## Version History Summary

| Version | Date | Key Changes |
|---------|------|-------------|
| 1.3 | 2026-05-24 | **BREAKING**: Method chaining over temporaries, final parameters only (not locals) |
| 1.2 | 2026-05-24 | Added 100% test coverage enforcement (JaCoCo), NetBeans IDE support |
| 1.1 | 2026-05-24 | Added final variables enforcement, Mockito fix tooling |
| 1.0 | 2026-05-24 | Initial release with Checkstyle, PMD, SpotBugs, version enforcement, PackageCloud support |

---

## Upgrading

### From 1.0 to 1.1

1. **Update dependency version** in your `pom.xml`:
   ```xml
   <dependency>
       <groupId>org.flossware</groupId>
       <artifactId>flossware-build-tools</artifactId>
       <version>1.1</version>  <!-- was 1.0 -->
   </dependency>
   ```

2. **Install new version**:
   ```bash
   cd flossware-build-tools
   mvn clean install
   ```

3. **Expect new violations** due to final variable enforcement

4. **Choose adoption strategy**:
   - **Aggressive**: Use IDE auto-fix to add `final` everywhere
   - **Gradual**: Temporarily suppress final checks, fix incrementally
   - See [FINAL-VARIABLES.md](FINAL-VARIABLES.md) for details

5. **Optional - Fix Mockito warnings**:
   ```bash
   ./flossware-build-tools/fix-mockito-warning.sh
   ```

### Testing After Upgrade

```bash
# Build with new standards
mvn clean verify

# Check for violations
mvn checkstyle:check

# Generate report to see what needs fixing
mvn checkstyle:checkstyle
open target/site/checkstyle.html
```
