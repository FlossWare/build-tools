# FlossWare Project Coverage Recommendations

This document provides specific test coverage recommendations for each FlossWare project based on project type and complexity.

## Quick Reference

| Coverage Level | Projects | Rationale |
|----------------|----------|-----------|
| **Strict 100%** | jcommons, jcollections, jencrypt, jsecurity, jclassloader, jremote, jthreadpool, jresource-monitor, jeventbus, jfs-watcher | Core libraries, critical business logic, reusable components |
| **Pragmatic 100%** | jnexus, jcurses, jcloudstorage, jcontainer, jfiletransfer, jmessaging, jvcs | CLI apps, abstraction libraries with entry points |
| **90-95%** | jplatform, build-tools, netbeans-plugins | Frameworks, build tools, IDE plugins |

---

## Core Libraries - Strict 100% (No Exclusions)

### jcommons
**Type:** Core utilities library  
**Coverage:** **Strict 100%** - No exclusions  
**Rationale:** Shared utilities used across all projects. Every line must be tested.

**Command:**
```bash
./rollout-standards.sh --project ../jcommons
```

**Why no exclusions:**
- Foundational library used everywhere
- High risk if bugs slip through
- No main methods or entry points
- Pure utility functions that can all be tested

---

### jcollections
**Type:** Data structures and collections  
**Coverage:** **Strict 100%** - No exclusions  
**Rationale:** Algorithms and data structures must be thoroughly tested.

**Command:**
```bash
./rollout-standards.sh --project ../jcollections
```

**Note:** Has one main file - if it's an example/demo, exclude it. If it's a CLI tool, use pragmatic coverage.

---

### jencrypt
**Type:** AES-256-GCM encryption library  
**Coverage:** **Strict 100%** - No exclusions  
**Rationale:** Security-critical code. NEVER exclude anything.

**Command:**
```bash
./rollout-standards.sh --project ../jencrypt
```

**Why strict:**
- Security is paramount
- Encryption bugs can be catastrophic
- Only 2 source files - easy to achieve 100%
- Every edge case must be tested

---

### jsecurity
**Type:** Security library  
**Coverage:** **Strict 100%** - No exclusions  
**Rationale:** Security-critical code.

**Command:**
```bash
./rollout-standards.sh --project ../jsecurity
```

---

### jclassloader
**Type:** ClassLoader with HTTP support  
**Coverage:** **Strict 100%** - No exclusions  
**Rationale:** ClassLoading is security-sensitive and complex.

**Command:**
```bash
./rollout-standards.sh --project ../jclassloader
```

**Why strict:**
- ClassLoader security implications
- 44 source files - substantial codebase
- Complex caching logic needs thorough testing

---

### jremote
**Type:** Remote invocation via Virtual Threads  
**Coverage:** **Strict 100%** - No exclusions  
**Rationale:** Distributed systems require comprehensive testing.

**Command:**
```bash
./rollout-standards.sh --project ../jremote
```

---

### jthreadpool
**Type:** Managed thread pools  
**Coverage:** **Strict 100%** - No exclusions  
**Rationale:** Concurrency bugs are hard to find and fix.

**Command:**
```bash
./rollout-standards.sh --project ../jthreadpool
```

**Why strict:**
- Concurrency is complex
- Thread safety must be verified
- Only 3 source files - achievable

---

### jresource-monitor
**Type:** Resource tracking and quota enforcement  
**Coverage:** **Strict 100%** - No exclusions  
**Rationale:** Resource management is critical for stability.

**Command:**
```bash
./rollout-standards.sh --project ../jresource-monitor
```

---

### jeventbus
**Type:** Event bus and service registry  
**Coverage:** **Strict 100%** - No exclusions  
**Rationale:** Inter-application communication requires reliability.

**Command:**
```bash
./rollout-standards.sh --project ../jeventbus
```

---

### jfs-watcher
**Type:** Filesystem watcher with debouncing  
**Coverage:** **Strict 100%** - No exclusions  
**Rationale:** File system operations need comprehensive testing.

**Command:**
```bash
./rollout-standards.sh --project ../jfs-watcher
```

---

## CLI Applications - Pragmatic 100%

### jnexus
**Type:** Command-line tool for Nexus  
**Coverage:** **Pragmatic 100%** - Exclude main/CLI classes  
**Rationale:** Has CLI entry points but core logic needs testing.

