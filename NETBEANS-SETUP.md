# NetBeans IDE Setup for FlossWare Standards

This guide configures NetBeans to work seamlessly with FlossWare build standards.

## Quick Setup

1. Open your FlossWare project in NetBeans
2. Right-click project → **Properties**
3. Follow the sections below

---

## Checkstyle Integration

### Option 1: Use Maven Plugin (Recommended)

NetBeans will automatically recognize the Checkstyle plugin in your `pom.xml` and show violations.

**Enable in NetBeans:**
1. **Tools** → **Plugins** → **Available Plugins**
2. Search for **"Checkstyle"** or **"Code Quality"**
3. Install if available

**View Violations:**
- **Window** → **Action Items**
- Checkstyle violations appear here after `mvn verify`

### Option 2: Manual Checkstyle Configuration

1. **Tools** → **Options** → **Editor** → **Hints**
2. Navigate to **Java** → **Code Style**
3. Enable these hints:
   - ☑ Local Variable or Parameter Can Be Final
   - ☑ Unnecessary Import Statement
   - ☑ Unused Import
   - ☑ Missing final on Parameters

---

## Final Variables Support

### Enable Hints

**Tools** → **Options** → **Editor** → **Hints** → **Java** → **Code Style**

Enable and set to **Warning** or **Error**:
- ☑ **Local Variable or Parameter Can Be Final**
- ☑ **Field Can Be Final**

### Quick Fix

When you see a hint icon (💡) in the margin:
1. Click the icon OR press **Alt+Enter**
2. Select **"Add 'final' modifier"**

### Bulk Fix

To fix all occurrences in a file:
1. **Source** → **Inspect and Transform**
2. Select **"Local Variable or Parameter Can Be Final"**
3. Click **Inspect**
4. Review suggestions → Click **Do Refactoring**

---

## Code Templates with Final

### Create Templates

**Tools** → **Options** → **Editor** → **Code Templates** → **Java**

Add these abbreviations:

**`pf`** - Private final field:
```java
private final ${type} ${name};
```

**`psf`** - Public static final constant:
```java
public static final ${type} ${NAME} = ${value};
```

**`m`** - Method with final parameters:
```java
${public} ${returnType} ${methodName}(final ${paramType} ${paramName}) {
    ${cursor}
}
```

**`fore`** - Enhanced for loop with final:
```java
for (final ${type} ${var} : ${collection}) {
    ${cursor}
}
```

**`try`** - Try-catch with final:
```java
try {
    ${cursor}
} catch (final ${Exception} e) {
    ${cursor}
}
```

### Usage

Type the abbreviation (e.g., `pf`) and press **Tab** to expand.

---

## Code Formatting

### Import FlossWare EditorConfig

NetBeans has built-in EditorConfig support (NetBeans 8.2+).

1. Copy `.editorconfig` to your project root:
   ```bash
   cp flossware-build-tools/.editorconfig yourproject/
   ```

2. NetBeans will automatically apply the settings

### Manual Formatting Setup

If EditorConfig isn't working, configure manually:

**Tools** → **Options** → **Editor** → **Formatting** → **Java**

**Tabs and Indents:**
- Tab Size: `4`
- Indent Size: `4`
- ☐ Expand Tabs to Spaces (use spaces)
- Right Margin: `120`

**Blank Lines:**
- Before Package: `0`
- After Package: `1`
- Before Imports: `1`
- After Imports: `1`

**Wrapping:**
- Method Parameters: `Never`
- Method Call Arguments: `Never`
- (Adjust as needed, FlossWare prefers minimal wrapping)

**Imports:**
- ☐ Use Single Class Import (NO star imports)
- ☑ Separate static imports

---

## Maven Integration

### Run Maven Goals from NetBeans

**Right-click project** → **Custom** → **Goals...**

Common goals:
```bash
# Full verification with all checks
clean verify

# Checkstyle only
checkstyle:check

# JaCoCo coverage report
jacoco:report
```

### Add Custom Actions

**Right-click project** → **Properties** → **Actions**

**Action: "Check Standards"**
- Goals: `checkstyle:check pmd:check spotbugs:check`
- Set Properties: (none)

**Action: "Coverage Report"**
- Goals: `clean test jacoco:report`
- Set Properties: (none)

