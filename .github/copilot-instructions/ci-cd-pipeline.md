# CI/CD Pipeline Documentation

**Date**: 2026-02-05

## Overview

Automated Jenkins CI/CD pipeline for building, versioning, and releasing the Machine Maintenance Android app. The pipeline runs in a containerized Flutter environment using Docker and handles complete release workflow including version management, building, tagging, and Forgejo releases.

### Pipeline Philosophy

**Quality assurance before release**: This pipeline is designed for releasing verified code, not for testing it. All code quality checks (testing, analysis, linting) should be performed locally before triggering a release build.

**Pipeline responsibilities**:
- ✅ Version management (increment and tag)
- ✅ Building release artifacts (APK and AAB)
- ✅ Publishing to Forgejo (mirrored to GitHub) and Play Store
- ✅ Artifact archiving

**Developer responsibilities**:
- ✅ Run `flutter test` locally
- ✅ Run `flutter analyze` locally
- ✅ Fix all issues before triggering release
- ✅ Verify app functionality on test devices

This separation keeps the release pipeline fast and focused on deployment, while ensuring quality through local development practices.

## Pipeline Architecture

### Infrastructure
- **Jenkins Node**: Docker plugin with access to Docker daemon
- **Docker Image**: `cirrusci/flutter:stable` (official Flutter Docker image)
- **Execution**: Entire pipeline runs inside single Flutter Docker container as agent
- **Trigger**: Manual (parameterized build)

### Docker Strategy

The pipeline uses a Docker container as the primary agent:

```groovy
agent {
    docker {
        image 'cirrusci/flutter:stable'
        label 'docker'
    }
}
```

**Key Points**:
- Jenkins spins up Flutter container once at pipeline start
- All stages execute inside this container
- No nested Docker containers
- Clean, simple execution model
- Workspace automatically mounted by Jenkins Docker plugin

Benefits:
- ✅ No Flutter installation needed on Jenkins host
- ✅ Consistent build environment for entire pipeline
- ✅ No Docker-in-Docker complexity
- ✅ No workspace mounting issues
- ✅ Uses official, pre-configured Flutter environment
- ✅ Faster execution (container starts once, not per stage)

## Build Parameters

### RELEASE_TYPE
**Type**: Choice parameter
**Options**:
- `patch` - Bug fixes, minor changes (1.0.0 → 1.0.1)
- `minor` - New features, backward compatible (1.0.0 → 1.1.0)
- `major` - Breaking changes (1.0.0 → 2.0.0)

Build number is automatically incremented on every build.

### RELEASE_NOTES
**Type**: Text parameter
**Optional**: Yes
**Description**: Multiline text field for custom release notes

**Usage**:
- Included in Forgejo release description
- Used for Play Store "What's new" section
- Supports markdown formatting for Forgejo
- Automatically formatted for both platforms

**Example**:
```
## New Features
- Added front/rear tire tracking
- Improved notification system

## Bug Fixes
- Fixed notification timing issues
```

### PUBLISH_TO_PLAY_STORE
**Type**: Boolean parameter
**Default**: `false` (unchecked)
**Description**: Enable/disable Google Play Store publishing

**Behavior**:
- When **enabled** (checked):
  - Builds Android App Bundle (AAB)
  - Publishes to Play Store (track determined by PLAY_STORE_TRACK parameter)
  - Requires Play Store credentials configured
  - Archives both APK and AAB
- When **disabled** (unchecked):
  - Only builds APK
  - Only creates Forgejo release
  - No Play Store interaction

**Safety**: Default is unchecked to prevent accidental publishing during testing.

### PLAY_STORE_TRACK
**Type**: Choice parameter
**Default**: `production`
**Choices**: production, internal, beta, alpha
**Description**: Select which Play Store track to publish to

**Track Options**:

1. **production** (Default)
   - Public release available to all users
   - Requires Google's review process (1-7 days)
   - Best for: Stable releases ready for general availability
   - Automated publishing (no manual promotion needed)

2. **internal**
   - Internal testing with up to 100 testers
   - No review required, available immediately
   - Best for: Quick testing before public release
   - Requires manual promotion to production

3. **beta**
   - Open or closed beta testing
   - Larger testing audience
   - Best for: Public beta programs
   - Requires manual promotion to production

