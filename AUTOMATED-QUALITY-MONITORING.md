# Automated Quality Monitoring with GitHub Issues

Automatically track and manage code quality issues across all FlossWare projects using GitHub Actions and automated issue creation.

---

## Overview

The **Quality Gate Workflow** runs on every push, pull request, and daily (security scan), automatically creating GitHub issues when quality checks fail.

### What Gets Monitored

- ✅ **Code Coverage** (JaCoCo) - Issues created when coverage drops
- ✅ **Bug Detection** (SpotBugs) - Issues created for each bug found
- ✅ **Code Quality** (PMD) - Issues created for quality violations
- ✅ **Code Style** (Checkstyle) - Issues created for style errors
- ✅ **Security Vulnerabilities** (OWASP) - Issues created for CVEs
- ✅ **Build Failures** - Workflow fails, preventing bad merges

---

## Quick Start

### 1. Distribute Workflow to All Projects

```bash
cd build-tools
./distribute-quality-workflow.sh --all
```

### 2. Commit and Push (Per Project)

```bash
cd ../jcommons  # Or any project
git add .github/
git commit -m "Add automated quality gate workflow"
git push
```

### 3. Watch It Work

- **On Push**: Workflow runs automatically
- **On PR**: Comments with quality metrics
- **Quality Failure**: GitHub issue auto-created
- **Daily 2 AM UTC**: Security scan runs

---

## How It Works

### Trigger Events

1. **Push to main/develop**
   - Runs full quality suite
   - Creates issues for failures
   - Fails workflow if gates not met

2. **Pull Request**
   - Runs quality checks
   - Comments quality metrics on PR
   - Prevents merge if checks fail

3. **Daily Schedule (2 AM UTC)**
   - Security vulnerability scan
   - Catches new CVEs in dependencies
   - Creates security issues if found

### Quality Gates

| Tool | Pass Criteria | Fail Action |
|------|--------------|-------------|
| **JaCoCo** | ≥93% instruction, ≥86% branch | Create "Code Coverage Below Threshold" issue |
| **SpotBugs** | 0 bugs | Create "SpotBugs Violations Detected" issue |
| **PMD** | 0 violations | Create "PMD Code Quality Violations" issue |
| **Checkstyle** | 0 errors | Create "Checkstyle Violations" issue |
| **OWASP** | 0 critical/high vulns | Create "Security Vulnerabilities Detected" issue |

---

## Issue Management

### Auto-Created Issues

**Labels Applied:**
- `quality-gate` - All auto-created quality issues
- `automated` - Distinguishes from manual issues
- Specific: `coverage`, `spotbugs`, `pmd`, `checkstyle`, `security`
- Priority: `priority-high` for security issues

**De-duplication:**
- Only creates one issue per category
- Checks for existing open issues before creating
- Close old issue when problem is fixed

### Issue Templates

Each auto-created issue includes:
- ✅ **Problem description** with metrics
- ✅ **Action required** section
- ✅ **How to fix** step-by-step guide
- ✅ **Resources** links to documentation
- ✅ **Triggered by** commit SHA and workflow run link

### Example: Coverage Issue

```markdown
## 🧪 Code Coverage Below Threshold

**Current Coverage:**
- Instruction Coverage: 89%
- Branch Coverage: 82%

**Required:**
- Instruction Coverage: ≥93%
- Branch Coverage: ≥86%

### Action Required
Increase test coverage to meet FlossWare quality standards.

### How to Fix
1. Run: `mvn clean verify`
2. Open: `target/site/jacoco/index.html`
3. Identify uncovered code
4. Add tests for uncovered lines/branches
5. Re-run: `mvn clean verify`

### Resources
- [Test Coverage Guide](../build-tools/TEST-COVERAGE.md)
- [Coverage Recommendations](../build-tools/COVERAGE-RECOMMENDATIONS.md)
```

---

## PR Quality Comments

Every pull request gets an automated comment with quality metrics:

