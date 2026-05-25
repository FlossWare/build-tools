# Rolling Out FlossWare Standards to Your Projects

This guide helps you apply FlossWare build standards across all projects in your organization.

## Quick Overview

```bash
# From FlossWare root directory
cd flossware-build-tools

# Option 1: Apply to all projects automatically
./rollout-standards.sh --all

# Option 2: Apply to specific project
./rollout-standards.sh --project ../jcommons

# Option 3: Dry run (preview changes only)
./rollout-standards.sh --all --dry-run
```

---

## Rollout Strategies

### Strategy 1: Big Bang (All Projects at Once)

**When to use:** Small org, < 10 projects, active development

**Steps:**
1. Apply standards to all projects
2. Fix violations in one sprint
3. Enforce from day one

**Pros:** ✓ Consistent immediately, ✓ One-time effort  
**Cons:** ✗ Disruptive, ✗ Requires dedicated time

### Strategy 2: Gradual Rollout (Project by Project)

**When to use:** Large org, > 10 projects, mixed activity levels

**Steps:**
1. Start with newest/smallest projects
2. Apply to 2-3 projects per week
3. Learn and adjust process
4. Roll out to larger projects

**Pros:** ✓ Less disruptive, ✓ Learn from early projects  
**Cons:** ✗ Takes longer, ✗ Inconsistent temporarily

### Strategy 3: New Code Only

**When to use:** Legacy codebases, limited resources

**Steps:**
1. Apply standards to new projects only
2. Gradually migrate existing projects
3. Allow violations in legacy code temporarily

**Pros:** ✓ Minimal disruption, ✓ Standards on new code  
**Cons:** ✗ Mixed standards, ✗ Technical debt remains

---

## Step-by-Step Rollout

### Phase 1: Preparation (1-2 hours)

#### 1.1. Review Standards

Ensure team understands:
- [README.md](README.md) - Overview
- [METHOD-CHAINING.md](METHOD-CHAINING.md) - Coding style
- [TEST-COVERAGE.md](TEST-COVERAGE.md) - Testing requirements

#### 1.2. Set Up IDE Templates

