# Database Backup and Restore

**Date**: 5 de fevereiro de 2026

## Overview

The app provides database export/import functionality to allow users to manually backup and restore their maintenance data. This is critical for data preservation when changing devices or reinstalling the app.

## Implementation

### Export Functionality

**Location**: `lib/services/database_service.dart` - `exportDatabase()`

**Process**:
1. Closes current database connection safely
2. Copies database file to user-accessible location (Downloads folder)
3. Creates timestamped backup filename: `machine_maintenance_backup_YYYY-MM-DDTHH-MM-SS.db`
4. Automatically reopens database after export
5. Returns exported file path on success

**Export Directory**:
- **Android**: `/storage/emulated/0/Download/` (user-accessible Downloads folder)
- **Other platforms**: Application documents directory as fallback

**Error Handling**:
- Ensures database is always reopened, even if export fails
- Shows user-friendly error messages via SnackBar

### Import Functionality

**Location**: `lib/services/database_service.dart` - `importDatabase()`

**Process**:
1. Validates selected file is a valid SQLite database (read-only test)
2. Shows confirmation dialog warning user about data replacement
3. Closes current database connection
4. Creates backup of current database (`.backup` extension)
5. **Deletes current database file** (prevents table conflicts)
6. Copies import file to database location
7. Reopens database (applies any necessary migrations)

**Critical**: The current database MUST be deleted before copying the import file to prevent "table already exists" errors during migration.

**Error Handling**:
- Attempts to restore from backup if import fails
- Ensures database is always reopened
- Shows user-friendly error messages via SnackBar

### UI Integration

**Location**: `lib/screens/about_screen.dart`

**Data Management Section**:
- Located between app description and credits
- Two side-by-side buttons:
  - **Export Button**: Blue, upload icon, shows "Exporting..." with loading spinner
  - **Import Button**: Green, download icon, shows "Importing..." with loading spinner
- Buttons disabled during operations to prevent concurrent access
- Success messages show exported filename or import success
- Error messages displayed for any failures

**User Flow**:
1. User navigates to About screen
2. Taps Export → Database saved to Downloads with timestamp
3. User can share/backup the `.db` file
4. To restore: Tap Import → Select `.db` file → Confirm warning → Data restored

### Database Service Methods

```dart
// Export database to specified directory
Future<String?> exportDatabase(String exportPath)

// Import database from file path
Future<bool> importDatabase(String importFilePath)

// Get current database file path
Future<String> getDatabasePath()
```

### Database Backup Methods

```dart
// Reset notification flag for specific maintenance interval
Future<int> resetNotificationSentFlag(int machineId, String maintenanceType)

// Reset notification flags for multiple intervals
Future<void> resetNotificationFlagsForOkIntervals(
  int machineId,
  List<String> okMaintenanceTypes,
)
```

## Dependencies

- `file_picker: ^8.0.0+1` - File selection dialog for import
- `path_provider: ^2.1.1` - Access to system directories
- `dart:io` - File system operations

## User Experience

**Export Success**:
```
"Database exported to:
machine_maintenance_backup_2026-02-05T14-30-00.db"
```

**Import Warning**:
```
"This will replace all your current data with the imported backup.
This action cannot be undone.

Do you want to continue?"
```

**Import Success**:
```
"Database imported successfully! Please restart the app."
```

## Best Practices

1. **Always backup before import**: The import process creates an automatic backup
2. **Delete old database**: Must delete current database to prevent migration conflicts
3. **Validate before import**: Open imported file in read-only mode to verify it's valid SQLite
4. **Error recovery**: Restore from backup if import fails
5. **User confirmation**: Always show warning dialog before destructive operations

## File Naming Convention

Export files use ISO 8601 timestamp format with colons replaced:
- Pattern: `machine_maintenance_backup_YYYY-MM-DDTHH-MM-SS.db`
- Example: `machine_maintenance_backup_2026-02-05T14-30-00.db`

## Future Enhancements

- Automatic cloud backup integration
- Scheduled automatic backups
- Backup encryption
- Backup verification/integrity checks
- Backup compression