```markdown
## 📊 Quality Gate Report

| Tool | Status | Metrics |
|------|--------|---------|
| 🧪 **JaCoCo** | ✅ | Instruction: 95%, Branch: 89% |
| 🐛 **SpotBugs** | ✅ | 0 bugs found |
| 📝 **PMD** | ❌ | 3 violations |
| ✓ **Checkstyle** | ✅ | 0 errors |
| 🔒 **OWASP** | ✅ | 0 vulnerabilities |

⚠️ **Quality gates failed!** Fix issues before merging.
```

---

## Workflow Configuration

### File Location

```
.github/workflows/quality-gate.yml
```

### Customization Options

#### Adjust Coverage Thresholds

```yaml
- name: Create issue for coverage drop
  if: |
    steps.jacoco.outputs.instruction_coverage < '93%'  # Change here
```

#### Change Schedule

```yaml
schedule:
  - cron: '0 2 * * *'  # Daily at 2 AM UTC - change as needed
```

#### Modify Issue Templates

Edit the `body:` section of each issue creation step.

#### Add Custom Checks

Add new steps after the existing quality checks:

```yaml
- name: Custom check
  run: |
    # Your custom validation
    echo "Running custom check..."
```

---

## Artifacts

Each workflow run uploads quality reports:

### Available Artifacts

- `quality-reports/` (retained 30 days)
  - `target/site/jacoco/` - Full coverage report
  - `target/spotbugsXml.xml` - SpotBugs XML report
  - `target/pmd.xml` - PMD XML report
  - `target/checkstyle-result.xml` - Checkstyle XML report
  - `target/dependency-check-report.xml` - OWASP XML report
  - `maven-verify.log` - Full Maven output

### Download Artifacts

1. Go to GitHub Actions tab
2. Click on workflow run
3. Scroll to "Artifacts" section
4. Download `quality-reports`

---

## Permissions Required

The workflow needs these GitHub permissions:

```yaml
permissions:
  contents: read        # Read repository code
  issues: write         # Create/update issues
  pull-requests: write  # Comment on PRs
```

These are automatically granted to GitHub Actions in your repository.

---

## Disable Specific Checks

### Temporarily Disable Issue Creation

Comment out the issue creation step:

```yaml
# - name: Create issue for coverage drop
#   if: ...
#   uses: actions/github-script@v7
#   ...
```

### Skip Specific Tool

Add to workflow:

```yaml
- name: Run Maven verify
  run: mvn clean verify -Dspotbugs.skip=true  # Skip SpotBugs
```

### Disable Workflow Entirely

Rename or delete `.github/workflows/quality-gate.yml`

---

## Integration with Development Workflow

### For Developers