Now you can run these from **Run** → **Custom Build**.

---

## JaCoCo Coverage Visualization

### View Coverage in NetBeans

After running tests:

1. Run: `mvn clean test jacoco:report`
2. Open: `target/site/jacoco/index.html` in browser
3. Or use NetBeans HTML viewer:
   - **File** → **Open File** → `target/site/jacoco/index.html`

### Install Code Coverage Plugin (Optional)

**Tools** → **Plugins** → **Available Plugins**
- Search for **"Code Coverage"** or **"JaCoCo"**
- Install if available

This shows coverage inline in the editor (green/red highlighting).

---

## Mockito Support

NetBeans works with both `mockito-core` and `mockito-inline`.

For the recommended `mockito-inline`:
```xml
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-inline</artifactId>
    <version>5.2.0</version>
    <scope>test</scope>
</dependency>
```

No special NetBeans configuration needed.

---

## Troubleshooting

### Checkstyle Violations Not Showing

1. Ensure you've run `mvn verify` at least once
2. Check **Window** → **Action Items**
3. Verify the plugin is in your `pom.xml`

### Code Templates Not Working

1. Make sure you're in a Java file
2. Type the abbreviation (e.g., `pf`)
3. Press **Tab** (not Enter)
4. Check **Tools** → **Options** → **Editor** → **Code Templates**

### EditorConfig Not Applied

1. Verify `.editorconfig` is in project root
2. Check NetBeans version (8.2+ required)
3. Restart NetBeans

### Final Modifier Hints Not Appearing

1. **Tools** → **Options** → **Editor** → **Hints** → **Java**
2. Ensure hints are enabled and set to Warning/Error
3. Click **Manage Hints** → **Enable All** for Code Style

---

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Quick Fix (Add final) | **Alt+Enter** |
| Format Code | **Alt+Shift+F** |
| Organize Imports | **Alt+Shift+I** |
| Fix Imports | **Ctrl+Shift+I** |
| Code Completion | **Ctrl+Space** |
| Show Hints | **Alt+Enter** |
| Inspect and Transform | **Alt+Shift+I** (then select option) |

---

## Project Properties Integration

### Set Build Standards in Project

**Right-click project** → **Properties** → **Build** → **Compile**

**Java Platform:** Java 17+ (or your target)

**Additional Compiler Options:**
```
-Xlint:all -Werror
```

This makes compiler warnings into errors (strict mode).

---

## Testing Configuration

### JUnit 5 Support

NetBeans 11+ has built-in JUnit 5 support.

**Create Test (Ctrl+Shift+U):**
- Right-click class → **Tools** → **Create/Update Tests**
- NetBeans generates test skeleton

**Run Tests:**
- **Alt+F6** (Test Project)
- **Ctrl+F6** (Test File)

### Test Coverage Highlighting

With JaCoCo reports, you can view coverage:

1. Run tests: `mvn clean test`
2. Generate report: `mvn jacoco:report`
3. Open `target/site/jacoco/index.html`

---

## Daily Workflow

1. **Open Project** in NetBeans
2. **Make Changes** with auto-final templates (`pf`, `m`, etc.)
3. **See Hints** as you type (Alt+Enter to fix)
4. **Format Code** (Alt+Shift+F) before commit
5. **Run Standards Check**: Right-click → Custom → `clean verify`
6. **Fix Violations** shown in Action Items
7. **Commit** when all checks pass

---

## Integration with FlossWare Standards

All FlossWare standards work with NetBeans:

✓ **Checkstyle** - Via Maven plugin + Action Items  
✓ **PMD** - Via Maven plugin  
✓ **SpotBugs** - Via Maven plugin  
✓ **JaCoCo** - Coverage reports in browser  
✓ **Final Variables** - Built-in hints + quick fix  
✓ **EditorConfig** - Native support (8.2+)  
✓ **Version Enforcement** - Maven enforcer runs on build  
✓ **Mockito** - Works with mockito-inline  

---

## Resources

- [NetBeans Java Editor](https://netbeans.apache.org/kb/docs/java/editor-codereference.html)
- [NetBeans Code Templates](https://netbeans.apache.org/kb/docs/java/editor-inspect-transform.html)
- [NetBeans Maven Support](https://netbeans.apache.org/kb/docs/java/maven-hib-java-se.html)
