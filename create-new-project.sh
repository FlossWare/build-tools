#!/bin/bash
#
# Create a New FlossWare Project with Standards Pre-Configured
#
# Usage:
#   ./create-new-project.sh project-name "Project Description"
#
# Example:
#   ./create-new-project.sh jcache "FlossWare Caching Library"
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <project-name> <description>"
    echo
    echo "Example:"
    echo "  $0 jcache \"FlossWare Caching Library\""
    exit 1
fi

PROJECT_NAME="$1"
DESCRIPTION="$2"
PROJECT_DIR="$PARENT_DIR/$PROJECT_NAME"

echo "========================================"
echo "Create New FlossWare Project"
echo "========================================"
echo "Name: $PROJECT_NAME"
echo "Description: $DESCRIPTION"
echo "Location: $PROJECT_DIR"
echo

# Check if project already exists
if [[ -d "$PROJECT_DIR" ]]; then
    echo "Error: Directory already exists: $PROJECT_DIR"
    exit 1
fi

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$PROJECT_DIR/src/main/java/org/flossware/$PROJECT_NAME"
mkdir -p "$PROJECT_DIR/src/test/java/org/flossware/$PROJECT_NAME"
mkdir -p "$PROJECT_DIR/src/main/resources"
mkdir -p "$PROJECT_DIR/src/test/resources"

# Create pom.xml from template
echo "📄 Creating pom.xml..."
cat > "$PROJECT_DIR/pom.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.flossware</groupId>
    <artifactId>$PROJECT_NAME</artifactId>
    <version>1.0</version>
    <packaging>jar</packaging>

    <name>$PROJECT_NAME</name>
    <description>$DESCRIPTION</description>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
    </properties>

    <!-- PackageCloud.io Distribution -->
    <distributionManagement>
        <repository>
            <id>packagecloud-flossware</id>
            <url>packagecloud+https://packagecloud.io/flossware/releases</url>
        </repository>
        <snapshotRepository>
            <id>packagecloud-flossware</id>
            <url>packagecloud+https://packagecloud.io/flossware/snapshots</url>
        </snapshotRepository>
    </distributionManagement>

    <dependencies>
        <!-- Testing Dependencies -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.2</version>
            <scope>test</scope>
        </dependency>

        <!-- Use mockito-inline instead of mockito-core to avoid JDK agent warnings -->
        <dependency>
            <groupId>org.mockito</groupId>
            <artifactId>mockito-inline</artifactId>
            <version>5.2.0</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <!-- Checkstyle: Code Style Enforcement -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-checkstyle-plugin</artifactId>
                <version>3.3.1</version>
                <dependencies>
                    <dependency>
                        <groupId>org.flossware</groupId>
                        <artifactId>flossware-build-tools</artifactId>
                        <version>1.3</version>
                    </dependency>
                    <dependency>
                        <groupId>com.puppycrawl.tools</groupId>
                        <artifactId>checkstyle</artifactId>
                        <version>10.12.5</version>
                    </dependency>
                </dependencies>
                <configuration>
                    <configLocation>flossware-checkstyle.xml</configLocation>
                    <consoleOutput>true</consoleOutput>
                    <failsOnError>true</failsOnError>
                    <violationSeverity>warning</violationSeverity>
                </configuration>
                <executions>
                    <execution>
                        <phase>validate</phase>
                        <goals>
                            <goal>check</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>

            <!-- PMD: Code Quality Analysis -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-pmd-plugin</artifactId>
                <version>3.21.2</version>
                <dependencies>
                    <dependency>
                        <groupId>org.flossware</groupId>
                        <artifactId>flossware-build-tools</artifactId>
                        <version>1.3</version>
                    </dependency>
                </dependencies>
                <configuration>
                    <rulesets>
                        <ruleset>flossware-pmd-ruleset.xml</ruleset>
                    </rulesets>
                    <printFailingErrors>true</printFailingErrors>
                    <failOnViolation>true</failOnViolation>
                </configuration>
                <executions>
                    <execution>
                        <phase>validate</phase>
                        <goals>
                            <goal>check</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>

            <!-- SpotBugs: Bug Detection -->
            <plugin>
                <groupId>com.github.spotbugs</groupId>
                <artifactId>spotbugs-maven-plugin</artifactId>
                <version>4.8.2.0</version>
                <dependencies>
                    <dependency>
                        <groupId>org.flossware</groupId>
                        <artifactId>flossware-build-tools</artifactId>
                        <version>1.3</version>
                    </dependency>
                </dependencies>
                <configuration>
                    <excludeFilterFile>flossware-spotbugs-exclude.xml</excludeFilterFile>
                    <effort>Max</effort>
                    <threshold>Low</threshold>
                    <failOnError>true</failOnError>
                </configuration>
                <executions>
                    <execution>
                        <phase>verify</phase>
                        <goals>
                            <goal>check</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>

            <!-- Enforce X.Y version format -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-enforcer-plugin</artifactId>
                <version>3.4.1</version>
                <executions>
                    <execution>
                        <id>enforce-version-format</id>
                        <goals>
                            <goal>enforce</goal>
                        </goals>
                        <configuration>
                            <rules>
                                <requireProperty>
                                    <property>project.version</property>
                                    <regex>^\d+\.\d+$</regex>
                                    <regexMessage>Version must be in X.Y format (e.g., 1.0, 2.5), not X.Y.Z</regexMessage>
                                </requireProperty>
                            </rules>
                        </configuration>
                    </execution>
                </executions>
            </plugin>

            <!-- JaCoCo: 100% Test Coverage Enforcement -->
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.11</version>
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
                                        <limit>
                                            <counter>INSTRUCTION</counter>
                                            <value>COVEREDRATIO</value>
                                            <minimum>1.00</minimum>
                                        </limit>
                                        <limit>
                                            <counter>BRANCH</counter>
                                            <value>COVEREDRATIO</value>
                                            <minimum>1.00</minimum>
                                        </limit>
                                        <limit>
                                            <counter>LINE</counter>
                                            <value>COVEREDRATIO</value>
                                            <minimum>1.00</minimum>
                                        </limit>
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
        </plugins>

        <!-- PackageCloud.io wagon extension -->
        <extensions>
            <extension>
                <groupId>io.packagecloud.maven.wagon</groupId>
                <artifactId>maven-packagecloud-wagon</artifactId>
                <version>0.0.6</version>
            </extension>
        </extensions>
    </build>
