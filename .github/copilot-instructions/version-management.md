# Version Management

**Date**: 2026-02-05

## Overview

App version is centralized to ensure consistency across the entire application. Version numbers only need to be updated in two synchronized locations, with automated tooling to keep them in sync.

## Version Constants Location

**Primary Source**: `lib/utils/constants.dart`

```dart
const String appVersion = '1.0.0';
const int appBuildNumber = 1;
```

**Build Configuration**: `pubspec.yaml`

```yaml
version: 1.0.0+1
```

## Version Format

Follows semantic versioning: `MAJOR.MINOR.PATCH+BUILD`

- **MAJOR**: Breaking changes or major feature releases
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, minor improvements
- **BUILD**: Incremental build number for each release

Example: `1.2.3+10`
- Version: 1.2.3
- Build Number: 10

## How to Update Version

### Method 1: Automated Script (Recommended)

```bash
# Update version and build number
./scripts/update_version.sh 1.1.0 2

# Update version only (build number defaults to 1)
./scripts/update_version.sh 1.1.0
```

The script automatically updates:
- `pubspec.yaml` → used by Flutter build tools
- `lib/utils/constants.dart` → used for in-app display

### Method 2: Manual Update

1. **Update pubspec.yaml**:
   ```yaml
   version: 1.1.0+2
   ```

2. **Update lib/utils/constants.dart**:
   ```dart
   const String appVersion = '1.1.0';
   const int appBuildNumber = 2;
   ```

⚠️ **Important**: Always keep these two files in sync!

## Version Usage in Code

### Displaying Version to User

```dart
import '../utils/constants.dart';

Text('Version $appVersion (Build $appBuildNumber)')
```

### Checking Version Programmatically

```dart
import '../utils/constants.dart';

if (appVersion == '1.0.0') {
  // Version-specific logic
}
```

## Android Version Mapping

Android build.gradle.kts automatically reads from pubspec.yaml:

- `versionName` ← `appVersion` (1.0.0)
- `versionCode` ← `appBuildNumber` (1)

This is handled by Flutter's Gradle plugin:
```kotlin
versionCode = flutter.versionCode
versionName = flutter.versionName
```

## Files Affected

- **lib/utils/constants.dart** - App version constants
- **pubspec.yaml** - Build configuration
- **lib/screens/about_screen.dart** - Displays version to user
- **android/app/build.gradle.kts** - Android native version (reads from pubspec.yaml)

## Release Workflow

1. **Update version**:
   ```bash
   ./scripts/update_version.sh 1.1.0 2
   ```

2. **Commit changes**:
   ```bash
   git add pubspec.yaml lib/utils/constants.dart
   git commit -m "chore: bump version to 1.1.0+2"
   ```

3. **Create git tag**:
   ```bash
   git tag -a v1.1.0 -m "Release 1.1.0"
   ```

4. **Push with tags**:
   ```bash
   git push origin main --tags
   ```

5. **Build release**:
   ```bash
   flutter build appbundle --release
   # or
   flutter build apk --release
   ```

## CI/CD Integration

The version script can be integrated into CI/CD pipelines:

```yaml
# Example Jenkins/GitHub Actions
steps:
  - name: Update Version
    run: |
      chmod +x scripts/update_version.sh
      ./scripts/update_version.sh ${{ env.VERSION }} ${{ env.BUILD_NUMBER }}
      
  - name: Build App
    run: flutter build appbundle --release
```

## Best Practices

1. **Increment build number** for every release to Play Store/App Store
2. **Use semantic versioning** for meaningful version numbers
3. **Tag releases** in git for version history
4. **Never reuse build numbers** - they must be unique and increasing
5. **Update version before building** release artifacts
6. **Keep version files in sync** - use the automated script

## Common Pitfalls

❌ **Don't** hardcode version strings throughout the app
❌ **Don't** forget to update build number for new releases
❌ **Don't** edit Android version directly (it reads from pubspec.yaml)
❌ **Don't** commit version bumps without tagging

✅ **Do** use the centralized constants
✅ **Do** increment build number for every release
✅ **Do** use the automated script
✅ **Do** tag releases in git

## Version History

- **1.0.0+1** (2026-02-05) - Initial release with centralized version management

## Future Enhancements

- Automated version increment in CI/CD
- Changelog generation from git commits
- Beta/RC version suffixes support
- Automatic Play Store version validation
