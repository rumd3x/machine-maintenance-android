# Android SDK Setup Guide

## ✅ Setup Complete!

Your development environment is now configured to build Android APKs with Flutter.

## What Was Installed

### 1. Java Development Kit (JDK)
- **Version**: OpenJDK 17.0.18
- **Location**: `/usr/lib/jvm/java-17-openjdk-amd64`
- **Purpose**: Required to run Android SDK tools

### 2. Android SDK
- **Location**: `$HOME/Android/Sdk` (`/home/edmur/Android/Sdk`)
- **Platform**: Android 36 (latest)
- **Build Tools**: 34.0.0 and 28.0.3
- **Platform Tools**: Latest (includes adb, fastboot)
- **Command Line Tools**: Version 20.0

### 3. Environment Variables
Added to `~/.bashrc`:
```bash
# Android SDK and Java (added for Flutter development)
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
```

## Verification

Run `flutter doctor -v` to verify everything is set up:

```bash
[✓] Flutter (Channel stable, 3.38.9)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
    • Android SDK at /home/edmur/Android/Sdk
    • Platform android-36, build-tools 34.0.0
    • Java version OpenJDK Runtime Environment (build 17.0.18+8)
    • All Android licenses accepted.
```

## Building Your APK

### Release Build (Production)
```bash
cd /mnt/NAS/Projetos/machine-maintenance-android
flutter build apk --release
```

APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

### Debug Build (Development)
```bash
flutter build apk --debug
```

### Split APKs by Architecture (Smaller files)
```bash
flutter build apk --split-per-abi
```

This generates separate APKs:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (Intel 64-bit)

## Installing APK on Device

### Via USB (ADB)
```bash
# Enable USB debugging on your Android device first
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Via File Transfer
1. Copy `app-release.apk` to your phone
2. Open the file on your phone
3. Allow "Install from unknown sources" if prompted
4. Install the app

## Useful Commands

### Check connected devices
```bash
adb devices
```

### View app logs
```bash
flutter logs
```

### Clean build
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Update SDK components
```bash
sdkmanager --update
```

### List installed SDK packages
```bash
sdkmanager --list_installed
```

## Troubleshooting

### If environment variables don't persist
Add them to your shell config:
```bash
nano ~/.bashrc
# Add the export commands, then save
source ~/.bashrc
```

### If Flutter doesn't find SDK
```bash
flutter config --android-sdk "$HOME/Android/Sdk"
```

### If Java version issues
```bash
# Check Java version
java -version

# If wrong version, set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

### Clear Gradle cache
```bash
cd android
./gradlew clean
cd ..
flutter clean
```

## Project-Specific Build

For the Machine Maintenance app:
```bash
cd /mnt/NAS/Projetos/machine-maintenance-android
flutter pub get
flutter build apk --release
```

Your APK will be at:
`build/app/outputs/flutter-apk/app-release.apk`

## Next Steps

1. ✅ Environment configured
2. ✅ APK building...
3. Test APK on physical Android device
4. Verify notification permissions work
5. Test all features in production build

## Notes

- The setup uses command-line tools only (no Android Studio required)
- All Android licenses have been accepted
- SDK packages can be updated with `sdkmanager --update`
- Build times: First build ~3-5 minutes, subsequent builds ~1-2 minutes
- APK size: ~20-30 MB (release build)

## Installed SDK Packages

- `platforms;android-36` - Android 36 platform
- `build-tools;34.0.0` - Build tools for compiling
- `build-tools;28.0.3` - Additional build tools (Flutter requirement)
- `platform-tools` - ADB and fastboot
- `cmdline-tools;latest` - SDK manager and tools
