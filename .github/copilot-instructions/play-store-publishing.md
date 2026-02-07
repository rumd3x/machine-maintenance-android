# Play Store Publishing Setup

**Date**: 7 de fevereiro de 2026

## Overview

Automated Google Play Store publishing is integrated into the Jenkins CI/CD pipeline. The pipeline can build and publish App Bundles (AAB) to the Play Store with custom release notes.

## 🔒 Public Repository Security

**CRITICAL**: This repository is public. All sensitive credentials must be kept outside the repository and managed securely.

### ❌ NEVER Commit to Repository:
- ❌ Keystores (`.jks`, `.keystore` files)
- ❌ `android/key.properties` file
- ❌ Service account JSON files
- ❌ Passwords or API keys
- ❌ `local.properties` with sensitive paths

### ✅ What's Safe in Public Repo:
- ✅ Build configuration files (`build.gradle.kts`)
- ✅ Jenkinsfile (uses credential IDs, not actual secrets)
- ✅ Documentation
- ✅ Source code (without hardcoded secrets)

### 🛡️ Security Model:
- **Jenkins**: Stores all secrets as credentials (never in repo)
- **Local Development**: Secrets in `key.properties` (gitignored)
- **CI/CD**: Injects secrets via environment variables
- **.gitignore**: Blocks all sensitive files from being committed

## How It Works (Secure Workflow)

```
┌─────────────────────────────────────────────────────────────┐
│  PUBLIC REPOSITORY (GitHub)                                 │
├─────────────────────────────────────────────────────────────┤
│  ✅ Source code                                              │
│  ✅ build.gradle.kts (reads from env vars)                  │
│  ✅ Jenkinsfile (references credential IDs)                 │
│  ✅ .gitignore (blocks sensitive files)                     │
│  ❌ NO keystores                                            │
│  ❌ NO passwords                                            │
│  ❌ NO service account JSON                                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  LOCAL DEVELOPMENT                                          │
├─────────────────────────────────────────────────────────────┤
│  📁 ~/secure-keys/machine-maintenance-upload.jks            │
│  📄 android/key.properties (gitignored)                     │
│     ↳ Points to keystore in secure location                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  JENKINS CI/CD                                              │
├─────────────────────────────────────────────────────────────┤
│  🔐 Secret File: android-upload-keystore                    │
│  🔐 Secret File: play-store-service-account                 │
│  🔐 Secret Text: keystore passwords                         │
│     ↳ Injected as environment variables at build time      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  BUILD PROCESS                                              │
├─────────────────────────────────────────────────────────────┤
│  1. Checkout public repo (no secrets)                       │
│  2. Jenkins injects credentials via env vars                │
│  3. Gradle reads env vars (never from repo)                 │
│  4. Signs AAB with injected keystore                        │
│  5. Publishes with injected service account                 │
└─────────────────────────────────────────────────────────────┘
```

**Key Principle**: Secrets flow INTO the build from secure external sources, never FROM the repository.

## Features

- **Automated AAB building** - Android App Bundle for Play Store
- **Release notes support** - Custom notes in both GitHub and Play Store
- **Track selection** - Choose production, internal, beta, or alpha track
- **Production releases** - Direct publishing to production (with Google review)
- **Optional publishing** - Checkbox to enable/disable Play Store push

## Prerequisites

### 1. Google Play Console Account

