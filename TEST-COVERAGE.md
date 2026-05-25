# 100% Test Coverage Standard

FlossWare enforces 100% test coverage using JaCoCo to ensure all code is tested.

## What's Enforced

JaCoCo checks four coverage metrics, all must be 100%:

1. **Instruction Coverage** - Every bytecode instruction executed
2. **Branch Coverage** - Every if/switch branch taken
3. **Line Coverage** - Every line of code executed  
4. **Class Coverage** - Every class has at least one test

## Configuration

The JaCoCo plugin in your `pom.xml` enforces these limits:

```xml
<limit>
    <counter>INSTRUCTION</counter>
    <value>COVEREDRATIO</value>
    <minimum>1.00</minimum>  <!-- 100% -->
</limit>
<limit>
    <counter>BRANCH</counter>
    <value>COVEREDRATIO</value>
    <minimum>1.00</minimum>  <!-- 100% -->
</limit>
<limit>
    <counter>LINE</counter>
    <value>COVEREDRATIO</value>
    <minimum>1.00</minimum>  <!-- 100% -->
</limit>
<limit>
    <counter>CLASS</counter>
    <value>MISSEDCOUNT</value>
    <maximum>0</maximum>  <!-- No untested classes -->
</limit>
```

## Running Coverage Checks

### Full Build with Coverage

```bash
mvn clean verify
```

This runs tests and fails the build if coverage < 100%.

### Generate Coverage Report Only

```bash
mvn clean test jacoco:report
```

View the report:
```bash
open target/site/jacoco/index.html
```

### Check Coverage Without Failing

```bash
mvn clean test jacoco:report
# Report shows coverage but doesn't fail build
```

## Understanding the Report

### HTML Report Structure

```
target/site/jacoco/
├── index.html              # Overall summary
├── com.example/            # Package coverage
│   ├── index.html
│   └── MyClass.html        # Class coverage (shows lines)
└── jacoco.xml              # Machine-readable report
```

### Coverage Indicators

- **Green** - Line covered by tests
- **Yellow** - Branch partially covered (e.g., only if, not else)
- **Red** - Line not covered

### Example Report

```
Element         Instruction  Branch  Line   Complexity
MyClass         100%         100%    100%   10/10
  myMethod()    100%         100%    100%   3/3
  otherMethod() 100%         100%    100%   7/7
```

## Achieving 100% Coverage

### Basic Example

**Source Code:**
```java
public class Calculator {
    public int add(final int a, final int b) {
        return a + b;
    }
    
    public int divide(final int a, final int b) {
        if (b == 0) {
            throw new IllegalArgumentException("Divide by zero");
        }
        return a / b;
    }
}
```

**Test Code (100% Coverage):**
```java
public class CalculatorTest {
    private Calculator calculator;
    
    @BeforeEach
    public void setUp() {
        calculator = new Calculator();
    }
    
    @Test
    public void testAdd() {
        assertEquals(5, calculator.add(2, 3));
        assertEquals(0, calculator.add(-1, 1));
    }
    
    @Test
    public void testDivide() {
        assertEquals(2, calculator.divide(6, 3));
    }
    
    @Test
    public void testDivideByZero() {
        assertThrows(IllegalArgumentException.class, 
            () -> calculator.divide(5, 0));
    }
}
```

**Coverage:**
- ✅ `add()` - Both lines covered
- ✅ `divide()` - All branches covered (normal + exception)
- ✅ 100% instruction, branch, line, class coverage

### Branch Coverage Example

**Source with branches:**
```java
public String getGrade(final int score) {
    if (score >= 90) {
        return "A";
    } else if (score >= 80) {
        return "B";
    } else if (score >= 70) {
        return "C";
    } else {
        return "F";
    }
}
```

**Tests for 100% branch coverage:**
```java
@Test
public void testGradeA() {
    assertEquals("A", getGrade(95));  // >= 90 branch
}

@Test
public void testGradeB() {
    assertEquals("B", getGrade(85));  // >= 80 branch
}

@Test
public void testGradeC() {
    assertEquals("C", getGrade(75));  // >= 70 branch
}

@Test
public void testGradeF() {
    assertEquals("F", getGrade(50));  // else branch
}
```

