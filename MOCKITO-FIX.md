# Fix Mockito JDK Agent Warning

## The Problem

You're seeing this warning when running tests:

```
This will no longer work in future releases of the JDK. 
Please add Mockito as an agent to your build as described in 
Mockito's documentation: https://javadoc.io/doc/org.mockito/mockito-core/latest/org.mockito/org/mockito/Mockito.html#0.3
```

This happens because:
- Mockito needs special permissions to mock classes (using ByteBuddy)
- Modern JDK versions restrict this unless Mockito runs as a Java agent
- `mockito-core` requires manual agent configuration

## ✅ Solution: Switch to mockito-inline (RECOMMENDED)

### Step 1: Update Your POM

Replace `mockito-core` with `mockito-inline`:

**Before:**
```xml
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-core</artifactId>
    <version>5.11.0</version>
    <scope>test</scope>
</dependency>
```

**After:**
```xml
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-inline</artifactId>
    <version>5.2.0</version>
    <scope>test</scope>
</dependency>
```

### Step 2: Clean and Test

```bash
mvn clean test
```

**That's it!** The warning should be gone.

---

## Alternative: Configure the Agent (If You Must Use mockito-core)

If you need to stick with `mockito-core`, configure Surefire to use Mockito as an agent:

### Add to `<properties>`:

```xml
<properties>
    <mockito.version>5.11.0</mockito.version>
</properties>
```

### Add Surefire Configuration:

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-surefire-plugin</artifactId>
            <version>3.2.5</version>
            <configuration>
                <argLine>
                    -javaagent:${settings.localRepository}/org/mockito/mockito-core/${mockito.version}/mockito-core-${mockito.version}.jar
                </argLine>
            </configuration>
        </plugin>
    </plugins>
</build>
```

---

## Why mockito-inline?

| Feature | mockito-core | mockito-inline |
|---------|--------------|----------------|
| Agent Setup | Manual | Automatic |
| Mocking Final Classes | Requires agent | Built-in |
| Mocking Static Methods | Requires agent | Built-in |
| JDK Compatibility | Needs config | Just works |
| Performance | Slightly faster | Negligible difference |

**Recommendation:** Use `mockito-inline` unless you have a specific reason not to.

---

## Bulk Fix Across All Projects

To fix this across all FlossWare projects:

### 1. Create a script

```bash
#!/bin/bash
# fix-mockito.sh

for pom in $(find . -name pom.xml); do
    if grep -q "mockito-core" "$pom"; then
        echo "Fixing $pom"
        sed -i 's/mockito-core/mockito-inline/g' "$pom"
    fi
done

echo "Done! Review changes with: git diff"
```

### 2. Run it

```bash
chmod +x fix-mockito.sh
./fix-mockito.sh
```

### 3. Test each project

```bash
for dir in */; do
    if [ -f "$dir/pom.xml" ]; then
        echo "Testing $dir"
        (cd "$dir" && mvn clean test) || echo "FAILED: $dir"
    fi
done
```

---

## Troubleshooting

### Warning Still Appears

1. **Check your dependency tree:**
   ```bash
   mvn dependency:tree | grep mockito
   ```
   
   Another dependency might be pulling in `mockito-core`. Exclude it:
   
   ```xml
   <dependency>
       <groupId>some.other.library</groupId>
       <artifactId>library-with-mockito</artifactId>
       <version>1.0</version>
       <exclusions>
           <exclusion>
               <groupId>org.mockito</groupId>
               <artifactId>mockito-core</artifactId>
           </exclusion>
       </exclusions>
   </dependency>
   ```

2. **Clear your local Maven cache:**
   ```bash
   rm -rf ~/.m2/repository/org/mockito/
   mvn clean test
   ```

### Tests Fail After Switching

If tests fail after switching to `mockito-inline`:

1. Update to the latest version:
   ```xml
   <version>5.2.0</version>
   ```

2. Check for incompatible Mockito usage (rare)

3. Verify Java version compatibility (Java 11+ recommended)

---

## For New Projects

When creating new FlossWare projects, use the template:

```bash
cp flossware-build-tools/flossware-project-template.xml yourproject/pom.xml
```

It includes `mockito-inline` by default.

---

## References

- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)
- [mockito-inline vs mockito-core](https://github.com/mockito/mockito/wiki/What%27s-new-in-Mockito-2#mock-the-unmockable-opt-in-mocking-of-final-classesmethods)