1. Go to [Google Play Console](https://play.google.com/console)
2. Create a developer account (one-time $25 fee)
3. Create your app in the console
4. Complete store listing requirements

### 2. App Signing

Google Play requires apps to be signed with a release keystore. You have two options:

#### Option A: Google Play App Signing (Recommended)

**Advantages**:
- Google manages your signing key securely
- Easier key rotation and recovery
- Optimized APK delivery

**Setup**:
1. Go to Play Console → Your App → Setup → App Signing
2. Follow the wizard to enroll in Google Play App Signing
3. Google generates and manages the app signing key
4. You only need to create an upload key

#### Option B: Manual Key Management

Manage your own signing keys (not recommended for production).

### 3. Create Upload Keystore

**🔒 SECURITY NOTE**: This step creates sensitive files that must NEVER be committed to the public repository.

Even with Google Play App Signing, you need an upload keystore to sign your AAB before uploading.

#### Generate Upload Keystore

**Run this command locally** (not in the repo):

```bash
# Create keystore in a secure location OUTSIDE the repository
mkdir -p ~/secure-keys
cd ~/secure-keys

keytool -genkey -v -keystore machine-maintenance-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass YOUR_STORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD \
  -dname "CN=Your Name, OU=Your Organization, O=Company, L=City, ST=State, C=US"
```

**Important Security Practices**: 
- ✅ Store keystore in a secure location (e.g., `~/secure-keys/`, encrypted drive, password manager)
- ✅ Use strong, unique passwords (20+ characters)
- ✅ Backup keystore to multiple secure locations (encrypted cloud, USB drive)
- ✅ Never share keystore via email, chat, or public channels
- ❌ NEVER commit the keystore to git (checked by `.gitignore`)
- ❌ NEVER store keystore in the project directory

#### Configure Flutter Signing (Local Development Only)

Create `android/key.properties` **in your local environment**:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/home/youruser/secure-keys/machine-maintenance-upload.jks
```

**CRITICAL**: 
- This file is automatically ignored by `.gitignore`
- Use absolute path pointing to secure location
- Each developer needs their own `key.properties` locally
- Never commit this file to git

#### Verify .gitignore Protection

Ensure `android/.gitignore` contains (already configured in this repo):

```gitignore
# Remember to never publicly share your keystore.
key.properties
**/*.keystore
**/*.jks
**/play-store-service-account.json
**/*service-account*.json
```

#### Update Build Configuration (Safe for Public Repo)

Update `android/app/build.gradle.kts` with this code (safe to commit):

```kotlin
// Load keystore properties from gitignored file
val keystorePropertiesFile = rootProject.file("../key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

**Why this is safe for public repos**:
- ✅ Code only reads from `key.properties` (which is gitignored)
- ✅ No hardcoded secrets
- ✅ Gracefully handles missing file (won't break debug builds)
- ✅ Each developer/CI system has their own `key.properties`

### 4. Create Service Account for API Access

**🔒 SECURITY NOTE**: The service account JSON file contains sensitive credentials and must NEVER be committed to the repository.

The Jenkins pipeline uses the Google Play Developer API to publish releases.

#### Steps:

1. **Enable Google Play Developer API**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing
   - Enable "Google Play Android Developer API"

2. **Create Service Account**:
   - Go to IAM & Admin → Service Accounts
   - Click "Create Service Account"
   - Name: `machine-maintenance-publisher`
   - Description: `Jenkins CI/CD for Play Store publishing`
   - Click "Create and Continue"

3. **Create JSON Key**:
   - Click on the created service account
   - Go to "Keys" tab
   - Add Key → Create new key → JSON
   - Download the JSON file (e.g., `play-store-service-account.json`)
   - **🔒 CRITICAL**: Store this file securely (password manager, encrypted storage)
   - **❌ NEVER commit this file to git** (protected by `.gitignore`)
   - **❌ NEVER share via email, chat, or public channels**

4. **Link Service Account to Play Console**:
   - Go to Play Console → Setup → API access
   - Click "Link" to link your Cloud project
   - Grant access to the service account
   - Set permissions:
     - ✅ View app information and download bulk reports
     - ✅ Manage production releases
     - ✅ Manage testing track releases
     - ✅ Manage internal app sharing releases

### 5. Configure Jenkins Credentials (CI/CD Only)

**🔒 SECURITY MODEL**: All secrets are stored in Jenkins credentials, never in the repository.

#### Add Play Store Service Account JSON

1. Go to Jenkins → Manage Jenkins → Manage Credentials
2. Select domain: (global)
3. Add Credentials:
   - **Kind**: Secret file
   - **File**: Upload `play-store-service-account.json`
   - **ID**: `play-store-service-account`
   - **Description**: Play Store API Service Account

**Note**: This credential ID is referenced in Jenkinsfile but the actual file never touches the repository.

#### Add Keystore to Jenkins

For Jenkins to sign the AAB, it needs access to the keystore:

**Option 1: Store as Jenkins Credential (Recommended)**

1. Add Credentials:
   - **Kind**: Secret file
   - **File**: Upload `machine-maintenance-upload.jks`
   - **ID**: `android-upload-keystore`

2. Add keystore password credentials:
   - **Kind**: Secret text
   - **Secret**: Your store password
   - **ID**: `android-keystore-password`

**Option 2: Store on Jenkins Host**

Copy keystore to Jenkins server and reference absolute path in configuration.

### 6. Update Jenkinsfile Environment Variables

Ensure these are set in the Jenkinsfile:

```groovy
environment {
    PLAY_STORE_CREDENTIALS_ID = 'play-store-service-account'
    // ... other vars
}
```

## Pipeline Usage

### Running a Release with Play Store Publishing

1. Go to Jenkins → machine-maintenance-android-release
2. Click "Build with Parameters"
3. Configure:
   - **RELEASE_TYPE**: `patch`, `minor`, or `major`
   - **RELEASE_NOTES**: Enter your release notes (supports markdown)
   - **PUBLISH_TO_PLAY_STORE**: ✅ Check to publish
   - **PLAY_STORE_TRACK**: Select track (production, internal, beta, alpha)
4. Click "Build"

**Track Selection Guide**:
- **production**: For stable releases ready for all users (requires Google review, 1-7 days)
- **internal**: For internal testing before public release (up to 100 testers, immediate)
- **beta**: For public beta testing programs
- **alpha**: For early access testing with smaller group

### Release Notes Format

The release notes you enter will appear in:
- **GitHub Release** description
- **Play Store** "What's new" section

**Example**:
```
## New Features
- Added front/rear tire tracking
- Added belts/chains maintenance type
- Improved notification system

## Bug Fixes
- Fixed notification timing for new machines
- Resolved yellow-to-red transition issues

## UI Improvements
- Better action buttons on detail screen
- Clickable status indicators
```

### First-Time Publishing Checklist

Before your first Play Store upload:

- [ ] App signed with upload keystore
- [ ] Google Play App Signing enrolled
- [ ] Service account created with API access
- [ ] Service account linked in Play Console
- [ ] Jenkins credentials configured
- [ ] Store listing completed (title, description, screenshots)
- [ ] Content rating questionnaire completed
- [ ] Privacy policy URL provided
- [ ] App content declaration completed

## Release Tracks

The pipeline supports all Play Store release tracks via the **PLAY_STORE_TRACK** parameter. Production releases are fully automated and do not require manual promotion.

### Available Tracks

1. **Production** (Default) - Public release
   - Available to all users worldwide
   - Requires Google's review (1-7 days)
   - Fully automated - no manual promotion needed
   - Best for: Stable releases ready for general availability

2. **Internal** - Internal testing
   - Up to 100 testers
   - No review required, immediate availability
   - Best for: Quick testing before public release
   - Requires manual promotion to production

3. **Beta** - Beta testing
   - Larger testing audience (open or closed)
   - Best for: Public beta programs
   - Requires manual promotion to production

4. **Alpha** - Alpha testing
   - Smaller alpha testing group
   - Best for: Early access testing
   - Requires manual promotion to production

### Selecting the Track

**In Jenkins**: Select the track via the `PLAY_STORE_TRACK` parameter when building

**Recommended workflow**:
1. Use **production** for normal releases (fully automated)
2. Use **internal** if you want to test on Play Store before making public
3. Use **beta/alpha** for staged rollouts with specific tester groups

**Note**: The track is set dynamically via the `PLAY_STORE_TRACK` environment variable. The `build.gradle.kts` reads this variable and defaults to "internal" for safety if not specified.

## Play Store Review Process

### Internal Testing
- **Review**: None required
- **Availability**: Immediate (within ~1 hour)
- **Testers**: Up to 100 internal testers

### Production Release
- **Review**: Required by Google (1-7 days)
- **Availability**: After approval
- **Audience**: Public

## Troubleshooting

### Error: "APK signature verification failed"

**Problem**: AAB not signed or signed with wrong key

**Solution**:
- Check `key.properties` configuration
- Verify keystore path is correct
- Ensure passwords match

### Error: "applicationNotFound" or "packageNotFound"

**Problem**: App doesn't exist in Play Console or applicationId mismatch

**Solution**:
- Verify `applicationId` in `build.gradle.kts` matches Play Console
- Ensure app is created in Play Console
- Check service account has access to this app

### Error: "Service account not found"

**Problem**: Service account not linked or no permissions

**Solution**:
- Go to Play Console → API Access
- Verify service account is listed
- Grant required permissions

### Error: "The first release must be uploaded via Play Console"

**Problem**: First-time releases cannot be automated

**Solution**:
1. Build AAB locally: `flutter build appbundle --release`
2. Upload manually to Play Console (Internal Testing)
3. Once uploaded, automated releases will work

### Error: "Release notes too long"

**Problem**: Play Store limits release notes to 500 characters

**Solution**: Keep release notes concise, detailed changelog can be in GitHub

## Security Best Practices for Public Repositories

### ✅ DO:

**File Protection**:
- ✅ Keep `.gitignore` updated with all sensitive file patterns
- ✅ Store keystores outside the repository directory
- ✅ Use absolute paths in `key.properties` pointing to secure locations
- ✅ Regularly audit git history for accidentally committed secrets

**Credential Management**:
- ✅ Store all secrets in Jenkins credentials (Secret file/Secret text)
- ✅ Use environment variables in CI/CD pipelines
- ✅ Rotate service account keys every 90 days
- ✅ Use different keystores for development vs production (if needed)

**Access Control**:
- ✅ Limit Jenkins access to authorized personnel only
- ✅ Enable 2FA on Google Play Console account
- ✅ Limit service account permissions to minimum required
- ✅ Review Play Console API access regularly

**Backup & Recovery**:
- ✅ Backup keystores to encrypted cloud storage (e.g., encrypted drive, password manager)
- ✅ Store keystore passwords separately from keystore files
- ✅ Document recovery procedures for lost credentials
- ✅ Test backup restoration process

### ❌ DON'T:

**Never Commit**:
- ❌ Keystores (`.jks`, `.keystore`) to git
- ❌ `android/key.properties` file
- ❌ Service account JSON files
- ❌ Passwords or API keys in code or configs
- ❌ `local.properties` with sensitive paths

**Never Share**:
- ❌ Keystores via email, chat, or file sharing
- ❌ Service account JSON via insecure channels
- ❌ Screenshots showing credentials
- ❌ Debug logs containing sensitive data

**Never Hardcode**:
- ❌ Passwords in source code
- ❌ API keys in configuration files
- ❌ Keystore paths in committed files (use variables)

### 🔍 Security Audit Checklist

Before making repository public or after major changes:

```bash
# 1. Check for accidentally committed secrets
git log --all --full-history --source --find-renames --diff-filter=D -- "*.jks" "*.keystore" "key.properties" "*service-account*.json"

# 2. Verify gitignore is working
git status --ignored

# 3. Check for hardcoded credentials in code
grep -r "password\|secret\|key" --include="*.dart" --include="*.kt" --include="*.gradle*"

# 4. Verify no sensitive files are tracked
git ls-files | grep -E "\.jks$|\.keystore$|key\.properties|service-account.*\.json"
```

### 🚨 If Secrets Are Accidentally Committed

**DO NOT** just delete the file and commit - it remains in git history!

**Immediate actions**:
1. **Rotate all compromised credentials immediately**:
   - Generate new keystore (if committed)
   - Create new service account (if JSON committed)
   - Update Jenkins credentials

2. **Remove from git history**:
   ```bash
   # Use git-filter-repo (recommended) or BFG Repo-Cleaner
   git filter-repo --path key.properties --invert-paths
   git filter-repo --path "*.jks" --invert-paths
   
   # Force push to remote
   git push origin --force --all
   ```

3. **Revoke old credentials**:
   - Delete old service account in Google Cloud Console
   - Never reuse the old keystore (even after removal from repo)

### 📋 Public Repository Security Checklist

Before publishing:
- [ ] Reviewed all `.gitignore` entries
- [ ] Verified no secrets in git history
- [ ] All sensitive configs use environment variables
- [ ] Jenkins credentials properly configured
- [ ] README doesn't contain sensitive information
- [ ] Documentation explains security model
- [ ] Test builds work without local secrets (should gracefully fail)


- ✅ Rotate service account keys periodically
- ✅ Limit service account permissions to minimum required
- ✅ Enable 2FA on Google Play Console account
- ✅ Backup keystores in secure, encrypted storage

## Testing Before Production

### Option 1: Direct Production Release (Automated)

For stable releases that are ready for all users:

1. Run Jenkins build with:
   - `PUBLISH_TO_PLAY_STORE` enabled
   - `PLAY_STORE_TRACK` = **production**
2. Google will review the release (1-7 days)
3. After approval, release is automatically available to all users

**Best for**: Regular releases where you've already tested locally and are confident in stability.

### Option 2: Internal Testing First (Manual Promotion)

For releases where you want to test on Play Store infrastructure first:

1. Run Jenkins build with:
   - `PUBLISH_TO_PLAY_STORE` enabled
   - `PLAY_STORE_TRACK` = **internal**
2. Wait for Play Console processing (~1 hour)
3. Go to Play Console → Internal Testing
4. Add internal testers (use email addresses)
5. Share the internal testing link
6. Test the app thoroughly
7. If successful, manually promote to production:
   - Go to Internal Testing → Review release
   - Click "Promote release" → Production
   - Submit for review

**Best for**: Major releases or significant changes where you want extra validation on Play Store.

## Gradle Play Publisher Configuration Reference

Current configuration in `android/app/build.gradle.kts`:

```kotlin
play {
    // Service account JSON for authentication
    serviceAccountCredentials.set(file(System.getenv("PLAY_STORE_CONFIG_JSON")))
    
    // Release track (dynamically set via PLAY_STORE_TRACK environment variable)
    val releaseTrack = System.getenv("PLAY_STORE_TRACK") ?: "internal"
    track.set(releaseTrack)
    
    // Release status (completed = immediately available)
    releaseStatus.set(ReleaseStatus.COMPLETED)
    
    // Prefer AAB over APK
    defaultToAppBundles.set(true)
}
```

### Additional Options

```kotlin
play {
    // Release to percentage of users (staged rollout)
    userFraction.set(0.1)  // 10% rollout
    
    // Retain artifacts for analysis
    retain.set(true)
    
    // Set app version name/code explicitly
    resolutionStrategy.set(ResolutionStrategy.AUTO)
}
```

## Monitoring Releases

### Jenkins Console Output

Watch for these success indicators:
```
✅ Build completed successfully!
✅ Published to Play Store (internal testing track)
Play Console: https://play.google.com/console
```

### Play Console

1. Go to Play Console → Your App → Release → Production/Testing
2. Check release status
3. View crash reports and analytics

## Next Steps After Setup

1. **First manual upload** - Upload first AAB via Play Console
2. **Test Jenkins pipeline** - Run with `PUBLISH_TO_PLAY_STORE` enabled and track = internal
3. **Test production release** - Run with track = production for automated public releases
4. **Monitor releases** - Check Play Console after each release
5. **Consider staged rollouts** - Use internal/beta/alpha for gradual testing

## Support

- **Google Play Console**: https://support.google.com/googleplay/android-developer
- **Gradle Play Publisher**: https://github.com/Triple-T/gradle-play-publisher
- **Flutter Deployment**: https://docs.flutter.dev/deployment/android

---

**Document Version**: 1.1  
**Last Updated**: 7 de fevereiro de 2026  
**Pipeline**: Jenkins with Gradle Play Publisher  
**Default Track**: Production (automated releases)
