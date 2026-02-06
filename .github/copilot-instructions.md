# GitHub Copilot Instructions

**🚨 CRITICAL**: Before making ANY code changes, read [DOCUMENTATION-MANDATE.md](copilot-instructions/DOCUMENTATION-MANDATE.md). **All code changes MUST be documented immediately.**

## Project-Specific Guidelines

### Form Screen Consistency

**CRITICAL**: The Add Machine and Edit Machine screens must maintain identical field structures.

When modifying either `add_machine_screen.dart` or `edit_machine_screen.dart`, **ALWAYS** update both files to ensure they remain synchronized.

#### Required Field Consistency Checklist:

1. **Machine Type Selector**
   - Must have 4 types: Vehicle, Motorcycle, Generator, Machine
   - Each type must have an icon: `directions_car`, `motorcycle`, `power`, `precision_manufacturing`
   - Use `FilterChip` with icons (not `ChoiceChip` without icons)
   - Auto-switch odometer unit: Generator/Machine → hours, Vehicle/Motorcycle → km

2. **Field Order** (must be identical):
   1. Image Picker
   2. Machine Type
   3. Brand (required)
   4. Model (required)
   5. Nickname (optional)
   6. Year (optional)
   7. Serial Number (optional)
   8. Spark Plug Type (optional)
   9. Oil Type (optional)
   10. Fuel Type (optional)
   11. Current Odometer (required)
   12. Tank Size (optional)

3. **Field Properties** (must match exactly):
   - **Icons**: 
     - Brand: `Icons.business`
     - Model: `Icons.motorcycle`
     - Nickname: `Icons.label`
     - Year: `Icons.calendar_today`
     - Serial Number: `Icons.numbers`
     - Spark Plug: `Icons.electrical_services`
     - Oil Type: `Icons.water_drop`
     - Fuel Type: `Icons.local_gas_station`
     - Odometer: `Icons.speed`
     - Tank Size: `Icons.local_gas_station`
   
   - **Hints**:
     - Brand: `'e.g., Suzuki, Honda, Yamaha'`
     - Model: `'e.g., Intruder 125, CG 160'`
     - Nickname: `'e.g., My Bike, Work Car'`
     - Year: `'e.g., 2008'`
     - Serial Number: `'VIN or chassis number'`
     - Spark Plug: `'e.g., NGK CR7HSA'`
     - Oil Type: `'e.g., 10W-40, 20W-50'`
     - Fuel Type: `'e.g., Gasoline, Diesel, Ethanol'`
     - Odometer: `'0'`
     - Tank Size: `'e.g., 10.0'`
   
   - **Validators**: Use identical error messages
     - Brand: `'Brand is required'`
     - Model: `'Model is required'`
     - Odometer: `'Odometer is required'` and `'Enter a valid number'`

4. **Input Formatters** (must be identical):
   - Year: digits only, max 4 characters
   - Odometer: decimal with max 2 decimal places
   - Tank Size: decimal with max 2 decimal places

5. **Odometer Input Structure**:
   - Must use `Row` with TextField (flex: 2) + DropdownButton (flex: 1)
   - Dropdown options: `odometerUnitKm` and `odometerUnitHours`
   - Combined in single `_buildOdometerInput()` method

6. **Text Capitalization**:
   - Brand, Model, Nickname, Fuel Type: `TextCapitalization.words`
   - Serial Number, Spark Plug, Oil Type: `TextCapitalization.characters`

### When Making Changes:

1. **Before editing**: Read both files completely
2. **After editing**: Verify both files match the checklist above
3. **Test**: Ensure both screens render identically
4. **Document**: Note any intentional differences with clear justification

### Constants Usage:

Always import and use constants from `lib/utils/constants.dart`:
- **App Version**: `appVersion`, `appBuildNumber` (centralized version management)
- **Machine Types**: `machineTypeVehicle`, `machineTypeMotorcycle`, `machineTypeGenerator`, `machineTypeMachine`
- **Odometer Units**: `odometerUnitKm`, `odometerUnitHours`

### Version Management

**App version is centralized** in `lib/utils/constants.dart` and `pubspec.yaml`.

To update version:
```bash
./scripts/update_version.sh 1.1.0 2  # version + build number
```

This automatically updates both files. See [version-management.md](copilot-instructions/version-management.md) for details.

### Import Order:

