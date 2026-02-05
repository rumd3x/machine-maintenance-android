# Technical Architecture

**Date**: 4 de fevereiro de 2026

## Platform
- **Target**: Android
- **Framework**: Flutter

## Framework Choice: Flutter
**Decision Date**: 4 de fevereiro de 2026

### Rationale
- Fast development with hot reload
- Excellent UI capabilities for custom designs
- Good local storage options (sqflite, hive)
- Jenkins-compatible build process
- Strong community and package ecosystem
- Cross-platform potential for future expansion

### Storage
- **Database**: sqflite (SQLite for Flutter)
- **File Storage**: Local filesystem for images (path_provider)
- **No Cloud**: Zero network dependencies for core functionality

### Key Flutter Packages
- `sqflite` - Local SQLite database
- `path_provider` - Access to filesystem directories
- `image_picker` - Camera/gallery image selection
- `shared_preferences` - Simple key-value storage
- `intl` - Date formatting and internationalization

## Build System
- **CI/CD**: Jenkins pipeline
- **Output**: APK (and potentially AAB for Play Store)
- **Build Command**: `flutter build apk --release`

## Architecture Pattern
- **Suggested**: MVVM (Model-View-ViewModel) or Clean Architecture
- Clear separation between:
  - Data layer (local storage)
  - Business logic (maintenance calculations)
  - UI layer (views and components)

## Key Technical Requirements
1. Efficient local data persistence
2. Image handling and compression
3. Date/time calculations for maintenance intervals
4. Notifications/reminders system (future consideration)
5. Data export/backup capability (future consideration)