Each test covers a different branch → 100% branch coverage.

## Common Patterns

### Testing Constructors

```java
public class User {
    private final String name;
    
    public User(final String name) {
        this.name = name;
    }
    
    public String getName() {
        return name;
    }
}
```

```java
@Test
public void testConstructor() {
    final User user = new User("Alice");
    assertEquals("Alice", user.getName());
}
```

### Testing Getters/Setters

```java
public class Config {
    private String value;
    
    public String getValue() {
        return value;
    }
    
    public void setValue(final String value) {
        this.value = value;
    }
}
```

```java
@Test
public void testGetterSetter() {
    final Config config = new Config();
    config.setValue("test");
    assertEquals("test", config.getValue());
}
```

### Testing Exception Paths

```java
public void validate(final String input) {
    if (input == null) {
        throw new NullPointerException("Input cannot be null");
    }
    if (input.isEmpty()) {
        throw new IllegalArgumentException("Input cannot be empty");
    }
}
```

```java
@Test
public void testValidateNull() {
    assertThrows(NullPointerException.class, 
        () -> validate(null));
}

@Test
public void testValidateEmpty() {
    assertThrows(IllegalArgumentException.class, 
        () -> validate(""));
}

@Test
public void testValidateSuccess() {
    assertDoesNotThrow(() -> validate("valid"));
}
```

### Testing Static Methods

```java
public class MathUtils {
    public static int max(final int a, final int b) {
        return a > b ? a : b;
    }
}
```

```java
@Test
public void testMax() {
    assertEquals(5, MathUtils.max(5, 3));
    assertEquals(5, MathUtils.max(3, 5));
    assertEquals(5, MathUtils.max(5, 5));
}
```

All branches of ternary operator covered.

## Excluding Code from Coverage

Sometimes you need to exclude code that can't or shouldn't be tested:

### 1. Main Methods

```java
public static void main(final String[] args) {
    // Application entry point - often excluded
}
```

### 2. Private Constructors (Utility Classes)

```java
private Utils() {
    throw new UnsupportedOperationException("Utility class");
}
```

### 3. JaCoCo Exclusions

Add to `pom.xml`:

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <configuration>
        <excludes>
            <exclude>**/*Application.class</exclude>
            <exclude>**/Main.class</exclude>
        </excludes>
    </configuration>
</plugin>
```

**Use exclusions sparingly!** Default FlossWare standard is 100% with no exclusions.

## Gradual Adoption

If you have existing code with low coverage, adopt gradually:

### Option 1: Lower Threshold Temporarily

```xml
<limit>
    <counter>INSTRUCTION</counter>
    <value>COVEREDRATIO</value>
    <minimum>0.80</minimum>  <!-- 80% temporarily -->
</limit>
```

Then increase over time: 0.80 → 0.90 → 0.95 → 1.00

### Option 2: Per-Package Thresholds

```xml
<rule>
    <element>PACKAGE</element>
    <limits>
        <limit>
            <counter>LINE</counter>
            <value>COVEREDRATIO</value>
            <minimum>1.00</minimum>
        </limit>
    </limits>
</rule>
```

Require 100% for new packages, gradually fix old ones.

### Option 3: Coverage Ratchet

Use a plugin to ensure coverage never decreases:

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <configuration>
        <dataFile>${project.build.directory}/coverage-reports/jacoco-ut.exec</dataFile>
        <rules>
            <rule implementation="org.jacoco.maven.RuleConfiguration">
                <element>BUNDLE</element>
                <limits>
                    <limit implementation="org.jacoco.report.check.Limit">
                        <counter>INSTRUCTION</counter>
                        <value>COVEREDRATIO</value>
                        <minimum>${previous.coverage}</minimum>
                    </limit>
                </limits>
            </rule>
        </rules>
    </configuration>
</plugin>
```

Coverage must stay at or above previous run.

## CI/CD Integration

### GitHub Actions

