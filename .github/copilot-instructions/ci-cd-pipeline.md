# CI/CD Pipeline Documentation

**Date**: 2026-02-05

## Overview

Automated Jenkins CI/CD pipeline for building, versioning, and releasing the Machine Maintenance Android app. The pipeline runs in a containerized Flutter environment using Docker and handles complete release workflow including version management, building, tagging, and GitHub releases.

## Pipeline Architecture

### Infrastructure
- **Jenkins Node**: `docker` (requires Docker plugin)
- **Docker Image**: `cirrusci/flutter:stable` (official Flutter Docker image)
- **Execution**: All build steps run inside Docker container
- **Trigger**: Manual (parameterized build)

### Docker Strategy

The pipeline uses `docker.image('cirrusci/flutter:stable').inside()` to:
- Eliminate need to install Flutter on Jenkins host
- Ensure consistent build environment across all builds
- Isolate dependencies and avoid conflicts
- Use official, pre-configured Flutter environment

## Build Parameters

### RELEASE_TYPE
**Type**: Choice parameter
**Options**:
- `patch` - Bug fixes, minor changes (1.0.0 → 1.0.1)
- `minor` - New features, backward compatible (1.0.0 → 1.1.0)
- `major` - Breaking changes (1.0.0 → 2.0.0)

Build number is automatically incremented on every build.

## Pipeline Stages

### 1. Checkout
```groovy
stage('Checkout')
```
- Clones repository from SCM
- Configures git user for commits
- Sets up workspace

### 2. Calculate New Version
```groovy
stage('Calculate New Version')
```
**Process**:
1. Parses current version from `pubspec.yaml`
2. Extracts: `major.minor.patch+build`
3. Increments version based on `RELEASE_TYPE` parameter
4. Increments build number
5. Sets environment variables:
   - `NEW_VERSION` (e.g., "1.1.0")
   - `NEW_BUILD_NUMBER` (e.g., "2")
   - `VERSION_TAG` (e.g., "v1.1.0")

**Versioning Logic**:
- **Patch**: Only patch number increments
- **Minor**: Minor increments, patch resets to 0
- **Major**: Major increments, minor and patch reset to 0
- **Build**: Always increments

**Example**:
```
Current: 1.2.3+5
Patch:   1.2.4+6
Minor:   1.3.0+6
Major:   2.0.0+6
```

### 3. Update Version
```groovy
stage('Update Version')
```
- Makes update script executable
- Runs `./scripts/update_version.sh ${NEW_VERSION} ${NEW_BUILD_NUMBER}`
- Updates both `pubspec.yaml` and `lib/utils/constants.dart`
- Verifies changes

### 4. Get Dependencies
```groovy
stage('Get Dependencies')
```
- Runs `flutter pub get`
- Downloads all package dependencies

### 5. Analyze Code
```groovy
stage('Analyze Code')
```
- Runs `flutter analyze`
- Static code analysis
- Checks for issues and violations

### 6. Run Tests
```groovy
stage('Run Tests')
```
- Runs `flutter test`
- Continues even if tests fail (non-blocking)
- Useful for projects without tests yet

### 7. Build Release APK
```groovy
stage('Build Release APK')
```
- Runs `flutter build apk --release`
- Generates optimized production APK
- Renames APK with version: `machine-maintenance-1.1.0-2.apk`
- APK location: `build/app/outputs/flutter-apk/`

### 8. Commit Version Changes
```groovy
stage('Commit Version Changes')
```
- Commits changes to:
  - `pubspec.yaml`
  - `lib/utils/constants.dart`
- Commit message: `chore: bump version to X.Y.Z+N`

### 9. Create Git Tag
```groovy
stage('Create Git Tag')
```
- Creates annotated git tag: `vX.Y.Z`
- Tag message: `Release X.Y.Z`

### 10. Push to GitHub
```groovy
stage('Push to GitHub')
```
- Pushes commit to `main` branch
- Pushes version tag
- Uses GitHub token (Secret text credential)
- Format: `https://${GITHUB_TOKEN}@github.com/repo.git`

### 11. Create GitHub Release
```groovy
stage('Create GitHub Release')
```
**Process**:
1. Creates GitHub release via REST API
2. Sets release name: `Release X.Y.Z`
3. Generates release notes with:
   - Version number
   - Build number
   - Release type
   - CI info
4. Uploads APK as release asset
5. Publishes release (not draft)

**Release URL**: `https://github.com/{GITHUB_REPO}/releases/tag/{VERSION_TAG}`

### 12. Archive Artifacts
```groovy
stage('Archive Artifacts')
```
- Archives APK in Jenkins
- Available for download from Jenkins UI
- Fingerprinting enabled for tracking

## Environment Variables

### Required Configuration

Update these in `Jenkinsfile`:

```groovy
environment {
    GITHUB_CREDENTIALS_ID = 'github-credentials'  // Jenkins credential ID
    GITHUB_REPO = 'rumd3x/machine-maintenance-android'  // GitHub repo
    APP_NAME = 'machine-maintenance'  // App name for APK
}
```

### Auto-Generated Variables

Set during pipeline execution:
- `NEW_VERSION` - New semantic version (e.g., "1.1.0")
- `NEW_BUILD_NUMBER` - New build number (e.g., "2")
- `VERSION_TAG` - Git tag name (e.g., "v1.1.0")

## Jenkins Setup Requirements

### 1. Docker Plugin
```
Jenkins → Manage Plugins → Available → Docker Pipeline
```

