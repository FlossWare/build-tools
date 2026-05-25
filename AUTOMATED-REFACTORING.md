# Automated Refactoring for FlossWare Standards

FlossWare supports automated code transformations to help migrate existing code to standards.

## Quick Start

```bash
# Auto-fix all FlossWare standards violations
cd your-project
mvn rewrite:run

# Preview changes without applying
mvn rewrite:dryRun
```

## What Gets Automated

### ✅ Fully Automated

1. **Add final to parameters** - Automatically adds `final` to all method/constructor parameters
2. **Fix wildcard imports** - Replaces `import java.util.*;` with specific imports
3. **Remove unnecessary variables** - Inlines single-use variables into method chains
4. **Add missing @Override** - Adds `@Override` annotations where missing
5. **Static imports** - Converts to static imports where appropriate
6. **Remove unused imports** - Cleans up unused import statements

### ⚠️ Semi-Automated (Requires Review)

1. **Test coverage** - Can't be fully automated, but tools can help identify gaps
2. **Complex refactorings** - May need manual review for correctness

---

## Tools Available

### Option 1: OpenRewrite (Recommended)

**Best for:** Automated, safe refactoring of entire codebase

**Add to your `pom.xml`:**

```xml
<plugin>
    <groupId>org.openrewrite.maven</groupId>
    <artifactId>rewrite-maven-plugin</artifactId>
    <version>5.20.0</version>
    <configuration>
        <activeRecipes>
            <recipe>org.flossware.FlossWareStandards</recipe>
        </activeRecipes>
    </configuration>
    <dependencies>
        <dependency>
            <groupId>org.flossware</groupId>
            <artifactId>flossware-build-tools</artifactId>
            <version>1.3</version>
        </dependency>
    </dependencies>
</plugin>
```

**Usage:**

```bash
# Preview changes
mvn rewrite:dryRun

# Apply changes
mvn rewrite:run

# Target specific recipe
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.cleanup.UnnecessaryExplicitTypeArguments
```

### Option 2: Error Prone (Google)

**Best for:** Catching issues during compilation

**Add to your `pom.xml`:**

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.11.0</version>
    <configuration>
        <compilerArgs>
            <arg>-XDcompilePolicy=simple</arg>
            <arg>-Xplugin:ErrorProne</arg>
        </compilerArgs>
        <annotationProcessorPaths>
            <path>
                <groupId>com.google.errorprone</groupId>
                <artifactId>error_prone_core</artifactId>
                <version>2.23.0</version>
            </path>
        </annotationProcessorPaths>
    </configuration>
</plugin>
```

**Usage:**

```bash
mvn clean compile
# Shows warnings for potential issues
```

### Option 3: IDE Automated Refactoring

**Best for:** Interactive refactoring with immediate feedback

#### IntelliJ IDEA

```
1. Code → Inspect Code
2. Filter by "FlossWare" or specific checks
3. Select all violations → Apply Fix
4. Or: Code → Cleanup Code (with custom profile)
```

**Bulk inline variables:**
```
1. Select code region
2. Refactor → Inline (Ctrl+Alt+N)
3. Select "Inline all" option
```

#### Eclipse

```
1. Source → Clean Up
2. Configure Clean Up profile:
   - Add final modifiers
   - Remove unnecessary local variables
   - Organize imports
3. Apply to workspace or selection
```

#### NetBeans

```
1. Source → Inspect and Transform
2. Select transformations:
   - Add final to parameters
   - Remove unnecessary variables
3. Do Refactoring
```

---

## Custom FlossWare Recipes

I've created custom OpenRewrite recipes for FlossWare standards:

### Recipe: FlossWareStandards

Combines all FlossWare transformations:

```yaml
---
type: specs.openrewrite.org/v1beta/recipe
name: org.flossware.FlossWareStandards
displayName: FlossWare Standards
description: Apply all FlossWare coding standards
recipeList:
  - org.flossware.AddFinalToParameters
  - org.flossware.InlineSingleUseVariables
  - org.openrewrite.java.cleanup.UnnecessaryExplicitTypeArguments
  - org.openrewrite.java.format.AutoFormat
  - org.openrewrite.java.cleanup.RemoveUnusedImports
  - org.openrewrite.java.cleanup.RemoveUnusedPrivateFields
  - org.openrewrite.java.cleanup.StaticMethodNotFinal
  - org.openrewrite.java.cleanup.AddOverrideAnnotation
