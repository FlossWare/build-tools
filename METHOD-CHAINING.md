# Method Chaining Style Guide

FlossWare prefers **method chaining** (fluent style) over temporary variables for improved readability and reduced code clutter.

## Core Principle

> **Prefer dotted method calls over single-use temporary variables**

## Basic Examples

### ✓ GOOD - Method Chaining

```java
public String normalize(final String input) {
    return input.trim()
                .toLowerCase()
                .replaceAll("\\s+", " ");
}
```

### ✗ BAD - Unnecessary Temporaries

```java
public String normalize(final String input) {
    final String trimmed = input.trim();
    final String lower = trimmed.toLowerCase();
    final String result = lower.replaceAll("\\s+", " ");
    return result;
}
```

**Why it's bad:** Each temporary variable is used exactly once, adding visual clutter without improving clarity.

## When to Chain

### ✓ Chain for Linear Transformations

```java
// Good: Clear transformation pipeline
return user.getName()
           .trim()
           .toUpperCase()
           .substring(0, 10);
```

### ✓ Chain for Fluent APIs

```java
// Good: Builder pattern
return new UserBuilder()
    .withName("Alice")
    .withAge(30)
    .withEmail("alice@example.com")
    .build();
```

### ✓ Chain for Streams

```java
// Good: Stream operations naturally chain
return items.stream()
            .filter(Item::isActive)
            .map(Item::getName)
            .sorted()
            .collect(Collectors.toList());
```

### ✓ Chain for Simple Conditionals

```java
// Good: Optional chaining
return userRepository.findById(id)
                     .map(User::getEmail)
                     .orElse("unknown@example.com");
```

## When NOT to Chain

### ✗ Don't Chain When Debugging is Needed

If you need to inspect intermediate values during development:

```java
// Better for debugging
final List<Item> activeItems = items.stream()
                                     .filter(Item::isActive)
                                     .collect(Collectors.toList());

final List<String> names = activeItems.stream()
                                       .map(Item::getName)
                                       .collect(Collectors.toList());

return names.stream()
            .sorted()
            .collect(Collectors.toList());
```

**Use this temporarily**, then refactor to chaining once debugged.

### ✗ Don't Chain When Reusing Values

If a value is used multiple times, use a variable:

```java
// Good: userId used multiple times
public User updateUser(final String userId, final UserData data) {
    final User user = userRepository.findById(userId)
                                    .orElseThrow(() -> new NotFoundException(userId));
    
    // user is reused here
    user.setName(data.getName());
    user.setEmail(data.getEmail());
    
    return userRepository.save(user);
}
```

### ✗ Don't Chain When It Hurts Readability

Chains longer than 5-6 methods can be hard to read:

```java
// Bad: Too long, hard to follow
return input.trim()
            .toLowerCase()
            .replaceAll("\\s+", " ")
            .replaceAll("[^a-z0-9 ]", "")
            .substring(0, Math.min(input.length(), 100))
            .split(" ")[0]
            .concat("-suffix");

// Better: Break into logical steps
final String normalized = input.trim()
                               .toLowerCase()
                               .replaceAll("\\s+", " ")
                               .replaceAll("[^a-z0-9 ]", "");

final String truncated = normalized.substring(0, Math.min(normalized.length(), 100));

return truncated.split(" ")[0] + "-suffix";
```

### ✗ Don't Chain When Exception Handling Needs Context

```java
// Bad: Which method threw the exception?
try {
    return input.trim().toLowerCase().substring(0, 5);
} catch (final IndexOutOfBoundsException e) {
    // Can't tell which step failed
}

// Better: Separate for clarity
try {
    final String cleaned = input.trim().toLowerCase();
    return cleaned.substring(0, 5);
} catch (final IndexOutOfBoundsException e) {
    // Now we know substring() failed
}
```

## Variables: When They're Required

### 1. Method Parameters (Always Final)

```java
// ✓ Parameters must always be final
public void process(final String input, final int count) {
    // ...
}
```

### 2. Values Used Multiple Times

```java
// ✓ Variable used 3 times - justified
public void logAndSave(final String userId) {
    final User user = findUser(userId);
    
    logger.info("Processing user: {}", user.getName());
    user.setLastAccessed(LocalDateTime.now());
    userRepository.save(user);
}
```

### 3. Complex Expressions

```java
// ✓ Variable clarifies intent
final boolean isEligible = user.isActive() 
                        && user.getAge() >= 18 
                        && !user.isBanned();

if (isEligible) {
    // ...
}
```

### 4. Loop Variables

```java
// ✓ Loop variable needed
for (final String item : items) {
    process(item);
}
```

### 5. Try-with-Resources

```java
// ✓ Resource variables required
try (final BufferedReader reader = new BufferedReader(new FileReader(file))) {
    return reader.lines().collect(Collectors.joining("\n"));
}
```

## Formatting Method Chains

### Short Chains (2-3 calls)

```java
// One line is fine
return input.trim().toLowerCase();
```

### Medium Chains (4-6 calls)

```java
// One method per line, aligned
return input.trim()
            .toLowerCase()
            .replaceAll("\\s+", " ")
            .substring(0, 10);
```

### Long Chains (7+ calls)

```java
// Group logically with blank lines
return items.stream()
            
            // Filtering
            .filter(Item::isActive)
            .filter(item -> item.getPrice() > 0)
            
            // Transformation
            .map(Item::getName)
            .map(String::toUpperCase)
            
            // Collection
            .sorted()
            .collect(Collectors.toList());
```

