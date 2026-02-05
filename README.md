# Machine Maintenance Tracker

A local, offline-first Flutter application for tracking vehicle and machine maintenance.

## Features

- 🔧 Track multiple vehicles and machines (motorcycles, cars, generators, etc.)
- 📱 100% local storage - no cloud connection required
- 🔔 Maintenance reminders based on time or distance/hours
- 📊 Overview dashboard with status indicators
- 📝 Detailed maintenance history logging
- 📷 Photo storage for each machine

## Tech Stack

- **Framework**: Flutter 3.38.9
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **Platform**: Android

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   ├── machine.dart
│   ├── maintenance_record.dart
│   ├── maintenance_interval.dart
│   └── maintenance_status.dart
├── screens/               # UI screens
├── widgets/               # Reusable widgets
├── services/              # Business logic & services
│   └── database_service.dart
└── utils/                 # Utility functions
```

## Getting Started

### Prerequisites

- Flutter SDK 3.38.9 or higher
- Android SDK
- Dart 3.10.8 or higher

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building APK

```bash
flutter build apk --release
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

## Jenkins CI/CD

This project includes a `Jenkinsfile` for automated builds. See `.github/copilot-instructions/flutter-setup.md` for Jenkins configuration details.

## Documentation

All project requirements and instructions are documented in the `.github/copilot-instructions/` folder.

## License

Private project - All rights reserved