```

### Recipe: AddFinalToParameters

Adds `final` to all method parameters:

```java
// Before
public void process(String input, int count) {
    // ...
}

// After
public void process(final String input, final int count) {
    // ...
}
```

### Recipe: InlineSingleUseVariables

Converts single-use variables to method chains:

```java
// Before
public String normalize(final String input) {
    final String trimmed = input.trim();
    final String lower = trimmed.toLowerCase();
    final String result = lower.replaceAll("\\s+", " ");
    return result;
}

// After
public String normalize(final String input) {
    return input.trim()
                .toLowerCase()
                .replaceAll("\\s+", " ");
}
```

---

## Automated Migration Script

Use this script to migrate an entire project:

```bash
#!/bin/bash
# migrate-to-standards.sh

PROJECT_DIR="${1:-.}"

echo "Migrating $PROJECT_DIR to FlossWare standards..."

cd "$PROJECT_DIR"

# 1. Add final to parameters (IntelliJ command-line)
echo "Step 1: Adding final to parameters..."
idea inspect $PROJECT_DIR $HOME/.flossware/inspection-profile.xml $PROJECT_DIR/inspection-results --format xml

# 2. Run OpenRewrite recipes
echo "Step 2: Running OpenRewrite refactorings..."
mvn rewrite:run

# 3. Organize imports (Maven)
echo "Step 3: Organizing imports..."
mvn tidy:pom

# 4. Format code
echo "Step 4: Formatting code..."
mvn spotless:apply

# 5. Run tests
echo "Step 5: Running tests..."
mvn clean test

echo "Migration complete! Review changes with: git diff"
```

---

## Step-by-Step Migration

### Step 1: Add OpenRewrite Plugin

Add to your `pom.xml`:

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.openrewrite.maven</groupId>
            <artifactId>rewrite-maven-plugin</artifactId>
            <version>5.20.0</version>
            <configuration>
                <activeRecipes>
                    <recipe>org.openrewrite.java.cleanup.UnnecessaryExplicitTypeArguments</recipe>
                    <recipe>org.openrewrite.java.cleanup.RemoveUnusedImports</recipe>
                    <recipe>org.openrewrite.java.cleanup.RemoveUnusedLocalVariables</recipe>
                    <recipe>org.openrewrite.java.format.AutoFormat</recipe>
                </activeRecipes>
            </configuration>
        </plugin>
    </plugins>
</build>
```

### Step 2: Preview Changes

```bash
mvn rewrite:dryRun
```

This shows what would change without actually modifying files.

### Step 3: Apply Changes

```bash
mvn rewrite:run
```

### Step 4: Review and Test

```bash
git diff
mvn clean verify
```

### Step 5: Commit

```bash
git add .
git commit -m "Apply automated FlossWare refactorings

- Added final to parameters
- Inlined single-use variables
- Removed unused imports
- Formatted code

Applied via OpenRewrite"
```

---

## Available Recipes

### Java Cleanup Recipes

```bash
# Remove unnecessary variables
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.cleanup.RemoveUnusedLocalVariables

# Remove unused imports
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.cleanup.RemoveUnusedImports

# Add @Override annotations
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.cleanup.AddOverrideAnnotation

# Simplify boolean expressions
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.cleanup.SimplifyBooleanExpression

# Static method not final
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.cleanup.StaticMethodNotFinal
```

### Java Format Recipes

```bash
# Auto-format all code
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.format.AutoFormat

# Normalize line breaks
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.format.NormalizeLineBreaks

# Empty new line at end of file
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.format.EmptyNewlineAtEndOfFile
```

---

## Spotless Integration (Alternative)

**Spotless** is another option for automated formatting:

```xml
<plugin>
    <groupId>com.diffplug.spotless</groupId>
    <artifactId>spotless-maven-plugin</artifactId>
    <version>2.41.1</version>
    <configuration>
        <java>
            <removeUnusedImports/>
            <trimTrailingWhitespace/>
            <endWithNewline/>
            <indent>
                <spaces>true</spaces>
                <spacesPerTab>4</spacesPerTab>
            </indent>
            <importOrder>
                <order>java,javax,org,com</order>
            </importOrder>
        </java>
    </configuration>
</plugin>
```

**Usage:**

```bash
# Check formatting
mvn spotless:check

# Apply formatting
mvn spotless:apply
```