4. **alpha**
   - Smaller alpha testing group
   - Best for: Early access testing
   - Requires manual promotion to production

**When to use each**:
- Use **production** for normal releases (fully automated)
- Use **internal** for testing before making public
- Use **beta/alpha** for staged rollouts with specific tester groups

## Pipeline Stages

### 1. Checkout
```groovy
stage('Checkout')
```
- Clones repository from SCM
- Configures git user for commits
- Sets up workspace

### 2. Setup Android Signing
```groovy
stage('Setup Android Signing')
```
**Purpose**: Injects Android keystore credentials from Jenkins into the workspace

**Process**:
1. Loads keystore file from Jenkins credential: `android-upload-keystore`
2. Loads keystore password from Jenkins credential: `android-keystore-password`
3. Copies keystore to `android/upload-keystore.jks`
4. Creates `android/key.properties` dynamically with:
   - storePassword
   - keyPassword
   - keyAlias (always `upload`)
   - storeFile (absolute path to keystore)

**Security**:
- Credentials never committed to repository
- Keystore and properties file created temporarily in workspace
- Automatically cleaned up after build (workspace cleanup)
- `.gitignore` protects files from accidental commit

**Required Jenkins Credentials**:
- `android-upload-keystore` (Secret file) - The JKS keystore file
- `android-keystore-password` (Secret text) - Password for keystore and key

This stage ensures release builds are properly signed without storing sensitive data in the repository.

### 3. Calculate New Version
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

### 4. Update Version
```groovy
stage('Update Version')
```
- Makes update script executable
- Runs `./scripts/update_version.sh ${NEW_VERSION} ${NEW_BUILD_NUMBER}`
- Updates both `pubspec.yaml` and `lib/utils/constants.dart`
- Verifies changes

### 5. Get Dependencies
```groovy
stage('Get Dependencies')
```
- Runs `flutter pub get`
- Downloads all package dependencies
- Required before building

**Note**: Code analysis and testing are done locally before release. The release pipeline focuses on building and deploying verified code.

### 6. Build Release APK
```groovy
stage('Build Release APK')
```
- Runs `flutter build apk --release`
- Generates optimized production APK
- Renames APK with version: `machine-maintenance-1.1.0-2.apk`
- APK location: `build/app/outputs/flutter-apk/`
- Uses release signing config from `android/key.properties`

### 7. Build App Bundle (AAB)
```groovy
stage('Build App Bundle (AAB)') {
    when {
        expression { params.PUBLISH_TO_PLAY_STORE == true }
    }
}
```
**Conditional**: Only runs if `PUBLISH_TO_PLAY_STORE` is enabled

**Process**:
- Runs `flutter build appbundle --release`
- Generates Android App Bundle for Play Store
- Renames AAB with version: `machine-maintenance-1.1.0-2.aab`
- AAB location: `build/app/outputs/bundle/release/`
- Uses release signing config from `android/key.properties`

**Why AAB?**:
- Required format for Play Store publishing
- Allows Google to generate optimized APKs per device
- Smaller download sizes for end users

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

### 10. Push to Forgejo
```groovy
stage('Push to Forgejo')
```
- Pushes commit to `main` branch and the version tag
- Uses a Forgejo access token (Secret text credential `forgejo-credentials`)
- Format: `https://${FORGEJO_TOKEN}@forgejo.rumd3x.com/rumd3x/machine-maintenance-android.git`
- Forgejo mirrors to GitHub automatically; always use the canonical repo URL (Forgejo cannot follow a 301 on push)

### 11. Create Forgejo Release
```groovy
stage('Create Forgejo Release')
```
**Process**:
1. Creates the release via `POST /api/v1/repos/{repo}/releases` (`Authorization: token`)
2. Reads the release id from the response (fails the build if missing)
3. Sets release name `Release X.Y.Z` with custom notes, version, build, release type and CI info
4. Uploads the APK via `POST .../releases/{id}/assets?name=` (multipart `attachment`)

The AAB is archived in Jenkins only (not attached to the Forgejo release).

**Release URL**: `https://forgejo.rumd3x.com/rumd3x/machine-maintenance-android/releases/tag/{VERSION_TAG}`