```yaml
- name: Run Tests with Coverage
  run: mvn clean verify

- name: Upload Coverage Report
  uses: codecov/codecov-action@v3
  with:
    files: ./target/site/jacoco/jacoco.xml
```

### GitLab CI

```yaml
test:
  script:
    - mvn clean verify
  artifacts:
    reports:
      coverage_report:
        coverage_format: jacoco
        path: target/site/jacoco/jacoco.xml
```

### Jenkins

```groovy
stage('Test') {
    steps {
        sh 'mvn clean verify'
        jacoco execPattern: '**/target/jacoco.exec'
    }
}
```

## IDE Integration

### IntelliJ IDEA

1. **Run** → **Run with Coverage**
2. View coverage in editor (green/red highlighting)
3. **Analyze** → **Show Coverage Data**

### Eclipse

1. **Coverage As** → **JUnit Test**
2. View coverage in Package Explorer (color-coded)
3. **Coverage** view shows percentages

### NetBeans

1. Run: `mvn clean test jacoco:report`
2. **File** → **Open File** → `target/site/jacoco/index.html`
3. Optional: Install JaCoCo plugin for inline highlighting

### VS Code

1. Install **Coverage Gutters** extension
2. Run: `mvn clean test jacoco:report`
3. Click **Watch** in status bar
4. Coverage shows in gutters

## Best Practices

### 1. Test First (TDD)

Write tests before implementation:
```java
@Test
public void testCalculateDiscount() {
    assertEquals(90.0, calculateDiscount(100.0, 0.10));
}

// Now implement calculateDiscount()
```

### 2. Test Boundary Conditions

```java
@Test
public void testBoundaries() {
    assertEquals(0, min(0, 5));      // Lower bound
    assertEquals(100, max(50, 100)); // Upper bound
    assertEquals(5, identity(5));     // Exact value
}
```

### 3. Test Error Cases

```java
@Test
public void testInvalidInput() {
    assertThrows(IllegalArgumentException.class, 
        () -> process(-1));  // Negative not allowed
}
```

### 4. One Assert Per Test (Preferred)

```java
@Test
public void testAddPositive() {
    assertEquals(5, add(2, 3));
}

@Test
public void testAddNegative() {
    assertEquals(-5, add(-2, -3));
}
```

Better than combining into one test.

### 5. Use Descriptive Test Names

```java
// ✗ BAD
@Test
public void test1() { }

// ✓ GOOD
@Test
public void shouldReturnTrueWhenInputIsValid() { }
```

## Troubleshooting

### Coverage Not 100%

1. **Run report**: `mvn clean test jacoco:report`
2. **Open**: `target/site/jacoco/index.html`
3. **Find red lines** - untested code
4. **Write tests** for those lines
5. **Verify**: `mvn clean verify`

### Build Passes Locally, Fails in CI

- Different test execution order
- Missing test dependencies
- Environment-specific code paths

**Fix**: Make tests independent, don't rely on execution order.

### Can't Test Private Methods

**Options:**
1. Test via public methods (preferred)
2. Make package-private for testing
3. Consider if private method should be separate class

**Don't use reflection to test private methods** - it breaks encapsulation.

### Tests Too Slow

- Use `@Disabled` to skip slow integration tests during development
- Run full coverage in CI only
- Optimize slow tests (mock external dependencies)

## Summary

| Metric | Threshold | FlossWare Standard |
|--------|-----------|-------------------|
| Instruction | 100% | ✅ Required |
| Branch | 100% | ✅ Required |
| Line | 100% | ✅ Required |
| Class | 0 missed | ✅ Required |

**Goal**: Every line of code has at least one test that executes it.

**Command**: `mvn clean verify`

**Report**: `target/site/jacoco/index.html`

---

## References

- [JaCoCo Documentation](https://www.jacoco.org/jacoco/trunk/doc/)
- [JaCoCo Maven Plugin](https://www.jacoco.org/jacoco/trunk/doc/maven.html)
- [Effective Unit Testing](https://www.manning.com/books/effective-unit-testing)