</project>
EOF

# Copy .editorconfig
echo "📝 Copying .editorconfig..."
cp "$SCRIPT_DIR/.editorconfig" "$PROJECT_DIR/.editorconfig"

# Create README.md
echo "📄 Creating README.md..."
cat > "$PROJECT_DIR/README.md" <<EOF
# $PROJECT_NAME

$DESCRIPTION

## Building

\`\`\`bash
mvn clean verify
\`\`\`

## Installing

\`\`\`bash
mvn clean install
\`\`\`

## Standards

This project follows [FlossWare Build Standards](../flossware-build-tools/):
- ✅ X.Y versioning
- ✅ No wildcard imports
- ✅ Final parameters
- ✅ Method chaining preferred
- ✅ 100% test coverage
- ✅ Code quality checks (Checkstyle, PMD, SpotBugs)

## Publishing

\`\`\`bash
mvn deploy
\`\`\`

See [PACKAGECLOUD-SETUP.md](../flossware-build-tools/PACKAGECLOUD-SETUP.md) for PackageCloud configuration.
EOF

# Create .gitignore
echo "🚫 Creating .gitignore..."
cat > "$PROJECT_DIR/.gitignore" <<EOF
target/
*.class
*.jar
*.war
*.ear
*.iml
.idea/
.vscode/
.settings/
.classpath
.project
*.log
EOF

# Create sample source file
echo "☕ Creating sample source file..."
cat > "$PROJECT_DIR/src/main/java/org/flossware/$PROJECT_NAME/Example.java" <<EOF
package org.flossware.$PROJECT_NAME;

/**
 * Example class for $PROJECT_NAME.
 */
public class Example {

    /**
     * Example method demonstrating method chaining.
     *
     * @param input the input string
     * @return normalized string
     */
    public String normalize(final String input) {
        return input.trim()
                    .toLowerCase()
                    .replaceAll("\\\\s+", " ");
    }
}
EOF

# Create sample test file
echo "🧪 Creating sample test file..."
cat > "$PROJECT_DIR/src/test/java/org/flossware/$PROJECT_NAME/ExampleTest.java" <<EOF
package org.flossware.$PROJECT_NAME;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test class for Example.
 */
public class ExampleTest {

    private Example example;

    @BeforeEach
    public void setUp() {
        example = new Example();
    }

    @Test
    public void testNormalize() {
        assertEquals("hello world", example.normalize("  HELLO   WORLD  "));
    }

    @Test
    public void testNormalizeAlreadyNormalized() {
        assertEquals("hello world", example.normalize("hello world"));
    }

    @Test
    public void testNormalizeEmpty() {
        assertEquals("", example.normalize(""));
    }
}
EOF

# Initialize git
cd "$PROJECT_DIR"
echo "📦 Initializing git repository..."
git init
git add .
git commit -m "Initial commit: $PROJECT_NAME

- FlossWare standards v1.3 pre-configured
- 100% test coverage enforced
- Example class with tests
- PackageCloud.io ready"

echo
echo "========================================"
echo "✅ Project Created Successfully!"
echo "========================================"
echo
echo "Location: $PROJECT_DIR"
echo
echo "Next steps:"
echo "  1. cd $PROJECT_DIR"
echo "  2. mvn clean verify     # Should pass with 100% coverage"
echo "  3. Start coding!"
echo
echo "Standards pre-configured:"
echo "  ✓ Checkstyle (no wildcard imports, final parameters)"
echo "  ✓ PMD (method chaining preference)"
echo "  ✓ SpotBugs (bug detection)"
echo "  ✓ JaCoCo (100% coverage)"
echo "  ✓ X.Y versioning"
echo "  ✓ PackageCloud.io ready"
echo
echo "Documentation:"
echo "  - See: ../flossware-build-tools/README.md"
echo "  - Method chaining: ../flossware-build-tools/METHOD-CHAINING.md"
echo "  - Test coverage: ../flossware-build-tools/TEST-COVERAGE.md"
