# Universal Build Tools Proposal

## Vision

Transform `build-tools` into a **universal FlossWare build standards repository** supporting all project types across the FlossWare organization.

## Current State

- **Name**: `build-tools` (Java Build Tools)
- **Scope**: Maven/Java projects only
- **Tools**: Checkstyle, PMD, SpotBugs, JaCoCo, EditorConfig

## Proposed Evolution

### Option 1: Rename to `build-standards` ⭐ RECOMMENDED

```
FlossWare/build-standards/
├── java/                          # Java/Maven standards
│   ├── checkstyle/
│   ├── pmd/
│   ├── spotbugs/
│   ├── templates/
│   ├── scripts/
│   └── README.md
├── shell/                         # Shell/Bash standards
│   ├── shellcheck/
│   ├── templates/
│   ├── scripts/
│   └── README.md
├── c-cpp/                         # C/C++ standards (for VirtOS)
│   ├── clang-format/
│   ├── clang-tidy/
│   ├── templates/
│   ├── scripts/
│   └── README.md
├── python/                        # Python standards (future)
│   ├── pylint/
│   ├── black/
│   ├── templates/
│   └── README.md
├── go/                            # Go standards (for gofl)
│   ├── golangci-lint/
│   ├── templates/
│   └── README.md
├── common/                        # Universal configs
│   ├── .editorconfig
│   ├── .gitignore templates
│   ├── CODE_OF_CONDUCT.md
│   ├── LICENSE templates
│   └── README.md
├── scripts/                       # Cross-language tools
│   ├── apply-standards.sh         # Universal rollout
│   ├── verify-all-projects.sh     # Universal verification
│   └── create-new-project.sh      # Multi-language project creation
└── README.md                      # Universal guide
```

### Option 2: Keep `build-tools` + Create Language-Specific Repos

```
FlossWare/build-tools/           # Java only
FlossWare/shell-build-tools/      # Shell/Bash
FlossWare/c-build-tools/          # C/C++
FlossWare/build-standards/        # Universal orchestrator
```

**Pros**: Clear separation
**Cons**: Harder to maintain, duplicate scripts

---

## Proposed Language Support

### 1. Java/Maven (Current) ✅

**Status**: Fully implemented

**Tools**:
- Checkstyle (style)
- PMD (quality)
- SpotBugs (bugs)
- JaCoCo (coverage)
- Maven Enforcer (standards)
- OWASP Dependency Check (security)

**Projects**: jcommons, jcollections, jcurses, jdiskwipe, jencrypt, etc.

---

### 2. Shell/Bash (NEW - for VirtOS)

**Tools to Add**:
- **ShellCheck** - Shell script static analysis
- **shfmt** - Shell script formatter
- **BATS** - Bash Automated Testing System

**Configuration Files**:
```bash
shell/
├── shellcheck.rc              # ShellCheck configuration
├── shfmt.config              # Formatting rules
├── templates/
│   └── script-template.sh    # Standard shell script template
└── scripts/
    ├── apply-shell-standards.sh
    └── verify-shell-quality.sh
```

**Example `.shellcheckrc`**:
```bash
# ShellCheck configuration for FlossWare projects
disable=SC2034  # Unused variables (sometimes needed for exports)
enable=all
shell=bash
external-sources=true
```

**Projects**: VirtOS, VirtOS-Examples

---

### 3. C/C++ (NEW - for VirtOS native code)

**Tools to Add**:
- **clang-format** - Code formatting
- **clang-tidy** - Static analysis
- **cppcheck** - Additional static analysis
- **gcov/lcov** - Code coverage

**Configuration Files**:
```
c-cpp/
├── .clang-format             # Code style
├── .clang-tidy               # Linting rules
├── cppcheck.xml              # Static analysis config
└── templates/
    ├── CMakeLists.txt        # CMake template
    └── Makefile.template     # Make template
```

**Projects**: VirtOS (if it has C/C++ components)

---

### 4. Go (NEW - for gofl)

**Tools to Add**:
- **golangci-lint** - Comprehensive Go linter
- **gofmt** - Go formatter
- **go vet** - Go static analysis
- **go test -cover** - Coverage

**Configuration Files**:
```
go/
├── .golangci.yml             # golangci-lint config
└── templates/
    └── go.mod.template
```

**Projects**: gofl

---

### 5. Python (FUTURE)

**Tools to Add**:
- **pylint** - Static analysis
- **black** - Code formatter
- **mypy** - Type checking
- **pytest** - Testing framework
- **coverage.py** - Code coverage

**Configuration Files**:
```
python/
├── .pylintrc                 # Pylint config
├── pyproject.toml            # Black/isort/pytest config
└── templates/
    ├── setup.py.template
    └── pyproject.toml.template
```

---

## Universal Scripts

### 1. `apply-standards.sh` - Language-Aware Rollout

```bash
#!/bin/bash
# Universal standards application

./apply-standards.sh --all                    # Auto-detect and apply
./apply-standards.sh --language java --all    # Java only
./apply-standards.sh --language shell --all   # Shell only
./apply-standards.sh --project ../VirtOS      # Auto-detect project type
```