## Common Patterns

### String Manipulation

```java
// ✓ Good
public String formatName(final String name) {
    return name.trim()
               .toLowerCase()
               .replaceAll("[^a-z]", "");
}
```

### Collection Processing

```java
// ✓ Good
public List<String> getActiveUserEmails(final List<User> users) {
    return users.stream()
                .filter(User::isActive)
                .map(User::getEmail)
                .collect(Collectors.toList());
}
```

### Optional Handling

```java
// ✓ Good
public String getUserEmail(final String userId) {
    return userRepository.findById(userId)
                         .map(User::getEmail)
                         .orElseThrow(() -> new NotFoundException(userId));
}
```

### Builder Pattern

```java
// ✓ Good
public HttpRequest buildRequest(final String url) {
    return HttpRequest.newBuilder()
                      .uri(URI.create(url))
                      .header("Content-Type", "application/json")
                      .timeout(Duration.ofSeconds(30))
                      .GET()
                      .build();
}
```

### Validation Chains

```java
// ✓ Good
public void validate(final User user) {
    Validator.of(user)
             .ensure(u -> u.getName() != null, "Name required")
             .ensure(u -> u.getAge() >= 18, "Must be adult")
             .ensure(u -> u.getEmail().contains("@"), "Invalid email")
             .validate();
}
```

## Testing with Method Chains

### Test Method Chains Directly

```java
@Test
public void testNormalize() {
    assertEquals("hello world", normalize("  HELLO   WORLD  "));
}
```

No need to test each intermediate step separately - test the final result.

### When to Test Intermediate Steps

Only when the chain is complex enough to warrant it:

```java
@Test
public void testComplexTransformation() {
    final String input = "Test@Input#123";
    
    // Test the full chain
    assertEquals("testinput", processString(input));
    
    // Optionally test key intermediate states if needed
    final String afterTrim = input.trim();
    final String afterLower = afterTrim.toLowerCase();
    // ... but prefer testing just the final result
}
```

## IDE Support

### IntelliJ IDEA

**Inline Variable (Ctrl+Alt+N):**
- Select variable
- Ctrl+Alt+N
- IntelliJ replaces all usages with the expression

**Extract Variable (Ctrl+Alt+V):**
- Select expression
- Ctrl+Alt+V (when you need to break apart a chain for debugging)

### Eclipse

**Inline (Alt+Shift+I):**
- Select variable
- Alt+Shift+I

### NetBeans

**Inline (Ctrl+R):**
- Select variable
- Refactor → Inline

### VS Code

**Inline Variable:**
- Select variable
- Right-click → Refactor → Inline Variable

## PMD Rules

FlossWare uses these PMD rules to enforce chaining:

1. **UnnecessaryLocalBeforeReturn** - Detects:
   ```java
   // ✗ BAD
   final String result = input.trim();
   return result;
   
   // ✓ GOOD
   return input.trim();
   ```

2. **UnusedLocalVariable** - Detects variables that are never used

## Migration Guide

If you have existing code with many temporary variables:

### Step 1: Identify Single-Use Variables

```bash
# Find variables used only once (manual review needed)
grep -n "final.*=" YourClass.java
```

### Step 2: Use IDE Inline Refactoring

1. Place cursor on variable
2. Ctrl+Alt+N (IntelliJ) or Alt+Shift+I (Eclipse)
3. IDE automatically inlines the variable

### Step 3: Verify Tests Still Pass

```bash
mvn clean verify
```

### Example Refactoring

**Before:**
```java
public String process(final String input) {
    final String trimmed = input.trim();
    final String lower = trimmed.toLowerCase();
    final String replaced = lower.replaceAll("\\s+", " ");
    return replaced;
}
```

**After:**
```java
public String process(final String input) {
    return input.trim()
                .toLowerCase()
                .replaceAll("\\s+", " ");
}
```

## Performance Considerations

### Method Chaining Performance

**Myth:** "Method chaining is slower"

**Reality:** Modern JVMs optimize chained calls just as well as temporary variables. No measurable difference.

**Exception:** Very hot loops (millions of iterations) - but even then, the JIT compiler usually optimizes it.

### When Performance Matters

Profile first, optimize later:

```bash
# Use JMH for micro-benchmarking if needed
mvn clean test -Pbenchmark
```

## Summary

| Scenario | Approach |
|----------|----------|
| Single-use temporary | ✓ Chain methods |
| Value used 2+ times | ✓ Use variable |
| Parameters | ✓ Always final |
| Linear transformation | ✓ Chain methods |
| Complex logic | ✓ Use descriptive variables |
| Debugging needed | ⚠️ Temporarily use variables |
| Stream operations | ✓ Chain methods |
| Builder pattern | ✓ Chain methods |

**Golden Rule:** If a variable is used only once to pass a value to the next operation, eliminate it and chain instead.

## References

- [Effective Java (Item 2): Consider a builder when faced with many constructor parameters](https://www.oreilly.com/library/view/effective-java/9780134686097/)
- [Java Streams Guide](https://docs.oracle.com/javase/8/docs/api/java/util/stream/package-summary.html)
- [PMD UnnecessaryLocalBeforeReturn](https://pmd.github.io/latest/pmd_rules_java_codestyle.html#unnecessarylocalbeforereturn)
