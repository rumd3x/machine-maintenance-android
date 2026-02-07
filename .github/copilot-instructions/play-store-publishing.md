# Play Store Publishing Architecture

**Purpose**: AI context for Play Store publishing integration in CI/CD pipeline

## Overview

Automated Google Play Store publishing via Jenkins. Pipeline builds AAB and publishes to Play Store with configurable tracks and release notes.

## Security Model (Public Repository)

**Critical**: This is a public repository. All secrets are external.

### Protected Files (Never Commit):
- Keystores (`.jks`, `.keystore`)
- `android/key.properties`
- Service account JSON (`*service-account*.json`)
- Passwords, API keys

### Safe to Commit:
- Build configuration (`build.gradle.kts`) - reads from environment variables
- Jenkinsfile - uses credential IDs, not actual secrets
- `.gitignore` - blocks sensitive files

### Secret Flow:
```
Developer → Jenkins Credentials → Environment Variables → Build Process
```

- **Local dev**: `key.properties` (gitignored) points to keystore outside repo
- **CI/CD**: Jenkins injects secrets dynamically via environment variables
- **Build**: Gradle reads from env vars, never from repository

## Google Play App Signing

**Current Setup**: Google Play App Signing enabled (recommended approach)

### Two-Key System:
1. **Upload Key** (project manages): Signs AAB before upload to Play Console
   - Required for uploading to Play Store
   - Can be reset if lost (Google controls distribution key)
2. **App Signing Key** (Google manages): Signs final APK for users
   - Google holds this securely
   - Users never see upload key

### Upload Key Options:
- **Option A**: Let Google generate `.der` certificate
  - Download from Play Console → App Signing
  - Convert to `.jks` for local use (if needed)
- **Option B**: Generate own keystore with `keytool`
  - Store outside repository
  - Upload to Play Console

## Build Configuration

### Android Signing (`android/app/build.gradle.kts`)

```kotlin
// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = java.util.Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { stream ->
        keystoreProperties.load(stream)
    }
}

android {
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")  // Fallback for debug builds
            }
        }
    }
}
```

**Pattern**: Reads from `key.properties` (gitignored) if exists, otherwise falls back to debug signing.

### key.properties Format

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=/absolute/path/to/keystore.jks
```

- Uses absolute paths to keystores outside repository
- Each developer/CI system has their own local copy
- File is gitignored

### Gradle Play Publisher Configuration

```kotlin
play {
    // Service account JSON path from environment
    val serviceAccountJsonPath = System.getenv("PLAY_STORE_CONFIG_JSON")
    if (serviceAccountJsonPath != null) {
        serviceAccountCredentials.set(file(serviceAccountJsonPath))
    }
    
    // Release track from environment (defaults to internal for safety)
    val releaseTrack = System.getenv("PLAY_STORE_TRACK") ?: "internal"
    track.set(releaseTrack)
    
    // Release status
    releaseStatus.set(com.github.triplet.gradle.androidpublisher.ReleaseStatus.COMPLETED)
    
    // Prefer AAB over APK
    defaultToAppBundles.set(true)
}
```

**Pattern**: Reads from environment variables, not hardcoded values.

## Jenkins Pipeline Integration

### Environment Variables

```groovy
environment {
    PLAY_STORE_CREDENTIALS_ID = 'play-store-service-account'
    ANDROID_KEYSTORE_ID = 'android-upload-keystore'
    ANDROID_KEYSTORE_PASSWORD_ID = 'android-keystore-password'
}
```

### Setup Android Signing Stage

```groovy
stage('Setup Android Signing') {
    steps {
        withCredentials([
            file(credentialsId: env.ANDROID_KEYSTORE_ID, variable: 'KEYSTORE_FILE'),
            string(credentialsId: env.ANDROID_KEYSTORE_PASSWORD_ID, variable: 'KEYSTORE_PASSWORD')
        ]) {
            // Copy keystore to workspace
            sh 'cp $KEYSTORE_FILE android/upload-keystore.jks'
            
            // Create key.properties dynamically
            sh """
                cat > android/key.properties << EOF
storePassword=${KEYSTORE_PASSWORD}
keyPassword=${KEYSTORE_PASSWORD}
keyAlias=upload
storeFile=\${PWD}/android/upload-keystore.jks
EOF
            """
        }
    }
}
```

**Pattern**: Injects credentials from Jenkins at build time, creates `key.properties` dynamically.

### Build Stages

```groovy
// APK for GitHub release
stage('Build Release APK') {
    sh 'flutter build apk --release'
}