Both screens should have the same import structure:
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/machine.dart';
import '../services/machine_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
```
## Notification System Architecture

### Database Structure

**Current Version**: 4

#### Version History:
- **v1**: Initial schema (machines, maintenance_records, maintenance_intervals)
- **v2**: Added `fuelType` to machines, `fuelAmount` to maintenance_records
- **v3**: Added `notifications` table
- **v4**: Added `notificationSent` flag to maintenance_intervals

#### Notifications Table Schema:
```sql
CREATE TABLE notifications(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  machineId INTEGER,  -- NULL for test notifications
  createdAt TEXT NOT NULL,
  isRead INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (machineId) REFERENCES machines (id) ON DELETE CASCADE
)
```

#### Maintenance Intervals Table Schema:
```sql
CREATE TABLE maintenance_intervals(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  machineId INTEGER NOT NULL,
  maintenanceType TEXT NOT NULL,
  intervalDistance REAL,
  intervalDays INTEGER,
  enabled INTEGER NOT NULL DEFAULT 1,
  notificationSent INTEGER NOT NULL DEFAULT 0,  -- Prevents duplicate notifications
  FOREIGN KEY (machineId) REFERENCES machines (id) ON DELETE CASCADE,
  UNIQUE(machineId, maintenanceType)
)
```

### Notification Flow

**IMPORTANT**: Notifications are handled by THREE separate but coordinated systems:

1. **NotificationService** (`lib/services/notification_service.dart`)
   - Handles Android system notifications (push alerts)
   - Schedules exact alarms for maintenance reminders
   - Parameters: `saveToDb` - set to `false` when called from NotificationProvider (avoids duplicates)

2. **NotificationProvider** (`lib/services/notification_provider.dart`)
   - Manages notification history in database
   - State management for UI (unread count, list updates)
   - Method `addNotification()` - saves to DB AND triggers push notification
   - Used by UI components to display notification history

3. **BackgroundService** (`lib/services/background_service.dart`)
   - WorkManager integration for background checks
   - Periodic maintenance status checks (every 6 hours)
   - Boot receiver integration for post-restart rescheduling
   - Ensures notifications work even when app is closed

### Notification Triggers

Notifications are checked/scheduled at:
1. **App startup** (`main.dart`) - immediate check via `triggerImmediateCheck()`
2. **Home screen load** (`home_screen.dart`) - `rescheduleAllNotifications()`
3. **Machine added/updated** (`machine_provider.dart`) - `_scheduleNotificationsForMachine()`
4. **Maintenance logged** (`machine_provider.dart`) - automatic reschedule
5. **Intervals changed** (`machine_provider.dart`) - `saveMaintenanceInterval()`
6. **Device boot** (Android boot receiver) - WorkManager auto-reschedule
7. **Periodic background** (WorkManager) - every 6 hours

### Best Practices for Notifications

**When modifying notification behavior:**

1. **Avoid double-saving**: 
   - If calling `NotificationService.showNotification()` from `NotificationProvider`, set `saveToDb: false`
   - If calling directly (e.g., from scheduled tasks), set `saveToDb: true`

2. **Status-based scheduling**:
   - **Overdue**: Send immediately + save to history
   - **Check Soon**: Schedule for future + save to history

3. **Notification sent flag**:
   - Check `notificationSent` flag before sending notifications (prevents duplicates)
   - Set flag to `true` after sending notification
   - Reset flag to `false` when maintenance is logged and status returns to optimal
   - Methods: `resetNotificationSentFlag()`, `resetNotificationFlagsForOkIntervals()`

4. **Reschedule after changes**:
   - Always call `_scheduleNotificationsForMachine()` after updating machine/maintenance data
   - Cancel old notifications before rescheduling to prevent duplicates

5. **Database migrations**:
   - ALWAYS increment version number in `database_service.dart`
   - Add migration logic in `_onUpgrade()` method
   - Test both fresh install (onCreate) and upgrade paths

### Theme Constants

**IMPORTANT**: Use correct theme constant names from `lib/utils/app_theme.dart`:

- ✅ `AppTheme.primaryBackground` (NOT `darkBackground`)
- ✅ `AppTheme.cardBackground` (NOT `cardColor`)
- ✅ `AppTheme.textAccent` (NOT `primaryBlue`)
- ✅ `AppTheme.accentBlue`
- ✅ `AppTheme.statusOptimal`, `statusWarning`, `statusOverdue`
- ✅ `AppTheme.textPrimary`, `textSecondary`

### Navigation Patterns

**MachineDetailScreen**: Always navigate with `machineId` parameter:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MachineDetailScreen(machineId: machine.id),
  ),
);
```

**NOT** with `machine` object (outdated pattern).

### Critical Dependencies

- `workmanager: ^0.9.0` - Background task execution
- `flutter_local_notifications: ^17.0.0` - System notifications
- `sqflite: ^2.3.0` - Local database
- `file_picker: ^8.0.0+1` - File selection for database import
- `path_provider: ^2.1.1` - Access to system directories

### Android Permissions Required

Notifications require these permissions in `AndroidManifest.xml`:
- `POST_NOTIFICATIONS` - Show notifications (Android 13+)
- `SCHEDULE_EXACT_ALARM` - Precise scheduling
- `RECEIVE_BOOT_COMPLETED` - Post-restart rescheduling
- `FOREGROUND_SERVICE` - Background reliability
- `FOREGROUND_SERVICE_DATA_SYNC` - Background work
- `WAKE_LOCK` - Wake device for notifications
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` - Battery saver exemption