Each developer should configure their IDE:
- **IntelliJ**: [FINAL-VARIABLES.md](FINAL-VARIABLES.md#intellij-idea---auto-add-on-save)
- **Eclipse**: [FINAL-VARIABLES.md](FINAL-VARIABLES.md#eclipse---auto-add-on-save)
- **NetBeans**: [NETBEANS-SETUP.md](NETBEANS-SETUP.md)

#### 1.3. Communicate to Team

Send email/Slack with:
```
📢 FlossWare Build Standards Rollout

Starting [DATE], all FlossWare projects will enforce:
✅ X.Y versioning (no X.Y.Z)
✅ No wildcard imports
✅ Final parameters
✅ Method chaining preferred
✅ 100% test coverage
✅ Code quality checks

📖 Documentation: /path/to/flossware-build-tools/
🛠️ IDE Setup: See NETBEANS-SETUP.md (or your IDE)
🗓️ Rollout Schedule: [LINK TO SCHEDULE]

Questions? Ask in #flossware-dev
```

### Phase 2: Apply Standards (Per Project)

#### 2.1. Back Up First

```bash
cd /path/to/project
git checkout -b apply-flossware-standards
git commit -am "Checkpoint before standards" --allow-empty
```

#### 2.2. Add Build Tools Dependency

Run the rollout script:

```bash
cd /path/to/flossware-build-tools
./rollout-standards.sh --project /path/to/your-project
```

Or manually add to `pom.xml`:

```xml
<build>
    <plugins>
        <!-- Copy from example-project-pom-snippet.xml -->
    </plugins>
</build>
```

#### 2.3. Copy EditorConfig

```bash
cp flossware-build-tools/.editorconfig your-project/
```

#### 2.4. Initial Build (Expect Failures)

```bash
cd your-project
mvn clean verify
```

**Expected violations:**
- Missing `final` on parameters
- Wildcard imports
- Code quality issues
- Low test coverage

### Phase 3: Fix Violations

#### 3.1. Fix Import Issues

```bash
# IntelliJ
Ctrl+Alt+O (Optimize Imports)

# Eclipse  
Ctrl+Shift+O (Organize Imports)

# NetBeans
Alt+Shift+I (Fix Imports)

# Or via Maven
mvn checkstyle:check
```

#### 3.2. Add Final to Parameters

**IntelliJ:**
1. Analyze → Inspect Code
2. Filter: "Parameter can be final"
3. Select all → Apply Fix

**Eclipse:**
1. Source → Clean Up
2. Configure → "Add final to parameters"
3. Select files → Clean Up

**NetBeans:**
1. Source → Inspect and Transform
2. Select "Parameter Can Be Final"
3. Do Refactoring

**Manual regex (if needed):**
```bash
# Use with caution - review changes!
find src -name "*.java" -exec sed -i 's/\(public\|private\|protected\) \([a-zA-Z<>]\+\) \([a-zA-Z]\+\)(\([a-zA-Z<>]\+ [a-zA-Z]\+\)/\1 \2 \3(final \4/g' {} \;
```

#### 3.3. Fix Mockito Warnings

```bash
cd /path/to/flossware-build-tools
./fix-mockito-warning.sh /path/to/your-project
```

#### 3.4. Improve Test Coverage

This is the hardest part. For each uncovered line:

```bash
# 1. Generate coverage report
mvn clean test jacoco:report

# 2. Open report
open target/site/jacoco/index.html

# 3. Find red lines (uncovered code)

# 4. Write tests for each red line

# 5. Re-run until 100%
mvn clean verify
```

See [TEST-COVERAGE.md](TEST-COVERAGE.md) for testing patterns.

**Gradual approach:**
```xml
<!-- Temporarily lower threshold while adding tests -->
<limit>
    <counter>INSTRUCTION</counter>
    <value>COVEREDRATIO</value>
    <minimum>0.80</minimum>  <!-- Start at current coverage -->
</limit>
```

Increase by 10% each week until reaching 1.00.

#### 3.5. Verify Build Passes

```bash
mvn clean verify
# All checks should pass
```

### Phase 4: Commit and Deploy

#### 4.1. Review Changes

```bash
git diff
git status
```

#### 4.2. Commit

```bash
git add .
git commit -m "Apply FlossWare build standards v1.3

- Added Checkstyle, PMD, SpotBugs, JaCoCo plugins
- Fixed wildcard imports
- Added final to parameters
- Improved test coverage to 100%
- Added .editorconfig

Standards: flossware-build-tools v1.3"
```

#### 4.3. Test in CI

```bash
git push origin apply-flossware-standards
# Create PR, wait for CI to pass
```

#### 4.4. Merge to Main

Once CI passes and PR is reviewed:

```bash
git checkout main
git merge apply-flossware-standards
git push origin main
```

---

## Automation Scripts

### rollout-standards.sh

Apply standards to one or all projects:

```bash
# Apply to all projects
./rollout-standards.sh --all

# Apply to specific project
./rollout-standards.sh --project ../jcommons

# Dry run (preview only)
./rollout-standards.sh --all --dry-run

# Skip coverage (add JaCoCo but don't enforce 100% yet)
./rollout-standards.sh --all --skip-coverage-enforcement
```

### verify-all-projects.sh

Check which projects pass standards:

```bash
# Test all projects
./verify-all-projects.sh

# Output:
# ✓ jcommons - PASS
# ✗ jclassloader - FAIL (coverage 85%)
# ✓ jvcs - PASS
```

---

## Handling Difficult Cases

### Large Legacy Projects

**Problem:** 1000s of violations, low test coverage

**Solution:**
1. Apply standards but disable enforcement temporarily:
   ```xml
   <failOnViolation>false</failOnViolation>
   ```

2. Fix violations incrementally:
   - Week 1: Fix imports
   - Week 2: Add final to parameters
   - Week 3-N: Improve coverage 10% per week

3. Enable enforcement once clean:
   ```xml
   <failOnViolation>true</failOnViolation>
   ```

### Projects with External Contributors

**Problem:** Contributors unfamiliar with standards

**Solution:**
1. Add `CONTRIBUTING.md` to each project:
   ```markdown
   # Contributing
   
   This project uses FlossWare build standards.
   
   Before submitting PR:
   - Run `mvn clean verify` (must pass)
   - See flossware-build-tools/README.md
   ```

2. Add pre-commit hook (optional):
   ```bash
   # .git/hooks/pre-commit
   #!/bin/bash
   mvn checkstyle:check pmd:check
   ```

3. Configure CI to block PRs that fail standards

### Projects Using Different Java Versions

**Problem:** Some projects on Java 8, others on Java 17

**Solution:**

Standards work with all Java versions 8+. Just set in each project:

```xml
<properties>
    <maven.compiler.source>8</maven.compiler.source>
    <maven.compiler.target>8</maven.compiler.target>
</properties>
```

FlossWare build-tools is version-agnostic.

---

## Rollout Schedule Example

### Week 1: Pilot Projects
- ✅ 2-3 small/new projects
- ✅ Document issues encountered
- ✅ Update team on learnings

### Week 2: Active Projects  
- ✅ 3-5 actively developed projects
- ✅ Pair with developers to fix violations
- ✅ Update FAQs based on questions

### Week 3: Medium Projects
- ✅ 5-10 medium-sized projects
- ✅ Most common issues now documented
- ✅ Team familiar with process

### Week 4: Large/Legacy Projects
- ✅ Remaining large projects
- ✅ May need gradual coverage adoption
- ✅ Dedicate time for test writing

### Week 5: Cleanup
- ✅ Verify all projects pass
- ✅ Update CI/CD to enforce standards
- ✅ Celebrate! 🎉

---

## CI/CD Integration

### GitHub Actions

Add to each project's `.github/workflows/build.yml`:

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Build and Verify Standards
        run: mvn clean verify
      
      - name: Upload Coverage Report
        uses: codecov/codecov-action@v3
        with:
          files: ./target/site/jacoco/jacoco.xml
```

### GitLab CI

Add to each project's `.gitlab-ci.yml`:

```yaml
stages:
  - build
  - test

build:
  stage: build
  image: maven:3.8-openjdk-17
  script:
    - mvn clean verify
  artifacts:
    reports:
      junit: target/surefire-reports/TEST-*.xml
      coverage_report:
        coverage_format: jacoco
        path: target/site/jacoco/jacoco.xml
```

### Jenkins

Add to each project's `Jenkinsfile`:

```groovy
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean verify'
            }
        }
        
        stage('Publish Reports') {
            steps {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: '**/target/jacoco.exec'
                checkstyle pattern: '**/target/checkstyle-result.xml'
                pmd pattern: '**/target/pmd.xml'
            }
        }
    }
}
```

---

## Monitoring Compliance

### Dashboard (Manual)

Create a spreadsheet tracking:

| Project | Standards Applied | All Checks Pass | Coverage | Notes |
|---------|------------------|-----------------|----------|-------|
| jcommons | ✅ v1.3 | ✅ | 100% | |
| jvcs | ✅ v1.3 | ✅ | 100% | |
| jclassloader | ✅ v1.3 | ⚠️ | 85% | Coverage WIP |

### Automated Check

```bash
./verify-all-projects.sh > compliance-report.txt
cat compliance-report.txt
```

---

## Troubleshooting

### Build Fails with "Coverage check failed"

**Solution:** Improve test coverage

```bash
mvn jacoco:report
open target/site/jacoco/index.html
# Write tests for red lines
```

### Too Many Checkstyle Violations

**Solution:** Use IDE auto-fix

```
IntelliJ: Code → Reformat Code (Ctrl+Alt+L)
Eclipse: Source → Clean Up
NetBeans: Source → Format
```

### PMD Complains About Method Chaining

**Solution:** PMD wants you to chain, not use temporaries

```java
// ✗ PMD violation
final String result = input.trim();
return result;

// ✓ PMD happy
return input.trim();
```

---

## Support

- **Questions:** File issue at flossware-build-tools
- **Bugs in standards:** Update flossware-build-tools and re-apply
- **Project-specific issues:** Review relevant .md files

---

## Checklist

Per-project checklist:

- [ ] Branch created for standards work
- [ ] Build-tools dependency added to pom.xml
- [ ] .editorconfig copied to project root
- [ ] Wildcard imports fixed
- [ ] Final added to parameters
- [ ] Mockito warnings fixed
- [ ] Test coverage at 100%
- [ ] `mvn clean verify` passes
- [ ] Changes committed and pushed
- [ ] CI passes
- [ ] PR merged

Organization-wide checklist:

- [ ] All developers have IDE configured
- [ ] Rollout schedule communicated
- [ ] Documentation accessible to team
- [ ] CI configured to enforce standards
- [ ] All projects passing standards
- [ ] New project template updated
- [ ] Team trained on standards