1. **Write code** as normal
2. **Commit and push**
3. **GitHub Actions runs** automatically
4. **If quality fails**:
   - Issue created (if doesn't exist)
   - Workflow run shows details
   - Fix issues locally
   - Commit fix
   - Push (re-runs checks)
5. **When fixed**:
   - Workflow passes ✅
   - Close the auto-created issue

### For Pull Requests

1. **Create PR**
2. **Automated comment** appears with quality metrics
3. **If checks fail**:
   - PR shows ❌ in status checks
   - Cannot merge until fixed
4. **Fix issues** and push
5. **Re-check runs** automatically
6. **When green**, PR is mergeable ✅

### For Project Maintainers

1. **Monitor quality issues**:
   - Filter by `quality-gate` label
   - Prioritize `priority-high` (security)
2. **Track trends**:
   - Are issues increasing?
   - Common patterns?
3. **Review suppressions**:
   - Justified exclusions in `spotbugs-exclude.xml`?
   - False positives in `dependency-check-suppressions.xml`?

---

## Troubleshooting

### Workflow Not Running

**Check:**
1. Is `.github/workflows/quality-gate.yml` committed?
2. Is GitHub Actions enabled? (Settings → Actions)
3. Are there syntax errors in YAML? (GitHub shows warnings)

### Issues Not Being Created

**Possible Causes:**
1. Issue already exists (de-duplication)
   - Close existing issue, re-run workflow
2. Permissions insufficient
   - Check `permissions:` in workflow YAML
3. GitHub API rate limit
   - Wait an hour, re-run

### False Positives

**SpotBugs:**
Add to `spotbugs-exclude.xml`:
```xml
<Match>
    <Class name="org.flossware.Example"/>
    <Bug pattern="EI_EXPOSE_REP"/>
</Match>
```

**OWASP:**
Add to `dependency-check-suppressions.xml`:
```xml
<suppress>
    <notes>False positive - not vulnerable in our usage</notes>
    <cve>CVE-2021-12345</cve>
</suppress>
```

### Workflow Takes Too Long

**Optimization:**
1. Use Maven dependency caching (already in workflow)
2. Skip site generation:
   ```yaml
   run: mvn clean verify -Dsite.skip=true
   ```
3. Parallelize tests:
   ```yaml
   run: mvn clean verify -T 1C  # 1 thread per CPU core
   ```

---

## Examples

### Typical Daily Workflow

```
Morning:
- Check GitHub for new quality-gate issues
- Prioritize security issues (priority-high)
- Assign coverage/bug issues to team

During Development:
- Developer pushes code
- Quality gate runs
- If fails: Issue auto-created, developer notified
- Developer fixes locally
- Push again, issue auto-closes

End of Day:
- Review open quality-gate issues
- Plan fixes for next sprint
```

### Handling a Security Alert

```
1. Daily scan runs (2 AM UTC)
2. Critical vulnerability detected
3. Issue auto-created with priority-high label
4. Security team notified (GitHub notifications)
5. Review OWASP report (download artifact)
6. Update affected dependency
7. Test: mvn clean verify
8. Commit and push
9. Workflow re-runs, passes
10. Close issue
```

---

## Rollout Strategy

### Phase 1: Pilot Projects (1-2 projects)
1. Distribute workflow to 1-2 mature projects
2. Monitor for 1 week
3. Adjust thresholds/templates based on feedback

### Phase 2: Core Libraries (5-10 projects)
1. Distribute to foundational libraries
2. Train team on issue triage
3. Establish issue-closing workflow

### Phase 3: All Projects
1. Run mass distribution:
   ```bash
   ./distribute-quality-workflow.sh --all
   ```
2. Commit across all repos
3. Monitor GitHub Actions usage/costs
4. Celebrate automated quality! 🎉

---

## Cost Considerations

### GitHub Actions Minutes

- **Free tier**: 2,000 minutes/month for private repos
- **Public repos**: Unlimited (FlossWare is public)
- **This workflow**: ~3-5 minutes per run
- **Estimate**: 
  - 20 projects × 5 pushes/day × 5 min = 500 min/day
  - Public repos: FREE ✅

### Storage (Artifacts)

- **Free tier**: 500 MB for private repos
- **Public repos**: Unlimited
- **This workflow**: ~5 MB per run, 30-day retention
- **Estimate**: 
  - 100 runs × 5 MB = 500 MB
  - Auto-cleanup after 30 days
  - Public repos: FREE ✅

---

## Resources

- **Workflow Template**: `.github/workflows/quality-gate.yml`
- **Distribution Script**: `distribute-quality-workflow.sh`
- **Maven Quality Requirements**: `MAVEN-QUALITY-REQUIREMENTS.md`
- **Test Coverage Guide**: `TEST-COVERAGE.md`
- **GitHub Actions Docs**: https://docs.github.com/en/actions

---

## FAQ

**Q: Will this create hundreds of issues?**  
A: No, de-duplication prevents duplicates. One issue per category maximum.

**Q: Can I silence specific issues?**  
A: Yes, fix the underlying problem or add justified exclusions to config files.

**Q: What about private repos?**  
A: Works the same, but uses GitHub Actions minutes (2,000/month free).

**Q: Can I run this locally?**  
A: Yes: `mvn clean verify` runs all checks locally without creating issues.

**Q: Does this block development?**  
A: No, you can push code. Workflow fails but doesn't prevent push. PR merge is blocked until fixed.

**Q: Can I customize issue templates?**  
A: Yes, edit the `body:` section in `quality-gate.yml` for each issue type.

---

## Next Steps

1. **Distribute workflow**:
   ```bash
   ./distribute-quality-workflow.sh --all
   ```

2. **Commit and enable** (per project)

3. **Monitor quality issues** with GitHub labels

4. **Iterate and improve** workflow based on team feedback