### 2. Docker Node Configuration
Label a Jenkins node as `docker`:
```
Jenkins → Manage Nodes → Configure Node → Labels: docker
```

Ensure Docker is installed and Jenkins user has access:
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### 3. GitHub Credentials

**GitHub Personal Access Token (Required)**

1. Generate token at: https://github.com/settings/tokens
2. Required scopes:
   - `repo` (full control)
   - `write:packages` (optional)
3. Add to Jenkins:
   ```
   Jenkins → Credentials → Add Credentials
   Kind: Secret text
   ID: github-credentials
   Secret: <your-token>
   Description: GitHub Token for Machine Maintenance Android
   ```

**Note**: The pipeline uses token-based authentication with the format `https://${GITHUB_TOKEN}@github.com/repo.git`

### 4. Pipeline Job Setup

Create new pipeline job:
```
Jenkins → New Item → Pipeline
Name: machine-maintenance-android-release
```

Configure:
- **Pipeline Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: Your GitHub repo
- **Branch**: `*/main`
- **Script Path**: `Jenkinsfile`
- **Enable**: "This project is parameterized" (parameters auto-detected from Jenkinsfile)

## Usage

### Manual Build

1. Go to Jenkins job
2. Click "Build with Parameters"
3. Select release type:
   - **patch** - For bug fixes
   - **minor** - For new features
   - **major** - For breaking changes
4. Click "Build"

### Build Output

**Success**:
```
✅ Build completed successfully!
Version: 1.1.0+2
Tag: v1.1.0
GitHub Release: https://github.com/rumd3x/machine-maintenance-android/releases/tag/v1.1.0
```

**Artifacts**:
- APK available in Jenkins
- APK available in GitHub release
- Git tag pushed to repository
- Version files updated in repository

## Troubleshooting

### Docker Permission Denied

**Problem**: Jenkins can't access Docker socket

**Solution**:
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### GitHub Push Failed

**Problem**: Authentication failed

**Solutions**:
- Verify credential ID matches `GITHUB_CREDENTIALS_ID`
- Check token has `repo` scope
- Ensure token hasn't expired
- Test token manually: `git push https://<token>@github.com/<repo>.git`

### Version Parse Failed

**Problem**: Can't extract version from pubspec.yaml

**Solution**:
- Verify `pubspec.yaml` has format: `version: X.Y.Z+N`
- Check no extra spaces or special characters
- Ensure file is committed

### APK Not Found

**Problem**: Archive stage can't find APK

**Solution**:
- Check Flutter build succeeded
- Verify APK path: `build/app/outputs/flutter-apk/`
- Ensure `APP_NAME` environment variable is correct

### GitHub Release Creation Failed

**Problem**: GitHub API returns error

**Solutions**:
- Check token has `repo` write access
- Verify tag doesn't already exist
- Check rate limits: https://api.github.com/rate_limit
- Ensure repo name is correct: `owner/repo`

## CI/CD Best Practices

### Before Release
- ✅ Test app manually on device
- ✅ Review code changes
- ✅ Update release notes if needed
- ✅ Ensure tests pass locally

### After Release
- ✅ Verify APK downloads and installs
- ✅ Check GitHub release page
- ✅ Test app functionality
- ✅ Update Play Store listing if needed

### Version Strategy
- **Patch**: Bug fixes only, no new features
- **Minor**: New features, backward compatible
- **Major**: Breaking changes, major updates

### Build Number
- Increments automatically every build
- Never reuse build numbers
- Used as Android `versionCode`
- Must be greater than previous release

## Integration with Version Management

Pipeline fully integrates with centralized version management:

**Files Updated**:
- `pubspec.yaml` - Build configuration
- `lib/utils/constants.dart` - Display constants

**Script Used**:
- `scripts/update_version.sh` - Automated version update

**Version Format**:
- Follows semantic versioning: `MAJOR.MINOR.PATCH+BUILD`
- Example: `1.2.3+10`

See [version-management.md](version-management.md) for details.

## Security Considerations

### Secrets Management
- ✅ Never hardcode tokens in Jenkinsfile
- ✅ Use Jenkins credentials store
- ✅ Tokens are masked in console output
- ✅ Credentials have limited scope

### Access Control
- ✅ Jenkins job requires authentication
- ✅ GitHub token has minimal required permissions
- ✅ Docker runs as root inside container (isolated)
- ✅ Workspace cleaned after build

### Build Reproducibility
- ✅ Docker image version tagged (`stable`)
- ✅ Dependencies locked in `pubspec.lock`
- ✅ Build environment is isolated
- ✅ Clean workspace on each build

## Future Enhancements

- [ ] Automated version increment based on commit messages
- [ ] Changelog generation from git history
- [ ] Play Store upload integration
- [ ] Beta/staging release channels
- [ ] Slack/email notifications
- [ ] Performance testing
- [ ] Screenshot automation
- [ ] Multi-APK builds (arm64-v8a, armeabi-v7a, x86_64)
- [ ] App Bundle (AAB) generation for Play Store
- [ ] Code signing with keystore
- [ ] Automated rollback on failure

## Related Documentation

- [version-management.md](version-management.md) - Version update workflow
- [ANDROID_SETUP_GUIDE.md](../../ANDROID_SETUP_GUIDE.md) - Android configuration
- [README.md](../../README.md) - Project overview

## Version History

- **2026-02-05**: Initial CI/CD pipeline with Docker, versioning, and GitHub releases