### 12. Publish to Play Store
```groovy
stage('Publish to Play Store') {
    when {
        expression { params.PUBLISH_TO_PLAY_STORE == true }
    }
}
```
**Conditional**: Only runs if `PUBLISH_TO_PLAY_STORE` is enabled

**Process**:
1. Creates release notes directory: `android/app/src/main/play/release-notes/en-US/`
2. Writes release notes to `default.txt` file
   - Uses `RELEASE_NOTES` parameter
   - Falls back to auto-generated notes
3. Sets `PLAY_STORE_TRACK` environment variable from parameter
4. Runs Gradle task: `./gradlew publishBundle`
5. Uploads AAB to selected Play Store track

**Requirements**:
- Play Store service account JSON configured in Jenkins
- Credential ID: `play-store-service-account`
- First release must be uploaded manually via Play Console

**Track**: Dynamic (selected via `PLAY_STORE_TRACK` parameter)
- production: Automated public release (with Google review)
- internal: Internal testing (no review, manual promotion)
- beta/alpha: Staged rollouts (manual promotion)

**Gradle Configuration**:
- Uses Gradle Play Publisher plugin (v3.10.1)
- Credentials from environment: `PLAY_STORE_CONFIG_JSON`
- Track from environment: `PLAY_STORE_TRACK`
- Release status: COMPLETED (immediately available to track audience)

### 13. Archive Artifacts
```groovy
stage('Archive Artifacts')
```
- Archives APK in Jenkins
- Archives AAB (if Play Store publishing was enabled)
- Available for download from Jenkins UI
- Fingerprinting enabled for tracking

## Environment Variables

### Required Configuration

Update these in `Jenkinsfile`:

```groovy
environment {
    FORGEJO_CREDENTIALS_ID = 'forgejo-credentials'  // Jenkins credential ID
    FORGEJO_HOST = 'forgejo.rumd3x.com'
    FORGEJO_REPO = 'rumd3x/machine-maintenance-android'
    GIT_BRANCH_NAME = 'main'
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

### 3. Forgejo Credentials

**Forgejo access token (Required)**

1. Forgejo → Settings → Applications → Generate token with `write:repository`
2. Add to Jenkins:
   ```
   Jenkins → Credentials → Add Credentials
   Kind: Secret text
   ID: forgejo-credentials
   Secret: <your-token>
   ```

### 4. Pipeline Job Setup

Create new pipeline job:
```
Jenkins → New Item → Pipeline
Name: machine-maintenance-android-release
```

Configure:
- **Pipeline Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: Your Forgejo repo
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
Forgejo Release: https://forgejo.rumd3x.com/rumd3x/machine-maintenance-android/releases/tag/v1.1.0
```

**Artifacts**:
- APK available in Jenkins
- APK available in Forgejo release
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

### Forgejo Push Failed

**Problem**: Authentication failed

**Solutions**:
- Verify credential ID matches `FORGEJO_CREDENTIALS_ID`
- Check token has `write:repository` scope and hasn't expired
- Use the canonical repo URL (no redirects)
- Test token manually: `git push https://<token>@forgejo.rumd3x.com/<repo>.git`

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

### Forgejo Release Creation Failed

**Problem**: Forgejo API returns error / "no release id in response"

**Solutions**:
- Check token has `write:repository`
- Verify tag doesn't already exist
- Ensure repo name is correct: `owner/repo`

## CI/CD Best Practices

### Before Release
- ✅ Test app manually on device
- ✅ Review code changes
- ✅ Update release notes if needed
- ✅ Ensure tests pass locally

### After Release
- ✅ Verify APK downloads and installs
- ✅ Check Forgejo release page
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


## Pipeline Improvements (2026-02-11)

- Migrated from GitHub API to Forgejo (`forgejo-credentials`, `FORGEJO_HOST/REPO`, `GIT_BRANCH_NAME`)
- AAB is archived in Jenkins right after the AAB build (survives a failed publish); the final stage archives only the APK
- Safer defaults: track choices start with `internal`, status choices start with `draft`
- New `PUBLISH_STORE_LISTING` boolean (default **false**): syncs the Play listing (`publishListing`) before `publishBundle`. Screenshots are copied from `assets/images/screenshots` (max 8) into the gitignored `phone-screenshots` folder
