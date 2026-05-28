# Maven Quality Requirements for FlossWare Projects

Comprehensive Maven configuration requirements based on production quality audits of FlossWare projects (especially jcommons). This document defines the complete quality tooling setup for professional Java libraries.

---

## Table of Contents

1. [Quality Tool Requirements](#quality-tool-requirements)
2. [Build Lifecycle Integration](#build-lifecycle-integration)
3. [Reporting Configuration](#reporting-configuration)
4. [Maven Site Structure](#maven-site-structure)
5. [Dependency Management](#dependency-management)
6. [CI/CD Integration](#cicd-integration)
7. [Complete POM Template](#complete-pom-template)

---

## Quality Tool Requirements

### 1. JaCoCo (Code Coverage) - REQUIRED ✅

**Minimum Configuration:**
```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.12</version>
    <executions>
        <execution>
            <id>prepare-agent</id>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
        <execution>
            <id>check</id>
            <phase>verify</phase>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <rules>
                    <rule>
                        <element>BUNDLE</element>
                        <limits>
                            <!-- Minimum 93% instruction coverage -->
                            <limit>
                                <counter>INSTRUCTION</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.93</minimum>
                            </limit>
                            <!-- Minimum 86% branch coverage -->
                            <limit>
                                <counter>BRANCH</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.86</minimum>
                            </limit>
                            <!-- No missed classes -->
                            <limit>
                                <counter>CLASS</counter>
                                <value>MISSEDCOUNT</value>
                                <maximum>0</maximum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

**Why Required:**
- Enforces test coverage standards
- Prevents untested code
- Foundation library quality baseline

---

### 2. SpotBugs (Static Analysis) - REQUIRED ✅

**Minimum Configuration:**
```xml
<plugin>
    <groupId>com.github.spotbugs</groupId>
    <artifactId>spotbugs-maven-plugin</artifactId>
    <version>4.9.8.3</version>
    <configuration>
        <effort>Max</effort>
        <threshold>Low</threshold>
        <failOnError>true</failOnError>
        <xmlOutput>true</xmlOutput>
        <excludeFilterFile>spotbugs-exclude.xml</excludeFilterFile>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

**Required File:** `spotbugs-exclude.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<FindBugsFilter>
    <!-- Add exclusions here with justification -->
</FindBugsFilter>
```

**Why Required:**
- Catches bugs automatically
- Security vulnerability detection
- Best practices enforcement

---

### 3. PMD (Code Quality) - REQUIRED ✅

**Minimum Configuration:**
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-pmd-plugin</artifactId>
    <version>3.25.0</version>
    <configuration>
        <rulesets>
            <ruleset>pmd-ruleset.xml</ruleset>
        </rulesets>
        <printFailingErrors>true</printFailingErrors>
        <failOnViolation>true</failOnViolation>
        <minimumTokens>100</minimumTokens>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>check</goal>
                <goal>cpd-check</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

**Required File:** `pmd-ruleset.xml`
```xml
<?xml version="1.0"?>
<ruleset name="flossware-pmd-rules"
         xmlns="http://pmd.sourceforge.net/ruleset/2.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://pmd.sourceforge.net/ruleset/2.0.0 
                             https://pmd.sourceforge.io/ruleset_2_0_0.xsd">
    <description>PMD rules for FlossWare projects</description>

    <!-- Standard rulesets -->
    <rule ref="category/java/bestpractices.xml"/>
    <rule ref="category/java/codestyle.xml">
        <exclude name="AtLeastOneConstructor"/>  <!-- Utility classes use private constructor -->
    </rule>
    <rule ref="category/java/design.xml"/>
    <rule ref="category/java/errorprone.xml"/>
    <rule ref="category/java/multithreading.xml"/>
    <rule ref="category/java/performance.xml"/>
    <rule ref="category/java/security.xml"/>
</ruleset>
```

**Why Required:**
- Detects code quality issues
- Copy-paste detection (CPD)
- Enforces best practices
- **Issue**: jcommons missing custom ruleset (#155)

---

### 4. Checkstyle (Code Style) - REQUIRED ✅

**Minimum Configuration:**
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-checkstyle-plugin</artifactId>
    <version>3.6.0</version>
    <configuration>
        <configLocation>google_checks.xml</configLocation>
        <consoleOutput>true</consoleOutput>
        <failOnViolation>true</failOnViolation>
        <violationSeverity>error</violationSeverity>
        <logViolationsToConsole>true</logViolationsToConsole>
    </configuration>
    <executions>
        <execution>
            <id>validate-style</id>
            <phase>validate</phase>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

**Why Required:**
- Google Java Style Guide enforcement
- Consistent code formatting
- No wildcard imports
- **Issue**: jcommons not bound to lifecycle (#198)

---

### 5. Maven Enforcer - REQUIRED ✅

**Minimum Configuration:**
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-enforcer-plugin</artifactId>
    <version>3.6.3</version>
    <executions>
        <execution>
            <id>enforce</id>
            <goals>
                <goal>enforce</goal>
            </goals>
            <configuration>
                <rules>
                    <!-- Require Java 17+ -->
                    <requireJavaVersion>
                        <version>[17,)</version>
                        <message>Java 17 or higher is required</message>
                    </requireJavaVersion>

                    <!-- Require Maven 3.6.3+ -->
                    <requireMavenVersion>
                        <version>[3.6.3,)</version>
                        <message>Maven 3.6.3 or higher is required</message>
                    </requireMavenVersion>

                    <!-- Ban duplicate dependencies -->
                    <banDuplicatePomDependencyVersions/>

                    <!-- Require dependency convergence -->
                    <dependencyConvergence/>

                    <!-- Require plugin versions -->
                    <requirePluginVersions>
                        <message>All plugins must have explicit versions</message>
                        <banLatest>true</banLatest>
                        <banRelease>true</banRelease>
                        <banSnapshots>true</banSnapshots>
                    </requirePluginVersions>

                    <!-- Require no SNAPSHOT dependencies in releases -->
                    <requireReleaseDeps>
                        <message>No SNAPSHOT dependencies allowed in releases</message>
                        <onlyWhenRelease>true</onlyWhenRelease>
                    </requireReleaseDeps>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

**Why Required:**
- Java version enforcement
- Maven version enforcement
- Dependency consistency
- Build reproducibility

---

### 6. OWASP Dependency Check - REQUIRED ✅

**Minimum Configuration:**
```xml
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>10.0.4</version>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>
        <suppressionFile>dependency-check-suppressions.xml</suppressionFile>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

**Required File:** `dependency-check-suppressions.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
    <!--
        OWASP Dependency Check Suppressions
        Add suppressions for known false positives with justification
    -->
</suppressions>
```

**Why Required:**
- Security vulnerability scanning
- Protects against CVEs
- Foundation library security baseline

---

### 7. Maven Failsafe (Integration Tests) - REQUIRED ✅

**Minimum Configuration:**
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-failsafe-plugin</artifactId>
    <version>${maven-surefire-plugin}</version>
    <executions>
        <execution>
            <goals>
                <goal>integration-test</goal>
                <goal>verify</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

**Why Required:**
- Integration test execution
- Separate from unit tests
- **Issue**: jcommons has ITs but never runs them (#166)

---

### 8. Maven Source Plugin - REQUIRED ✅

**Minimum Configuration:**
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-source-plugin</artifactId>
    <version>3.3.1</version>
    <executions>
        <execution>
            <id>attach-sources</id>
            <phase>package</phase>
            <goals>
                <goal>jar-no-fork</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

**Why Required:**
- Maven Central requirement
- IDE source integration
- **Issue**: jcommons missing (#152)

---

### 9. Maven JavaDoc Plugin - REQUIRED ✅

**Minimum Configuration:**
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-javadoc-plugin</artifactId>
    <version>3.12.0</version>
    <executions>
        <execution>
            <id>attach-javadocs</id>
            <phase>package</phase>
            <goals>
                <goal>jar</goal>
            </goals>
            <configuration>
                <doclint>all</doclint>
                <failOnError>true</failOnError>
                <quiet>true</quiet>
            </configuration>
        </execution>
    </executions>
</plugin>
```

**Why Required:**
- Maven Central requirement
- API documentation
- IDE JavaDoc integration
- **Issue**: jcommons not executed (#151)

---

### 10. PIT Mutation Testing - OPTIONAL ⚠️

**Configuration:**
```xml
<plugin>
    <groupId>org.pitest</groupId>
    <artifactId>pitest-maven</artifactId>
    <version>1.17.3</version>
    <dependencies>
        <dependency>
            <groupId>org.pitest</groupId>
            <artifactId>pitest-junit5-plugin</artifactId>
            <version>1.2.1</version>
        </dependency>
    </dependencies>
    <configuration>
        <targetClasses>
            <param>org.flossware.*</param>
        </targetClasses>
        <targetTests>
            <param>org.flossware.*</param>
        </targetTests>
        <mutationThreshold>80</mutationThreshold>
        <coverageThreshold>100</coverageThreshold>
        <outputFormats>
            <format>HTML</format>
            <format>XML</format>
        </outputFormats>
    </configuration>
    <!-- Do NOT add executions - too slow for CI -->
    <!-- Run manually: mvn org.pitest:pitest-maven:mutationCoverage -->
</plugin>
```

**Why Optional:**
- Very slow (5-10 minutes)
- Advanced quality metric
- Run manually before releases
- **Issue**: jcommons configured but never used (#200)

---

## Build Lifecycle Integration

### Critical: All Quality Tools Must Run Automatically

**Requirements:**
1. ✅ JaCoCo: Bound to `verify` phase
2. ✅ SpotBugs: Has `<executions>` section
3. ✅ PMD: Has `<executions>` section
4. ✅ Checkstyle: Has `<executions>` bound to `validate` or `verify`
5. ✅ Enforcer: Has `<executions>` section
6. ✅ OWASP: Has `<executions>` section
7. ✅ Failsafe: Has `<executions>` for integration-test phase

**Test Command:**
```bash
mvn clean verify
# Should run: compile, test, JaCoCo, SpotBugs, PMD, Checkstyle, Enforcer, OWASP, Failsafe
```

**Common Mistake:** Plugin configured but no `<executions>` section
- Results in plugin only running when manually invoked
- Not enforced in CI/CD
- **Issue**: jcommons Checkstyle (#198)

---

## Reporting Configuration

### Required: `<reporting>` Section

**Why Required:**
- Generates unified Maven site
- Consolidates all quality reports
- Professional project presentation
- **Issue**: jcommons missing (#197)

**Minimum Reporting Configuration:**
```xml
<reporting>
    <plugins>
        <!-- JaCoCo Coverage Report -->
        <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <reportSets>
                <reportSet>
                    <reports>
                        <report>report</report>
                    </reports>
                </reportSet>
            </reportSets>
        </plugin>

        <!-- SpotBugs Report -->
        <plugin>
            <groupId>com.github.spotbugs</groupId>
            <artifactId>spotbugs-maven-plugin</artifactId>
        </plugin>

        <!-- PMD Report -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-pmd-plugin</artifactId>
        </plugin>

        <!-- Checkstyle Report -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-checkstyle-plugin</artifactId>
        </plugin>

        <!-- Maven Project Info Reports -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-project-info-reports-plugin</artifactId>
            <version>3.9.0</version>
            <reportSets>
                <reportSet>
                    <reports>
                        <report>index</report>
                        <report>summary</report>
                        <report>dependencies</report>
                        <report>team</report>
                        <report>licenses</report>
                        <report>scm</report>
                    </reports>
                </reportSet>
            </reportSets>
        </plugin>

        <!-- JavaDoc Report -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-javadoc-plugin</artifactId>
        </plugin>

        <!-- JXR (Source Cross-Reference) -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-jxr-plugin</artifactId>
            <version>3.6.0</version>
        </plugin>
    </plugins>
</reporting>
```

**Usage:**
```bash
mvn site
# Generates: target/site/index.html
# Contains: All quality reports in unified dashboard
```

---

## Maven Site Structure

### Required: `src/site/` Directory Structure

**Why Required:**
- Professional project website
- Centralized documentation
- GitHub Pages deployment
- **Issue**: jcommons missing (#199)

**Minimum Structure:**
```
src/site/
├── site.xml           # Site descriptor (navigation, skin)
├── markdown/
│   └── index.md       # Home page
└── resources/
    ├── css/
    │   └── site.css   # Custom styling
    └── images/
```

**Minimum `src/site/site.xml`:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project name="Project Name">
    <bannerLeft>
        <name>Project Name</name>
        <href>https://github.com/FlossWare/project</href>
    </bannerLeft>

    <publishDate position="right"/>
    <version position="right"/>

    <body>
        <links>
            <item name="GitHub" href="https://github.com/FlossWare/project"/>
            <item name="Issues" href="https://github.com/FlossWare/project/issues"/>
        </links>

        <menu name="Documentation">
            <item name="JavaDoc" href="apidocs/index.html"/>
        </menu>

        <menu name="Quality Reports">
            <item name="Code Coverage" href="jacoco/index.html"/>
            <item name="SpotBugs" href="spotbugs.html"/>
            <item name="PMD" href="pmd.html"/>
            <item name="Checkstyle" href="checkstyle.html"/>
        </menu>

        <menu ref="reports"/>
    </body>

    <skin>
        <groupId>org.apache.maven.skins</groupId>
        <artifactId>maven-fluido-skin</artifactId>
        <version>2.0.0-M10</version>
    </skin>
</project>
```

---

## Dependency Management

### Requirements

#### 1. Declare What You Use
**Rule:** If code imports from a package, that package's artifact must be in the POM.

**Common Mistake:** Relying on transitive dependencies
- Fragile: Parent can change dependencies
- **Issue**: jcommons has 3 undeclared dependencies (#173)

**Check:**
```bash
mvn dependency:analyze
# Should show: No "Used undeclared dependencies"
```

#### 2. Explicit Dependency Versions
**Rule:** All direct dependencies must have explicit versions (or use `<dependencyManagement>`).

**Bad:**
```xml
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-lang3</artifactId>
    <!-- ❌ No version - relies on parent -->
</dependency>
```

**Good:**
```xml
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-lang3</artifactId>
    <version>3.20.0</version>
</dependency>
```

#### 3. No Unused Dependencies
**Rule:** Remove dependencies not actually used.

**Check:**
```bash
mvn dependency:analyze
# Fix any "Unused declared dependencies"
```

**Exception:** Dependencies required by module-info.java
- **Issue**: jcommons has false positive (#173)

#### 4. Use `<dependencyManagement>`
**Rule:** For multi-module projects or when forcing transitive versions.

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>jakarta.xml.bind</groupId>
            <artifactId>jakarta.xml.bind-api</artifactId>
            <version>4.0.4</version>
        </dependency>
    </dependencies>
</dependencyManagement>
```

---

## CI/CD Integration

### Required GitHub Actions Steps

#### 1. Quality Gates in CI
```yaml
- name: Run Unit Tests
  run: mvn test

- name: Run Integration Tests
  run: mvn failsafe:integration-test failsafe:verify

- name: Run Quality Checks
  run: mvn verify
  # Runs: JaCoCo, SpotBugs, PMD, Checkstyle, Enforcer, OWASP
```

#### 2. Generate and Upload Reports
```yaml
- name: Generate JaCoCo Coverage Report
  run: mvn jacoco:report

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v4
  with:
    token: ${{ secrets.CODECOV_TOKEN }}
    files: ./target/site/jacoco/jacoco.xml
    fail_ci_if_error: false

- name: Upload Quality Reports
  uses: actions/upload-artifact@v4
  if: always()
  with:
    name: quality-reports
    path: |
      target/site/jacoco/
      target/spotbugsXml.xml
      target/pmd.xml
      target/checkstyle-result.xml
```

#### 3. Generate Maven Site (Optional)
```yaml
- name: Generate Maven Site
  run: mvn site

- name: Deploy to GitHub Pages
  uses: peaceiris/actions-gh-pages@v4
  if: github.ref == 'refs/heads/main'
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./target/site
    destination_dir: site
```

---

## Complete POM Template

See `flossware-project-template.xml` for complete example including:
- All required plugins with proper configuration
- Reporting section
- Dependency management
- Distribution management
- SCM configuration
- Developer metadata

**Add to template:**
1. ✅ Checkstyle with `<executions>` bound to lifecycle
2. ✅ PMD with custom `pmd-ruleset.xml` reference
3. ✅ Complete `<reporting>` section
4. ✅ Maven source plugin execution
5. ✅ Maven javadoc plugin execution
6. ✅ Failsafe plugin for integration tests

---

## Validation Checklist

Before considering a Maven POM complete, verify:

### Build Plugins
- [ ] JaCoCo with enforced thresholds (93% instruction, 86% branch)
- [ ] SpotBugs with `<executions>` section
- [ ] PMD with `<executions>` and custom ruleset
- [ ] Checkstyle with `<executions>` bound to lifecycle
- [ ] Maven Enforcer with Java/Maven version requirements
- [ ] OWASP Dependency Check with suppressions file
- [ ] Maven Failsafe for integration tests
- [ ] Maven Source plugin with execution
- [ ] Maven JavaDoc plugin with execution

### Configuration Files
- [ ] `spotbugs-exclude.xml` exists (even if empty)
- [ ] `pmd-ruleset.xml` exists with project rules
- [ ] `dependency-check-suppressions.xml` exists
- [ ] `.editorconfig` exists for IDE consistency

### Reporting
- [ ] `<reporting>` section exists in POM
- [ ] All build plugins also in reporting section
- [ ] `src/site/site.xml` exists
- [ ] `src/site/markdown/index.md` exists

### Dependency Management
- [ ] `mvn dependency:analyze` shows no warnings
- [ ] All direct dependencies have explicit versions
- [ ] No unused dependencies (except module-info requirements)
- [ ] `<dependencyManagement>` used for transitive version control

### CI/CD Integration
- [ ] Quality checks run in CI workflow
- [ ] Integration tests run in CI workflow
- [ ] Coverage reports uploaded (Codecov)
- [ ] Artifacts include: JAR, sources JAR, javadoc JAR

### Metadata
- [ ] `<developers>` section populated
- [ ] `<organization>` section populated
- [ ] `<licenses>` section populated
- [ ] `<scm>` section populated
- [ ] `<distributionManagement>` configured

---

## References

All requirements derived from production quality audit of FlossWare/jcommons:
- Issue #155: PMD custom ruleset missing
- Issue #151: JavaDoc plugin not executed
- Issue #152: Source plugin missing
- Issue #166: Integration tests never run
- Issue #173: Dependency management issues
- Issue #197: Missing reporting section
- Issue #198: Checkstyle not in lifecycle
- Issue #199: No Maven site structure
- Issue #200: PIT mutation testing unused

Total findings: 71 issues across 11 comprehensive reviews documenting all gaps and best practices for production-ready Maven builds.