// AAB for Play Store (conditional)
stage('Build App Bundle (AAB)') {
    when { expression { params.PUBLISH_TO_PLAY_STORE == true } }
    sh 'flutter build appbundle --release'
}

// Publish to Play Store (conditional)
stage('Publish to Play Store') {
    when { expression { params.PUBLISH_TO_PLAY_STORE == true } }
    withCredentials([file(credentialsId: env.PLAY_STORE_CREDENTIALS_ID, variable: 'PLAY_STORE_CONFIG_JSON')]) {
        sh '''
            cd android
            PLAY_STORE_TRACK=${params.PLAY_STORE_TRACK} ./gradlew publishBundle --no-daemon
        '''
    }
}
```

## Pipeline Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `RELEASE_TYPE` | Choice | Version increment: patch/minor/major |
| `RELEASE_NOTES` | Text | Custom release notes (GitHub + Play Store) |
| `PUBLISH_TO_PLAY_STORE` | Boolean | Enable Play Store publishing |
| `PLAY_STORE_TRACK` | Choice | production/internal/beta/alpha |

## Release Tracks

| Track | Use Case | Review | Availability |
|-------|----------|--------|--------------|
| **production** | Public release | Required (1-7 days) | All users |
| **internal** | Internal testing | None | Up to 100 testers |
| **beta** | Beta testing | None | Tester list |
| **alpha** | Early access | None | Smaller group |

**Default**: production (automated public releases)

## Service Account Setup

### Required:
1. Google Cloud project with "Google Play Android Developer API" enabled
2. Service account with JSON key
3. Service account linked in Play Console → API Access
4. Permissions granted: production releases, testing tracks

### Jenkins Credential:
- **Kind**: Secret file
- **ID**: `play-store-service-account`
- **File**: Service account JSON

## Common Issues

### "APK signature verification failed"
- **Cause**: AAB not signed or wrong key
- **Fix**: Check `key.properties` configuration, verify keystore path

### "applicationNotFound"
- **Cause**: App doesn't exist in Play Console or applicationId mismatch
- **Fix**: Verify `applicationId` in `build.gradle.kts` matches Play Console

### "Service account not found"
- **Cause**: Service account not linked or no permissions
- **Fix**: Play Console → API Access → verify service account listed with permissions

### "First release must be uploaded via Play Console"
- **Cause**: Initial release requires manual upload
- **Fix**: Build AAB locally, upload once manually, then automation works

## Files Modified

- `android/app/build.gradle.kts` - Added signing config and Gradle Play Publisher
- `Jenkinsfile` - Added "Setup Android Signing" and "Publish to Play Store" stages
- `android/.gitignore` - Already protects `**/*.jks`, `key.properties`, `*service-account*.json`

## Technical Dependencies

- **Gradle Play Publisher**: `com.github.triplet.play` v3.10.1
- **Jenkins Credentials**: Secret file for keystore and service account
- **Android App Bundle**: Required format for Play Store

## Best Practices for AI Assistance

When helping with Play Store setup:
- **Never** suggest committing keystores, passwords, or service account JSON
- **Always** use environment variables for sensitive configuration
- **Always** verify `.gitignore` protects sensitive files
- **Remind** about two-key system (upload vs app signing)
- **Check** if Google Play App Signing is enabled before advising

## Documentation References

- Main documentation: `.github/copilot-instructions.md` (Recent Changes section)
- CI/CD pipeline: `.github/copilot-instructions/ci-cd-pipeline.md`
- Version management: `.github/copilot-instructions/version-management.md`
