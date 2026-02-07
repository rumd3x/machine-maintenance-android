# Play Store Publishing Setup

**Date**: 7 de fevereiro de 2026

## Overview

Automated Google Play Store publishing is integrated into the Jenkins CI/CD pipeline. The pipeline can build and publish App Bundles (AAB) to the Play Store with custom release notes.

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

Even with Google Play App Signing, you need an upload keystore to sign your AAB before uploading.

#### Generate Upload Keystore

```bash
keytool -genkey -v -keystore machine-maintenance-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass YOUR_STORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD \
  -dname "CN=Your Name, OU=Your Organization, O=Company, L=City, ST=State, C=US"
```

**Important**: 
- Store passwords securely (use a password manager)
- Backup the keystore file safely
- Never commit the keystore to git

#### Configure Flutter Signing

Create `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/path/to/machine-maintenance-upload.jks
```

Add to `.gitignore`:
```
android/key.properties
*.jks
*.keystore
```

Update `android/app/build.gradle.kts`:

```kotlin
// Load keystore properties
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

### 4. Create Service Account for API Access

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
   - **Keep this file secure!**

4. **Link Service Account to Play Console**:
   - Go to Play Console → Setup → API access
   - Click "Link" to link your Cloud project
   - Grant access to the service account
   - Set permissions:
     - ✅ View app information and download bulk reports
     - ✅ Manage production releases
     - ✅ Manage testing track releases
     - ✅ Manage internal app sharing releases

### 5. Configure Jenkins Credentials

#### Add Play Store Service Account JSON

1. Go to Jenkins → Manage Jenkins → Manage Credentials
2. Select domain: (global)
3. Add Credentials:
   - **Kind**: Secret file
   - **File**: Upload `play-store-service-account.json`
   - **ID**: `play-store-service-account`
   - **Description**: Play Store API Service Account

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

## Security Best Practices

- ✅ **Never** commit keystores or passwords to git
- ✅ Use `.gitignore` for sensitive files
- ✅ Store service account JSON securely
- ✅ Use environment variables for secrets in CI
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
