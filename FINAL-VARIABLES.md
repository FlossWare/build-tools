# Final Parameters Standard

FlossWare enforces the use of `final` on **parameters only** to prevent accidental reassignment.

**Important:** FlossWare **prefers method chaining** over local variables. See [METHOD-CHAINING.md](METHOD-CHAINING.md) for the full style guide.

## What's Enforced

### 1. Final Parameters (Required)

All method, constructor, catch block, and enhanced-for parameters must be `final`:

```java
// ✗ BAD - Missing final
public void process(String input) {
    // ...
}

// ✓ GOOD - Parameters are final
public void process(final String input) {
    // ...
}
```

### 2. Local Variables (NOT Enforced)

Local variables do **not** require `final`. Prefer method chaining instead:

```java
// ✓ PREFERRED - Method chaining, no temporaries
public String normalize(final String input) {
    return input.trim()
                .toLowerCase()
                .replaceAll("\\s+", " ");
}

// ⚠️ ACCEPTABLE - Variables when reused or for clarity
public void update(final String userId) {
    final User user = findUser(userId);  // Reused multiple times
    
    logger.info("Processing: {}", user.getName());
    user.setLastAccessed(LocalDateTime.now());
    save(user);
}

// ✗ AVOID - Single-use temporary variables
public String normalize(final String input) {
    final String trimmed = input.trim();
    final String lower = trimmed.toLowerCase();
    return lower.replaceAll("\\s+", " ");
}
```

### 3. Enhanced For-Each Loops

Loop variables must be `final` (they are parameters):

```java
// ✗ BAD - Missing final
for (String item : items) {
    process(item);
}

// ✓ GOOD - Loop variable is final
for (final String item : items) {
    process(item);
}

// ✓ BETTER - Method chaining when possible
items.stream()
     .forEach(this::process);
```

### 4. Try-Catch Blocks

Exception parameters must be `final`:

```java
// ✗ BAD - Missing final
try {
    riskyOperation();
} catch (IOException e) {
    log.error("Failed", e);
}

// ✓ GOOD - Exception parameter is final
try {
    riskyOperation();
} catch (final IOException e) {
    log.error("Failed", e);
}
```

## Why Final Parameters?

### Benefits

1. **Prevents Accidental Reassignment**
   ```java
   public void process(final String input) {
       // input = "changed";  // Compile error - caught immediately
   }
   ```

   Parameters are method contract - they shouldn't be modified.

2. **Improves Method Clarity**
   - Signals that parameters are inputs only, never outputs
   - Makes method behavior easier to reason about
   - Common source of bugs: reassigning parameters

3. **Catches Logic Errors**
   ```java
   // ✗ BAD - Reassigning parameter
   public void process(String input) {
       if (input == null) {
           input = "";  // Bug: loses information about null
       }
       log(input);
   }
   
   // ✓ GOOD - Can't reassign, forces better design
   public void process(final String input) {
       final String sanitized = input != null ? input : "";
       log(sanitized);
   }
   ```

4. **Lambda Compatibility**
   - Final parameters work in lambdas without issues
   - Prevents "variable must be final" errors

## When NOT to Use Final

Variables that ARE reassigned should NOT be final:

```java
// ✓ CORRECT - Variable is reassigned, so NOT final
public int sum(final List<Integer> numbers) {
    int total = 0;  // Not final - will be reassigned
    for (final Integer num : numbers) {
        total += num;  // Reassignment
    }
    return total;
}

// ✓ CORRECT - Counter variables
public String format(final String[] parts) {
    final StringBuilder result = new StringBuilder();
    int index = 0;  // Not final - reassigned in loop
    for (final String part : parts) {
        result.append(index++).append(": ").append(part);
    }
    return result.toString();
}
```

## Gradual Adoption

If you have many existing violations, adopt gradually:

### Option 1: Disable Temporarily

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-checkstyle-plugin</artifactId>
    <configuration>
        <!-- Temporarily disable to see other violations -->
        <violationSeverity>error</violationSeverity>
        <suppressionsLocation>checkstyle-suppressions.xml</suppressionsLocation>
    </configuration>
</plugin>
```

Create `checkstyle-suppressions.xml`:

```xml
<?xml version="1.0"?>
<!DOCTYPE suppressions PUBLIC
    "-//Checkstyle//DTD SuppressionFilter Configuration 1.2//EN"
    "https://checkstyle.org/dtds/suppressions_1_2.dtd">
<suppressions>
    <!-- Temporarily suppress final checks -->
    <suppress checks="FinalParameters" files="."/>
    <suppress checks="FinalLocalVariables" files="."/>
</suppressions>
```

### Option 2: Fix Incrementally

Use your IDE to auto-fix:

**IntelliJ IDEA:**
1. Go to **Analyze** → **Inspect Code**
2. Enable **"Local variable or parameter can be final"**
3. Run inspection
4. Right-click violations → **Make final**

**Eclipse:**
1. **Source** → **Clean Up**
2. Configure → Check **"Add final modifier to private fields"**, **"Add final modifier to method parameters"**, **"Add final modifier to local variables"**
3. Apply

**VS Code (with Java extensions):**
1. **Code Actions** (Ctrl+.)
2. Select **"Add final modifier"**

### Option 3: Fix File by File

Focus on new code first:

```bash
# Fix only new/modified files
git diff --name-only | grep '\.java$' | while read file; do
    echo "Review and fix final modifiers in: $file"