**Command:**
```bash
./rollout-standards.sh --project ../jnexus --pragmatic-coverage
```

**What gets excluded:**
- `JNexus.class` - Main CLI entry point
- `JNexusSwing.class`, `JNexusAWT.class`, `JNexusUI.class` - UI entry points (if they have main methods)

**Must test:**
- `NexusService` - All business logic
- `NexusClient` - HTTP communication
- `SearchCriteria`, `RepositoryStats` - Data models with logic
- All filtering, caching, pagination logic

**Manual exclusion needed:**
```xml
<excludes>
    <!-- CLI entry points - delegate to Picocli -->
    <exclude>**/JNexus.class</exclude>
    <exclude>**/JNexusSwing.class</exclude>
    <exclude>**/JNexusAWT.class</exclude>
    <exclude>**/JNexusUI.class</exclude>
</excludes>
```

---

### jcurses
**Type:** Terminal UI library  
**Coverage:** **Pragmatic 100%** - Exclude example/demo mains  
**Rationale:** Library with examples that demonstrate usage.

**Command:**
```bash
./rollout-standards.sh --project ../jcurses --pragmatic-coverage
```

**What to exclude:** Only demo/example main methods that show usage.  
**Must test:** All jcurses library code.

---

## Abstraction Libraries - Pragmatic 100%

### jcloudstorage
**Type:** Cloud storage abstraction (S3, Azure, GCS, etc.)  
**Coverage:** **Pragmatic 100%** - Exclude pure DTOs  
**Rationale:** Abstraction layer with DTOs for cloud responses.

**Command:**
```bash
./rollout-standards.sh --project ../jcloudstorage --pragmatic-coverage
```

**What gets excluded:**
- Pure DTOs with only getters/setters
- Configuration POJOs with no logic

**Must test:**
- All abstraction interfaces
- Provider implementations
- Error handling and retries
- Authentication logic

---

### jcontainer
**Type:** Container/orchestration abstraction (Kubernetes, Docker)  
**Coverage:** **Pragmatic 100%**  
**Rationale:** Similar to jcloudstorage.

**Command:**
```bash
./rollout-standards.sh --project ../jcontainer --pragmatic-coverage
```

---

### jfiletransfer
**Type:** File transfer abstraction (SFTP, WebDAV, SMB, FTP)  
**Coverage:** **Pragmatic 100%**  
**Rationale:** Protocol abstraction with configuration classes.

**Command:**
```bash
./rollout-standards.sh --project ../jfiletransfer --pragmatic-coverage
```

---

### jmessaging
**Type:** Messaging abstraction (Kafka, RabbitMQ, Redis)  
**Coverage:** **Pragmatic 100%**  
**Rationale:** Abstraction with configuration POJOs.

**Command:**
```bash
./rollout-standards.sh --project ../jmessaging --pragmatic-coverage
```

---

### jvcs
**Type:** Version control abstraction (Git)  
**Coverage:** **Pragmatic 100%**  
**Rationale:** VCS abstraction layer.

**Command:**
```bash
./rollout-standards.sh --project ../jvcs --pragmatic-coverage
```

---

## Frameworks and Tools - 90-95%

### jplatform
**Type:** Platform for running multiple apps in single JVM  
**Coverage:** **90-95%** - Start with 90%  
**Rationale:** Complex framework with 2 main files and initialization logic.

**Command:**
```bash
./rollout-standards.sh --project ../jplatform --skip-coverage-enforcement
# Then manually set to 0.90 in pom.xml
```

**Why lower:**
- Framework initialization code hard to test
- Multiple application entry points
- Platform-specific bootstrap logic
- Focus on API contracts and core functionality

**Gradually increase:** 90% → 95% → 100% as tests mature

---

### build-tools
**Type:** Build configuration tools  
**Coverage:** **90-95%**  
**Rationale:** Configuration files and documentation, no Java source.

**Note:** Currently has no Java source code (only XML configs). If Java source is added:
- Test any programmatic configuration builders
- Test validation logic
- Exclude example/template code

---

### netbeans-plugins
**Type:** NetBeans IDE plugins  
**Coverage:** **80-90%** initially  
**Rationale:** IDE plugins have UI components and IDE integration that's hard to test.