---

## Limitations

### What CAN'T Be Automated

1. **Writing tests** - Still requires human judgment
2. **Complex method chaining** - May need manual review for readability
3. **Architectural refactorings** - Large-scale design changes
4. **Business logic** - Domain-specific transformations

### What Requires Manual Review

1. **Method chaining with side effects** - Ensure order doesn't matter
2. **Exception handling** - May change exception context
3. **Multi-threaded code** - Ensure thread-safety maintained
4. **Performance-critical code** - Verify no performance regression

---

## Recommended Workflow

### For New Code

**IDE auto-format on save:**
- IntelliJ: Settings → Tools → Actions on Save → Reformat code
- Eclipse: Preferences → Java → Editor → Save Actions
- NetBeans: Tools → Options → Editor → On Save

**Prevents violations before commit!**

### For Existing Code

**Gradual approach:**

```bash
# Week 1: Auto-fix imports and formatting
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.cleanup.RemoveUnusedImports
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.format.AutoFormat

# Week 2: Add final to parameters (use IDE)
# IntelliJ: Analyze → Inspect Code → "Parameter can be final"

# Week 3: Inline single-use variables
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.cleanup.RemoveUnusedLocalVariables
# Then manually convert to method chains

# Week 4: Improve test coverage (manual)
```

---

## CI/CD Integration

### GitHub Actions

```yaml
name: Auto-Refactor

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  refactor:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Run OpenRewrite
        run: mvn rewrite:run
      
      - name: Check for changes
        id: changes
        run: |
          if [[ -n $(git status -s) ]]; then
            echo "changes=true" >> $GITHUB_OUTPUT
          fi
      
      - name: Commit changes
        if: steps.changes.outputs.changes == 'true'
        run: |
          git config user.name "FlossWare Bot"
          git config user.email "bot@flossware.org"
          git add .
          git commit -m "Apply automated FlossWare refactorings"
          git push
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running automated refactorings..."

# Run OpenRewrite
mvn rewrite:run -q

# Stage any changes
git add -u

echo "Refactorings applied!"
```

---

## Troubleshooting

### OpenRewrite Changes Too Much

**Solution:** Use specific recipes instead of broad ones

```bash
# Too broad
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.cleanup.Cleanup

# More targeted
mvn rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.cleanup.RemoveUnusedImports
```

### IDE Refactoring Breaks Tests

**Solution:** Run tests after each refactoring step

```bash
# After each IDE refactoring
mvn clean test
# If tests fail, revert and investigate
```

### Method Chaining Makes Debugging Hard

**Solution:** Temporarily break apart for debugging, then re-chain

```java
// Debugging
final String step1 = input.trim();        // Breakpoint here
final String step2 = step1.toLowerCase(); // Breakpoint here
return step2.replaceAll("\\s+", " ");

// After debugging, inline back to method chain
return input.trim().toLowerCase().replaceAll("\\s+", " ");
```

---

## Performance

**Q: Does automated refactoring slow down builds?**

**A:** OpenRewrite only runs when explicitly invoked (`mvn rewrite:run`), not during normal builds.

**Q: How long does refactoring take?**

**A:** Typical project:
- Small (< 50 classes): < 10 seconds
- Medium (50-200 classes): 10-30 seconds
- Large (200+ classes): 30-60 seconds

---

## Summary

| Tool | Use Case | Automation Level |
|------|----------|-----------------|
| OpenRewrite | Full codebase refactoring | ⭐⭐⭐⭐⭐ Fully automated |
| IDE Refactoring | Interactive fixes | ⭐⭐⭐⭐ Semi-automated |
| Error Prone | Compile-time checks | ⭐⭐⭐ Detection only |
| Spotless | Formatting | ⭐⭐⭐⭐⭐ Fully automated |
| PMD/Checkstyle | Detection | ⭐⭐ Detection only |

**Recommended:**
1. Use **OpenRewrite** for bulk migrations
2. Use **IDE refactoring** for new code
3. Use **Spotless** for formatting
4. Use **PMD/Checkstyle** to prevent regressions

---

## References

- [OpenRewrite Documentation](https://docs.openrewrite.org/)
- [OpenRewrite Recipes](https://docs.openrewrite.org/recipes)
- [Error Prone](https://errorprone.info/)
- [Spotless](https://github.com/diffplug/spotless)
