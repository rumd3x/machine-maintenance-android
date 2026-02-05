# Flutter Project Setup

**Date**: 4 de fevereiro de 2026

## Project Initialization

### Create Flutter Project
```bash
flutter create --org com.machinemaintenance --project-name machine_maintenance machine-maintenance-android
```

### Project Structure
```
machine-maintenance-android/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── screens/
│   ├── widgets/
│   ├── services/
│   └── utils/
├── assets/
│   └── images/
├── test/
├── android/
├── pubspec.yaml
└── README.md
```

## Required Dependencies

### Core Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Local Database
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  path: ^1.8.3
  
  # Image Handling
  image_picker: ^1.0.5
  
  # State Management
  provider: ^6.1.1
  
  # Date/Time
  intl: ^0.18.1
  
  # Simple Storage
  shared_preferences: ^2.2.2
```

## Jenkins Build Configuration

### Jenkinsfile
```groovy
pipeline {
    agent any
    
    environment {
        FLUTTER_HOME = '/path/to/flutter'
        PATH = "${FLUTTER_HOME}/bin:${env.PATH}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Flutter Doctor') {
            steps {
                sh 'flutter doctor -v'
            }
        }
        
        stage('Get Dependencies') {
            steps {
                sh 'flutter pub get'
            }
        }
        
        stage('Run Tests') {
            steps {
                sh 'flutter test'
            }
        }
        
        stage('Build APK') {
            steps {
                sh 'flutter build apk --release'
            }
        }
        
        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk', fingerprint: true
            }
        }
    }
}
```

## Development Setup

### Prerequisites
- Flutter SDK (latest stable)
- Android SDK
- Android Studio or VS Code with Flutter extensions

### Commands
```bash
# Get dependencies
flutter pub get

# Run app in debug mode
flutter run

# Build APK
flutter build apk --release

# Run tests
flutter test

# Analyze code
flutter analyze
```