Auto-detection logic:
- `pom.xml` → Java
- `Makefile` + `*.sh` → Shell
- `CMakeLists.txt` → C/C++
- `go.mod` → Go
- `setup.py` → Python

### 2. `verify-all-projects.sh` - Universal Verification

```bash
#!/bin/bash
# Verify all FlossWare projects

./verify-all-projects.sh --all
./verify-all-projects.sh --language java
./verify-all-projects.sh --report compliance-report.md
```

### 3. `create-new-project.sh` - Multi-Language Project Creation

```bash
#!/bin/bash
# Create new project with standards pre-applied

./create-new-project.sh --language java --name jnewlib
./create-new-project.sh --language shell --name scripts-toolkit
./create-new-project.sh --language go --name gonew
```

---

## Implementation Plan

### Phase 1: Restructure Current Repo ✅

1. ✅ Rename `build-tools` → `build-standards`
2. ✅ Move current Java configs to `java/` subdirectory
3. ✅ Create `common/` directory for universal files
4. ✅ Update all scripts to work with new structure
5. ✅ Update documentation

### Phase 2: Add Shell/Bash Support (for VirtOS)

1. Create `shell/` directory structure
2. Add ShellCheck configuration
3. Add shfmt configuration
4. Create shell script templates
5. Create `apply-shell-standards.sh`
6. Test on VirtOS project

### Phase 3: Add C/C++ Support (if needed for VirtOS)

1. Create `c-cpp/` directory structure
2. Add clang-format/clang-tidy configs
3. Create C/C++ templates
4. Create `apply-cpp-standards.sh`

### Phase 4: Add Go Support (for gofl)

1. Create `go/` directory structure
2. Add golangci-lint configuration
3. Create Go templates
4. Create `apply-go-standards.sh`

### Phase 5: Universal Scripts

1. Create language auto-detection
2. Update `apply-standards.sh` for multi-language
3. Update `verify-all-projects.sh` for multi-language
4. Update `create-new-project.sh` for multi-language

---

## Breaking Changes

### For Existing Java Projects

**Current**:
```xml
<dependency>
    <groupId>org.flossware</groupId>
    <artifactId>build-tools</artifactId>
    <version>1.3</version>
</dependency>
```

**Option A - Keep Artifact Name** (Recommended):
```xml
<!-- No changes needed - keep build-tools artifact name -->
<dependency>
    <groupId>org.flossware</groupId>
    <artifactId>build-tools</artifactId>
    <version>2.0</version>
</dependency>
```

**Option B - Rename Artifact**:
```xml
<!-- Requires updating all POMs -->
<dependency>
    <groupId>org.flossware</groupId>
    <artifactId>build-standards-java</artifactId>
    <version>2.0</version>
</dependency>
```

### Recommendation

**Keep Maven artifact as `build-tools`**, but rename the repository to `build-standards`:
- Repository: `FlossWare/build-standards`
- Java Maven artifact: `org.flossware:build-tools:2.0`
- No breaking changes for existing projects
- Repository name better reflects expanded scope

---

## Benefits

1. **Centralized Standards** - One place for all FlossWare quality standards
2. **Consistency** - Same quality bar across all languages
3. **Reusability** - Common configs (EditorConfig, CODE_OF_CONDUCT, etc.)
4. **Discoverability** - New contributors know where to find standards
5. **Automation** - Universal scripts work across all project types

---

## Questions to Answer

1. **Repository Name**:
   - Rename to `build-standards`? ⭐
   - Keep as `build-tools`?
   - New name: `quality-standards`?

2. **Maven Artifact**:
   - Keep as `build-tools`? ⭐ (No breaking changes)
   - Rename to `build-standards-java`?

3. **Priority Languages**:
   - Shell/Bash for VirtOS? ⭐ (Immediate need)
   - Go for gofl? ⭐ (Immediate need)
   - C/C++ for VirtOS native code?
   - Python for future projects?

4. **Structure**:
   - Single repo with subdirectories? ⭐ (Recommended)
   - Multiple language-specific repos?

---

## Next Steps

1. **Decide on naming** (repository vs artifact)
2. **Prioritize languages** (Shell + Go first?)
3. **Create restructure plan**
4. **Update documentation**
5. **Add Shell/Bash support for VirtOS**
6. **Add Go support for gofl**

---

## Example: Shell Standards for VirtOS

### `.shellcheckrc`
```bash
# FlossWare Shell Standards
disable=SC2034  # Unused variables
enable=all
shell=bash
external-sources=true
severity=style
```

### `shfmt.config`
```bash
# Format with:
#   shfmt -i 4 -bn -ci -sr -w script.sh

# -i 4    : 4 spaces indentation
# -bn     : Binary ops start line
# -ci     : Switch case indentation
# -sr     : Redirect operators space
# -w      : Write changes
```

### `apply-shell-standards.sh`
```bash
#!/bin/bash
# Apply shell standards to VirtOS

find . -name "*.sh" -exec shellcheck {} \;
find . -name "*.sh" -exec shfmt -i 4 -w {} \;
```

Would you like me to:
1. Start the restructure now?
2. Create Shell/Bash support for VirtOS first?
3. Create a migration plan document?