**Command:**
```bash
./rollout-standards.sh --project ../netbeans-plugins --skip-coverage-enforcement
# Set to 0.80 initially, increase to 0.90
```

**Why lower:**
- UI components difficult to unit test
- IDE integration requires NetBeans runtime
- Focus on business logic and plugin APIs
- Use integration tests for UI workflows

---

## Summary Matrix

| Project | Source Files | Coverage | Command |
|---------|--------------|----------|---------|
| jcommons | 19 | Strict 100% | `--project ../jcommons` |
| jcollections | 14 | Strict 100% | `--project ../jcollections` |
| jencrypt | 2 | Strict 100% | `--project ../jencrypt` |
| jsecurity | 3 | Strict 100% | `--project ../jsecurity` |
| jclassloader | 44 | Strict 100% | `--project ../jclassloader` |
| jremote | 17 | Strict 100% | `--project ../jremote` |
| jthreadpool | 3 | Strict 100% | `--project ../jthreadpool` |
| jresource-monitor | 3 | Strict 100% | `--project ../jresource-monitor` |
| jeventbus | 7 | Strict 100% | `--project ../jeventbus` |
| jfs-watcher | 4 | Strict 100% | `--project ../jfs-watcher` |
| jnexus | 7 | Pragmatic 100% | `--project ../jnexus --pragmatic-coverage` |
| jcurses | 59 | Pragmatic 100% | `--project ../jcurses --pragmatic-coverage` |
| jcloudstorage | 7 | Pragmatic 100% | `--project ../jcloudstorage --pragmatic-coverage` |
| jcontainer | 4 | Pragmatic 100% | `--project ../jcontainer --pragmatic-coverage` |
| jfiletransfer | 5 | Pragmatic 100% | `--project ../jfiletransfer --pragmatic-coverage` |
| jmessaging | 4 | Pragmatic 100% | `--project ../jmessaging --pragmatic-coverage` |
| jvcs | 2 | Pragmatic 100% | `--project ../jvcs --pragmatic-coverage` |
| jplatform | 0 (TBD) | 90-95% | `--project ../jplatform --skip-coverage-enforcement` |
| build-tools | 0 | N/A | Config files only |
| netbeans-plugins | 0 (TBD) | 80-90% | `--project ../netbeans-plugins --skip-coverage-enforcement` |

---

## General Guidelines

### When to Use Strict 100%
- ✅ Core libraries and utilities
- ✅ Security-critical code
- ✅ Data structures and algorithms
- ✅ No main methods or entry points
- ✅ Small to medium codebases (<50 files)

### When to Use Pragmatic 100%
- ✅ CLI applications with main methods
- ✅ Libraries with example code
- ✅ Abstraction layers with DTOs
- ✅ Projects with utility class constructors

### When to Use 80-95%
- ✅ Complex frameworks and platforms
- ✅ IDE plugins and UI-heavy code
- ✅ Legacy codebases (gradually increase)
- ✅ Integration-heavy projects

### Red Flags - Always Test
- ❌ Never exclude business logic
- ❌ Never exclude validation code
- ❌ Never exclude error handling
- ❌ Never exclude security code
- ❌ Never exclude public APIs

---

## Migration Path

For existing projects without coverage:

1. **Baseline:** Run tests and check current coverage
   ```bash
   cd <project>
   mvn clean test jacoco:report
   open target/site/jacoco/index.html
   ```

2. **Choose approach:**
   - If 0-50%: Start with `--skip-coverage-enforcement` (80%)
   - If 50-80%: Use `--pragmatic-coverage` and add tests
   - If 80-95%: Use strict 100% and complete testing

3. **Apply standards:**
   ```bash
   cd build-tools
   ./rollout-standards.sh --project ../yourproject --pragmatic-coverage
   ```

4. **Iterate:**
   - Write tests for uncovered code
   - Review exclusions (are they justified?)
   - Gradually increase threshold
   - Aim for pragmatic 100% minimum

---

## Questions?

- See [TEST-COVERAGE.md](TEST-COVERAGE.md) for detailed testing guides
- See [ROLLOUT-GUIDE.md](ROLLOUT-GUIDE.md) for step-by-step instructions
- See `jacoco-pragmatic-snippet.xml` for exclusion examples
- Run `./rollout-standards.sh --help` for usage

**Remember:** Coverage is a tool, not a goal. The goal is reliable, well-tested software.