done
```

## IDE Configuration

### NetBeans - Enable Warnings

**Tools** → **Options** → **Editor** → **Hints** → **Java** → **Code Style**
- ☑ **"Local Variable or Parameter Can Be Final"**
- Set severity to **Warning**

**Tools** → **Options** → **Editor** → **Formatting** → **Java**
- Tab: **Blank Lines**
- Tab: **Wrapping**
- Tab: **Alignment**

### NetBeans - Auto-Add Final on Generation

**Tools** → **Options** → **Editor** → **Code Templates**

Add custom templates with `final`:

```java
// For variables (type "pf" + Tab)
private final ${type} ${name};

// For method parameters (modify existing templates)
public ${type} ${methodName}(final ${paramType} ${paramName}) {
    ${cursor}
}
```

**Tools** → **Options** → **Editor** → **Hints** → **Java** → **Code Style**
- ☑ **Local Variable or Parameter Can Be Final**
- Click **Configure** → Set to **Warning** or **Error**

### NetBeans - Quick Fix

When you see a hint (lightbulb), press **Alt+Enter** to apply the fix:
- Position cursor on variable/parameter
- **Alt+Enter** → **Add 'final' modifier**

### IntelliJ IDEA - Enable Warnings

**Settings** → **Editor** → **Inspections** → **Java** → **Code style issues**
- ☑ **"Local variable or parameter can be final"**
- ☑ **"Method parameter can be final"**

Set to **Warning** to see yellow highlights.

### IntelliJ IDEA - Auto-Add on Save

**Settings** → **Tools** → **Actions on Save**
- ☑ **Reformat code**
- ☑ **Optimize imports**

Then: **Editor** → **Code Style** → **Java** → **Code Generation**
- ☑ **Make generated local variables final**
- ☑ **Make generated parameters final**

### Eclipse - Auto-Add on Save

**Preferences** → **Java** → **Editor** → **Save Actions**
- ☑ **Perform the selected actions on save**
- ☑ **Additional actions**
- Configure → **Code Style**:
  - ☑ **Add final modifier to private fields**
  - ☑ **Add final modifier to method parameters**
  - ☑ **Add final modifier to local variables**

### VS Code (with Java extensions)

**Settings** → **Extensions** → **Java**
- Install **Language Support for Java** by Red Hat
- Install **Checkstyle for Java**

Add to `.vscode/settings.json`:
```json
{
  "java.checkstyle.configuration": "${workspaceFolder}/flossware-build-tools/src/main/resources/flossware-checkstyle.xml",
  "java.cleanup.actionsOnSave": [
    "addFinalModifier"
  ]
}
```

## Common Patterns

### Builders

```java
public class User {
    private final String name;
    private final int age;
    
    private User(final Builder builder) {
        this.name = builder.name;
        this.age = builder.age;
    }
    
    public static class Builder {
        private String name;  // Not final - will be set
        private int age;      // Not final - will be set
        
        public Builder name(final String name) {
            this.name = name;
            return this;
        }
        
        public Builder age(final int age) {
            this.age = age;
            return this;
        }
        
        public User build() {
            return new User(this);
        }
    }
}
```

### Stream Operations

```java
public List<String> processItems(final List<Item> items) {
    return items.stream()
        .filter(item -> item.isActive())  // item is effectively final
        .map(item -> item.getName())
        .collect(Collectors.toList());
}
```

### Method References

```java
public void processNames(final List<String> names) {
    names.forEach(System.out::println);  // names must be final
}
```

## Checking Compliance

### Maven Build

```bash
# Check for violations
mvn checkstyle:check

# Generate report
mvn checkstyle:checkstyle
open target/site/checkstyle.html
```

### Command Line (checkstyle CLI)

```bash
# Install checkstyle
brew install checkstyle  # macOS
# or download from https://github.com/checkstyle/checkstyle/releases

# Run check
checkstyle -c flossware-build-tools/src/main/resources/flossware-checkstyle.xml src/
```

## FAQ

**Q: Does `final` make code slower?**  
A: No. The JVM often optimizes `final` variables better. Performance impact is negligible.

**Q: Isn't this too verbose?**  
A: Modern IDEs auto-add `final` modifiers. Once you're used to it, it becomes automatic and improves code quality.

**Q: What about fields?**  
A: Fields should also be `final` when possible, but that's enforced differently (constructor must initialize them).

**Q: Can I use this with Lombok?**  
A: Yes! Lombok's `@Value` and `@Builder` automatically make fields `final`.

```java
@Value
public class User {
    String name;  // Automatically final
    int age;      // Automatically final
}
```

## References

- [Effective Java (Item 17): Minimize Mutability](https://www.oreilly.com/library/view/effective-java/9780134686097/)
- [Checkstyle: FinalParameters](https://checkstyle.sourceforge.io/checks/misc/finalparameters.html)
- [Checkstyle: FinalLocalVariables](https://checkstyle.sourceforge.io/checks/coding/finallocalvariables.html)
