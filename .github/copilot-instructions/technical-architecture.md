# Technical Architecture

**Date**: 9 de fevereiro de 2026

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
4. Notifications/reminders system (✅ Implemented)
5. Data export/backup capability (✅ Implemented)

## Current Implementation Status

### Database
- **SQLite Database Version**: 8
- **Migration Strategy**: Progressive version upgrades with backward compatibility
- **Tables**: machines, maintenance_records, maintenance_intervals, notifications
- **Features**: 
  - Comprehensive machine specifications tracking (20 fields)
  - Full maintenance history with 13 maintenance types
  - Configurable maintenance intervals
  - Notification history with read/unread status
  - Database backup/restore functionality

### Notifications System
- **WorkManager**: Background task execution every 6 hours
- **flutter_local_notifications**: Push notifications on Android
- **Scheduling**: Exact alarm permissions for precise maintenance reminders
- **Duplicate Prevention**: Notification sent flag system

### State Management
- **Pattern**: Provider pattern
- **Key Providers**: 
  - MachineProvider - Machine and maintenance CRUD operations
  - NotificationProvider - Notification history management

### Build & Deployment
- **Jenkins Pipeline**: Automated releases with version management
- **Android Signing**: Keystore-based release signing
- **Play Store**: Optional automated publishing to Google Play
- **GitHub Releases**: Automated release creation with APK artifacts
