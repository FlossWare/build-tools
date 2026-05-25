# PackageCloud.io Setup for FlossWare Projects

This guide explains how to configure Maven to publish FlossWare projects to PackageCloud.io.

## Prerequisites

1. A PackageCloud.io account
2. Repository created at `packagecloud.io/flossware/releases` (or your chosen name)
3. Your PackageCloud API token

## Step 1: Get Your API Token

1. Log in to [packagecloud.io](https://packagecloud.io)
2. Go to **Account Settings** → **API Tokens**
3. Copy your API token

## Step 2: Configure Maven Credentials

Add your PackageCloud credentials to `~/.m2/settings.xml`:

```xml
<settings>
    <servers>
        <server>
            <id>packagecloud-flossware</id>
            <password>YOUR_PACKAGECLOUD_API_TOKEN_HERE</password>
        </server>
    </servers>
</settings>
```

**Important**: 
- The `<id>` must match the repository ID in your project's `pom.xml`
- Use `<password>` field for the API token (not `<username>`)
- Keep your token secure - never commit it to version control

## Step 3: Verify Project Configuration

Your project's `pom.xml` should have:

```xml
<distributionManagement>
    <repository>
        <id>packagecloud-flossware</id>
        <url>packagecloud+https://packagecloud.io/flossware/releases</url>
    </repository>
</distributionManagement>

<build>
    <extensions>
        <extension>
            <groupId>io.packagecloud.maven.wagon</groupId>
            <artifactId>maven-packagecloud-wagon</artifactId>
            <version>0.0.6</version>
        </extension>
    </extensions>
</build>
```

## Step 4: Publishing

### Deploy a Release

```bash
# Ensure your version is X.Y format (not X.Y.Z or SNAPSHOT)
mvn clean deploy
```

### Deploy a Snapshot

```bash
# Add -SNAPSHOT to your version
# Edit pom.xml: <version>1.0-SNAPSHOT</version>
mvn clean deploy
```

The artifact will be uploaded to:
- Releases: `https://packagecloud.io/flossware/releases`
- Snapshots: `https://packagecloud.io/flossware/snapshots`

## Troubleshooting

### Error: "401 Unauthorized"
- Check your API token in `~/.m2/settings.xml`
- Verify the `<id>` matches between settings.xml and pom.xml

### Error: "Repository not found"
- Verify the repository exists at packagecloud.io
- Check the URL in `<distributionManagement>`
- Ensure you have write access to the repository

### Error: "wagon not found"
- Ensure the `maven-packagecloud-wagon` extension is in your `pom.xml`
- Try `mvn clean install` first

## Alternative: Environment Variable

Instead of storing the token in `settings.xml`, you can use an environment variable:

```xml
<settings>
    <servers>
        <server>
            <id>packagecloud-flossware</id>
            <password>${env.PACKAGECLOUD_TOKEN}</password>
        </server>
    </servers>
</settings>
```

Then export it before deploying:

```bash
export PACKAGECLOUD_TOKEN="your-token-here"
mvn clean deploy
```

## CI/CD Integration

For GitHub Actions, GitLab CI, etc., add your token as a secret:

### GitHub Actions Example

```yaml
name: Deploy to PackageCloud
on:
  release:
    types: [created]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Deploy to PackageCloud
        env:
          PACKAGECLOUD_TOKEN: ${{ secrets.PACKAGECLOUD_TOKEN }}
        run: |
          mkdir -p ~/.m2
          echo '<settings><servers><server><id>packagecloud-flossware</id><password>${env.PACKAGECLOUD_TOKEN}</password></server></servers></settings>' > ~/.m2/settings.xml
          mvn clean deploy
```

Add `PACKAGECLOUD_TOKEN` as a repository secret in GitHub.
