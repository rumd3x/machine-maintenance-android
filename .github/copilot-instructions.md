# GitHub Copilot Instructions

**🚨 CRITICAL**: Before making ANY code changes, read [DOCUMENTATION-MANDATE.md](copilot-instructions/DOCUMENTATION-MANDATE.md). **All code changes MUST be documented immediately.**

## 🔴 MANDATORY DOCUMENTATION WORKFLOW

### BEFORE Making Code Changes:
1. **Check `.github/copilot-instructions/` folder** for relevant documentation files
2. **Read** the following files to understand current state:
   - `progress.md` - Recent changes and current status
   - `data-model.md` - Database schema and entity structure
   - `features.md` - Feature specifications
   - `technical-architecture.md` - Architecture decisions
   - Any other relevant topic-specific files
3. **Understand** existing patterns and conventions before implementing changes

### DURING Code Changes:
1. **Note** all changes being made (files, features, patterns)
2. **Track** which documentation files need updates
3. **Follow** existing patterns and conventions from documentation

### AFTER Making Code Changes:
1. **Update** this file (`copilot-instructions.md`) with:
   - New features and their usage patterns
   - Changed patterns or conventions
   - Important gotchas or warnings
   - Database version changes
   - New dependencies or configurations

2. **Update** relevant files in `.github/copilot-instructions/`:
   - `progress.md` - Add session summary with date
   - `data-model.md` - Update if database schema changed
   - `features.md` - Update if features added/changed
   - `ui-design.md` - Update if UI patterns changed
   - `technical-architecture.md` - Update if architecture changed

3. **Document**:
   - New features: Feature description, location, usage patterns, gotchas
   - Bug fixes: What was broken, how it was fixed, correct pattern going forward
   - Architecture changes: New approach, why it changed, migration notes
   - UI/UX changes: Pattern, component usage, styling guidelines
   - Database changes: Version number, migration, new fields/tables

### Documentation Standards:
- **ALWAYS** include date at top of documentation files
- **ALWAYS** increment database version number when schema changes
- **NEVER** leave a conversation without updating documentation
- **NEVER** create markdown files in project root (except README.md)

### Quick Checklist:
Before ending any conversation, ask yourself:
- [ ] Did I update `copilot-instructions.md` with new patterns?
- [ ] Did I update `progress.md` with today's session?
- [ ] Did I update relevant topic files (data-model, features, etc.)?
- [ ] Did I document database version changes?
- [ ] Did I document any new dependencies?

**Remember: Future AI assistants rely on this documentation to understand the codebase. Poor documentation leads to broken patterns and bugs.**

### Documentation File Placement

**NEVER create summary or documentation markdown files in the project root directory.**

All documentation MUST be placed in `.github/copilot-instructions/` directory:
- ✅ `.github/copilot-instructions/feature-name.md` - Feature documentation
- ✅ `.github/copilot-instructions/progress.md` - Session summaries
- ❌ `ROOT/SETUP_COMPLETE.md` - Never in root
- ❌ `ROOT/FEATURE_IMPLEMENTATION.md` - Never in root

**Exception**: `README.md` is the ONLY markdown file allowed in root.

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

2. **Conditional Field Visibility**
   - **Tire fields** (Front/Rear Size and Pressure): Only visible when type is Vehicle or Motorcycle
   - Condition: `if (_selectedType == machineTypeVehicle || _selectedType == machineTypeMotorcycle)`
   - Hidden for Generator and Machine types as they don't have tires

3. **Field Order** (must be identical):
   1. Image Picker
   2. Machine Type
   3. Brand (required)
   4. Model (required)
   5. Nickname (optional)
   6. Year (optional)
   7. Serial Number (optional)
   8. Spark Plug Type (optional)
   9. Spark Plug Gap (mm) (optional)
   10. Oil Type (optional)
   11. Oil Capacity (optional)
   12. Fuel Type (optional)
   13. Front Tires Size (optional)
   14. Rear Tires Size (optional)
   15. Front Tire Pressure (PSI) (optional)
   16. Rear Tire Pressure (PSI) (optional)
   17. Battery Voltage (V) (optional)
   18. Battery Capacity (Ah) (optional)
   19. Battery Type/Model (optional)
   20. Tank Size (optional)
   21. Current Odometer (required)

3. **Field Properties** (must match exactly):
   - **Icons**: 
     - Brand: `Icons.business`
     - Model: `Icons.motorcycle`
     - Nickname: `Icons.label`
     - Year: `Icons.calendar_today`
     - Serial Number: `Icons.numbers`
     - Spark Plug Type: `Icons.electrical_services`
     - Spark Plug Gap: `Icons.electrical_services`
     - Oil Type: `Icons.water_drop`
     - Oil Capacity: `Icons.water_drop`
     - Fuel Type: `Icons.local_gas_station`
     - Front Tires Size: `Icons.circle_outlined`
     - Rear Tires Size: `Icons.circle_outlined`
     - Front Tire Pressure: `Icons.speed`
     - Rear Tire Pressure: `Icons.speed`
     - Battery Voltage: `Icons.battery_charging_full`
     - Battery Capacity: `Icons.battery_std`
     - Battery Type: `Icons.battery_full`
     - Tank Size: `Icons.local_gas_station`
     - Odometer: `Icons.speed`
   
   - **Hints**:
     - Brand: `'e.g., Suzuki, Honda, Yamaha'`
     - Model: `'e.g., Intruder 125, CG 160'`
     - Nickname: `'e.g., My Bike, Work Car'`
     - Year: `'e.g., 2008'`
     - Serial Number: `'VIN or chassis number'`
     - Spark Plug Type: `'e.g., NGK CR7HSA'`
     - Spark Plug Gap: `'e.g., 0.8, 0.7-0.9'`
     - Oil Type: `'e.g., 10W-40, 20W-50'`
     - Oil Capacity: `'e.g., 1.2L, 4 Liters'`
     - Fuel Type: `'e.g., Gasoline, Diesel, Ethanol'`
     - Front Tires Size: `'e.g., 205/55 R16'`
     - Rear Tires Size: `'e.g., 225/50 R17'`
     - Front Tire Pressure: `'e.g., 32, 30-32'`
     - Rear Tire Pressure: `'e.g., 36, 34-36'`
     - Battery Voltage: `'e.g., 12, 12.6'`
     - Battery Capacity: `'e.g., 50, 100'`
     - Battery Type: `'e.g., HTZ7L, YTX9-BS'`
     - Tank Size: `'e.g., 10.0'`
     - Odometer: `'0'`
   
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
   - Serial Number, Spark Plug, Oil Type, Battery Type: `TextCapitalization.characters`

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

**Current Version**: 9

#### Version History:
- **v1**: Initial schema (machines, maintenance_records, maintenance_intervals)
- **v2**: Added `fuelType` to machines, `fuelAmount` to maintenance_records
- **v3**: Added `notifications` table
- **v4**: Added `notificationSent` flag to maintenance_intervals
- **v5**: Added `oilCapacity`, `frontTiresSize`, `rearTiresSize` to machines
- **v6**: Added `frontTirePressure`, `rearTirePressure` to machines
- **v7**: Added `batteryVoltage`, `batteryCapacity` to machines
- **v8**: (skipped - version number error)
- **v9**: Added `batteryType` to machines

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
   - **CRITICAL**: Reset flag when status is NOT overdue (optimal OR checkSoon)
   - This allows yellow→red transitions to notify properly
   - For new machines: Default intervals created with `notificationSent: true` to prevent immediate notifications
   - Methods: `resetNotificationSentFlag()`, `resetNotificationFlagsForOkIntervals()`
   
   **Notification Logic**:
   - CheckSoon (yellow): Resets flag when encountered, schedules notification, sets flag
   - Overdue (red): Always checks if should notify (ignores flag from checkSoon cycle)
   - Uses notification history to prevent duplicate overdue notifications (24h window)
   - New machines: No notifications until first status change (flag preset)
   - Yellow→Yellow: No duplicate (flag already set)
   - Yellow→Red: Notifies (flag reset during yellow phase)
   - Red→Red: No duplicate (history check prevents)
   - Service logged: Resets flag for non-overdue statuses

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

### Machine Detail Screen UI Patterns

**Action Buttons**: Use `OutlinedButton.icon` for section actions (not dim TextButton):
```dart
OutlinedButton.icon(
  onPressed: () => {},
  icon: const Icon(Icons.list, size: 16),
  label: const Text('View All'),
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  ),
)
```

**Interactive Status Indicators**: Wrap `StatusIndicator` in `GestureDetector` for tap actions:
```dart
GestureDetector(
  onTap: () => _addMaintenance(preselectType: maintenanceType),
  child: StatusIndicator(...),
)
```

**Preselected Dialogs**: Support optional preselection in maintenance dialogs:
- `_AddMaintenanceDialog` accepts `initialType` parameter
- Allows clicking status circles to open dialog with that type preselected

### CI/CD Pipeline

**Jenkins pipeline** automates releases with Docker:
- Runs on `docker` node using `cirrusci/flutter:stable` image
- Parameterized builds: `patch`, `minor`, `major`
- **Release notes** support with text field (included in GitHub and Play Store)
- **Play Store publishing** with checkbox to enable/disable
- Automatically increments version and build number
- Builds release APK and AAB (App Bundle)
- Commits version, creates git tag
- Publishes GitHub release with APK attachment
- Optionally publishes to Play Store internal testing track

**Pipeline stages**: Checkout → Setup Android Signing → Calculate Version → Update Version → Dependencies → Build APK → Build AAB (optional) → Commit → Tag → Push → GitHub Release → Play Store Publish (optional) → Archive

**Pipeline parameters**:
- `RELEASE_TYPE`: Version increment type (patch/minor/major)
- `RELEASE_NOTES`: Multiline text for release notes (optional)
- `PUBLISH_TO_PLAY_STORE`: Boolean to enable Play Store publishing
- `PLAY_STORE_TRACK`: Release track selection (production/internal/beta/alpha)

See [ci-cd-pipeline.md](copilot-instructions/ci-cd-pipeline.md) for complete pipeline documentation.
See [play-store-publishing.md](copilot-instructions/play-store-publishing.md) for Play Store setup guide.

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

## Machine Properties

### Core Properties
- `brand`, `model`: Required identification
- `nickname`: Optional user-friendly name
- `type`: Vehicle, Motorcycle, Generator, Machine
- `year`, `serialNumber`: Optional metadata
- `currentOdometer`, `odometerUnit`: Required tracking (km or hours)

### Specifications
- `sparkPlugType`: e.g., "NGK CR7HSA"
- `sparkPlugGap`: e.g., "0.8", "0.7-0.9" (in mm)
- `oilType`: e.g., "10W-40", "20W-50"
- `oilCapacity`: e.g., "1.2L", "4 Liters"
- `fuelType`: e.g., "Gasoline", "Diesel", "Ethanol"
- `tankSize`: Numeric value in liters
- `frontTiresSize`: e.g., "205/55 R16"
- `rearTiresSize`: e.g., "225/50 R17"
- `frontTirePressure`: e.g., "32", "30-32" (in PSI)
- `rearTirePressure`: e.g., "36", "34-36" (in PSI)
- `batteryVoltage`: e.g., "12", "12.6" (in Volts)
- `batteryCapacity`: e.g., "50", "100" (in Amp-hours)
- `batteryType`: e.g., "HTZ7L", "YTX9-BS" (battery model/type)
- `imagePath`: Optional photo path

## Maintenance Types

### Available Maintenance Types

Defined in `lib/utils/constants.dart`:

1. **Oil Change** (`maintenanceTypeOilChange`) - Icon: `Icons.water_drop`
2. **Filter Cleaning** (`maintenanceTypeFilterCleaning`) - Icon: `Icons.filter_alt`
3. **Chain Oiling** (`maintenanceTypeChainOiling`) - Icon: `Icons.link`
4. **Brake Fluid** (`maintenanceTypeBrakeFluid`) - Icon: `Icons.car_repair`
5. **Coolant** (`maintenanceTypeCoolant`) - Icon: `Icons.ac_unit`
6. **Spark Plug** (`maintenanceTypeSparkPlug`) - Icon: `Icons.electrical_services`
7. **Brake Inspection** (`maintenanceTypeBrakeInspection`) - Icon: `Icons.car_repair`
8. **General Service** (`maintenanceTypeGeneral`) - Icon: `Icons.build`
9. **Fuel** (`maintenanceTypeFuel`) - Icon: `Icons.local_gas_station`
10. **Front Tires** (`maintenanceTypeFrontTires`) - Icon: `Icons.trip_origin`
11. **Rear Tires** (`maintenanceTypeRearTires`) - Icon: `Icons.trip_origin`
12. **Belts/Chains** (`maintenanceTypeBeltsChains`) - Icon: `Icons.settings_input_component`
13. **Battery** (`maintenanceTypeBattery`) - Icon: `Icons.battery_charging_full`

### Adding New Maintenance Types

1. Add constant to `lib/utils/constants.dart`
2. Add display name to `maintenanceTypeNames` map
3. Add icon case to `_getMaintenanceIcon()` in `machine_detail_screen.dart`
4. No database migration needed (maintenanceType is TEXT field)

## Recent Changes and Improvements

### Session: February 10, 2026 - Form Layout Improvements and Battery Type Field

#### Conditional Field Visibility
**Feature**: Tire fields now conditionally display based on machine type.

**Implementation**:
- Tire fields (Front/Rear Size and Pressure) only visible for Vehicle and Motorcycle types
- Hidden for Generator and Machine types (they don't have tires)
- Condition: `if (_selectedType == machineTypeVehicle || _selectedType == machineTypeMotorcycle)`
- Wrapped in spread operator collection for clean conditional rendering

**Files Modified**:
- [add_machine_screen.dart](lib/screens/add_machine_screen.dart) - Added conditional rendering for tire fields
- [edit_machine_screen.dart](lib/screens/edit_machine_screen.dart) - Added conditional rendering for tire fields

#### Form Layout Enhancements
**Changes**: Restructured machine form fields for better space efficiency and cleaner UI.

**Paired Field Layout**:
All related fields combined into 50/50 Row layouts using `Expanded(flex: 1)`:
- Tire size/pressure (front and rear)
- Spark plug type/gap
- Oil type/capacity  
- Fuel type/tank size
- Battery voltage/capacity

**Unit Display**:
Moved units from `labelText` to `suffixText` for cleaner input appearance:
- Spark plug gap: "mm"
- Oil capacity: "L"
- Tire pressure: "PSI"
- Battery voltage: "V"
- Battery capacity: "Ah"

**Field Reordering**:
- Moved odometer inputs above serial number field
- Added `const Divider()` after serial number for visual separation
- Improved logical flow and visual hierarchy

**Files Modified**:
- [add_machine_screen.dart](lib/screens/add_machine_screen.dart) - Updated all field layouts
- [edit_machine_screen.dart](lib/screens/edit_machine_screen.dart) - Matched layout changes

#### Battery Type/Model Field
**Feature**: Added new field to track battery model/type specifications.

**Implementation**:
- Property: `batteryType` (String?, e.g., "HTZ7L", "YTX9-BS")
- Database: Upgraded to version 9 with migration for batteryType column
- Forms: New input field with `Icons.battery_full`, text capitalization set to `characters`
- Detail screen: Displays in battery section before voltage/capacity

**Files Modified**:
- [machine.dart](lib/models/machine.dart) - Added batteryType property, toMap, fromMap, copyWith
- [database_service.dart](lib/services/database_service.dart) - Version 9 migration
- [add_machine_screen.dart](lib/screens/add_machine_screen.dart) - Added batteryType input field
- [edit_machine_screen.dart](lib/screens/edit_machine_screen.dart) - Added batteryType input with pre-fill
- [machine_detail_screen.dart](lib/screens/machine_detail_screen.dart) - Added batteryType display
- [machine_provider.dart](lib/services/machine_provider.dart) - Added batteryType to machine construction

#### Machine Detail Screen Improvements
**Changes**:
- Added "L" suffix to oil capacity display
- Compacted tire display from 4 lines to 2 lines
- Format: "Front: 205/55 R16 / 32 PSI"

**Files Modified**:
- [machine_detail_screen.dart](lib/screens/machine_detail_screen.dart)

#### Consistency Verification
**Completed**: Verified add_machine_screen.dart and edit_machine_screen.dart remain identical:
- All 21 form fields match between both screens
- Controllers, validators, hints, icons synchronized
- Field order consistent across both forms

### Session: February 2026 - Notification Fixes, UI Improvements, and New Features

#### Notification System Fixes
**Problem**: New machines triggered immediate notifications and yellow→red transitions didn't notify.

**Solutions**:
1. **Default intervals** now created with `notificationSent: true` (prevents immediate notifications)
2. **Flag reset logic** updated to reset when status is NOT overdue (optimal OR checkSoon)
3. **Duplicate prevention** added via 24-hour notification history check for overdue statuses

**Files Modified**:
- `lib/services/maintenance_calculator.dart` - Default intervals with flag preset
- `lib/services/notification_service.dart` - Flag reset for checkSoon, history checks
- `lib/services/machine_provider.dart` - Flag reset for non-overdue statuses after service logged

#### UI Improvements - Machine Detail Screen
**Changes**:
1. **Action buttons** changed from dim `TextButton` to styled `OutlinedButton.icon`
   - Added icons (Icons.settings for Configure, Icons.list for View All)
   - Better padding and visual hierarchy
2. **Status circles** made interactive with `GestureDetector`
   - Tapping circle opens service dialog preselected to that type
   - Better UX for quick maintenance logging

**Files Modified**:
- `lib/screens/machine_detail_screen.dart`

#### New Machine Properties
Added three optional String properties to track additional specifications:
- `oilCapacity`: e.g., "1.2L", "4 Liters"
- `frontTiresSize`: e.g., "205/55 R16"
- `rearTiresSize`: e.g., "225/50 R17"

**Database**: Upgraded to version 5 with migration to add columns
**Files Modified**:
- `lib/models/machine.dart` - Added properties to model
- `lib/services/database_service.dart` - Version 5 migration
- `lib/screens/add_machine_screen.dart` - Added form fields
- `lib/screens/edit_machine_screen.dart` - Added form fields

#### New Maintenance Types
Added three new maintenance types:
- `maintenanceTypeFrontTires` - Icon: `Icons.trip_origin`
- `maintenanceTypeRearTires` - Icon: `Icons.trip_origin`
- `maintenanceTypeBeltsChains` - Icon: `Icons.settings_input_component`

**Files Modified**:
- `lib/utils/constants.dart` - Added constants and display names
- `lib/screens/machine_detail_screen.dart` - Added icon cases

#### Documentation Cleanup
**Actions Taken**:
1. **Removed** four "setup complete" summary files from root:
   - `NOTIFICATION_SETUP.md` (duplicate of copilot-instructions/notifications.md)
   - `DATA_PERSISTENCE.md` (duplicate of copilot-instructions/database-backup.md)
   - `ANDROID_SETUP_GUIDE.md` (duplicate of copilot-instructions/android-requirements.md)
   - `PIPELINE_FLOW.md` (duplicate of copilot-instructions/ci-cd-pipeline.md)

2. **Moved** legitimate documentation to copilot-instructions:
   - `JENKINS_SETUP.md` → `.github/copilot-instructions/jenkins-setup.md`

3. **Added** mandatory rule: No markdown files in root except `README.md`

**Project Structure**: Root directory now clean with only essential files and README.md

### Session: February 2026 - Play Store Publishing Integration

#### Automated Play Store Publishing
**Feature**: Added complete Play Store publishing automation to Jenkins pipeline.

**New Pipeline Parameters**:
1. **RELEASE_NOTES** (text): Multiline text field for custom release notes
   - Automatically included in GitHub release description
   - Used for Play Store "What's new" section
   - Supports markdown formatting for GitHub

2. **PUBLISH_TO_PLAY_STORE** (boolean): Checkbox to enable/disable Play Store publishing
   - When enabled: Builds AAB and publishes to Play Store
   - When disabled: Only builds APK and creates GitHub release
   - Safe default (unchecked) prevents accidental publishing

3. **PLAY_STORE_TRACK** (choice): Select release track for Play Store
   - **production**: Public release (requires Google review, 1-7 days)
   - **internal**: Internal testing (up to 100 testers, no review)
   - **beta**: Beta testing (larger audience, manual promotion)
   - **alpha**: Alpha testing (smaller audience, manual promotion)
   - Default: production (automated public releases)

**New Pipeline Stages**:
1. **Setup Android Signing**: Injects keystore credentials from Jenkins before building
2. **Build App Bundle (AAB)**: Conditional stage that builds Android App Bundle for Play Store
3. **Publish to Play Store**: Automated upload to Google Play with track selection

**Files Modified**:
- `android/app/build.gradle.kts`:
  - **CRITICAL UPDATE**: Added signing configuration that reads from `key.properties`
  - Loads keystore properties: keyAlias, keyPassword, storeFile, storePassword
  - Creates release signing config with these properties
  - Falls back to debug signing if `key.properties` doesn't exist (local dev)
  - Added Gradle Play Publisher plugin (v3.10.1)
  - Configured Play Store credentials via environment variable
  - Dynamic track selection via `PLAY_STORE_TRACK` environment variable
  - Enabled App Bundle as default format

- `Jenkinsfile`:
  - Added `RELEASE_NOTES` text parameter
  - Added `PUBLISH_TO_PLAY_STORE` boolean parameter
  - Added `PLAY_STORE_TRACK` choice parameter (production/internal/beta/alpha)
  - **NEW**: Added `ANDROID_KEYSTORE_ID` and `ANDROID_KEYSTORE_PASSWORD_ID` environment variables
  - **NEW**: Added "Setup Android Signing" stage that:
    * Copies keystore from Jenkins credentials to workspace
    * Dynamically creates `key.properties` file with credentials
    * Uses credential IDs: `android-upload-keystore` and `android-keystore-password`
  - Updated GitHub release body to include release notes
  - Added "Build App Bundle (AAB)" conditional stage
  - Added "Publish to Play Store" conditional stage with release notes generation
  - Dynamic track selection passed to Gradle via environment variable
  - Updated success message to show Play Store publish status and track
  - Updated Archive stage to include AAB artifacts

- `android/.gitignore`:
  - Already protects `**/*.jks` (covers temporary keystores Jenkins creates)
  - Already has key.properties, *service-account*.json patterns

**Documentation Added**:
- Created comprehensive [play-store-publishing.md](copilot-instructions/play-store-publishing.md) guide:
  - **Public Repository Security** section with clear DO/DON'T guidelines
  - Secure workflow diagram showing secret flow
  - Google Play App Signing explanation (two-key system)
  - Build configuration patterns (signing and publishing)
  - Jenkins pipeline integration patterns
  - Pipeline parameters and release tracks
  - Service account setup requirements
  - Common error patterns and solutions
  - Security best practices for AI assistance
  - Technical dependencies and references

**Security Model**:
- All secrets stored in Jenkins credentials (never committed)
- `.gitignore` protects keystores, key.properties, service account JSON
- Build configuration safe to commit (reads from environment variables OR files)
- Local development uses gitignored `key.properties` pointing to secure keystore location
- CI/CD injects secrets dynamically:
  * Copies keystore from Jenkins Secret File credential
  * Creates `key.properties` dynamically with Secret Text credential
  * Both are cleaned up after build (workspace cleanup)
- Credential IDs hardcoded in Jenkinsfile for consistency

**Key Features**:
- **Automatic signing** in Jenkins without storing secrets in repo
- Release notes appear in both GitHub and Play Store
- Direct publishing to any Play Store track (production/internal/beta/alpha)
- Production releases automated (no manual promotion needed)
- AAB artifacts archived alongside APK
- Conditional execution - no performance impact when disabled
- Comprehensive error handling and validation
- Local development still works with manual `key.properties` setup

**Usage Pattern**:
```
Jenkins → Build with Parameters:
1. Select RELEASE_TYPE (patch/minor/major)
2. Enter RELEASE_NOTES (optional but recommended)
3. Check PUBLISH_TO_PLAY_STORE if ready to publish
4. Select PLAY_STORE_TRACK (production for public release)
5. Click Build
```

**Security Notes**:
- Play Store credentials stored securely as Jenkins Secret File
- Service account JSON never exposed in logs
- Release notes sanitized before API calls
- Internal testing track provides safety net before production

**Pipeline Philosophy**:
- Testing and code analysis done locally before release
- Pipeline focuses on building and deploying verified code
- Removed `flutter test` and `flutter analyze` stages from release pipeline
- Quality checks are developer responsibility before triggering release

### Session: February 2026 - Battery Tracking and UI Refinements

#### Battery Information Tracking
**Feature**: Added complete battery specification tracking for machines.

**New Machine Properties**:
- `batteryVoltage`: Optional String field for voltage (e.g., "12", "12.6")
  - Icon: `Icons.battery_charging_full`
  - Hint: "e.g., 12, 12.6"
- `batteryCapacity`: Optional String field for capacity in amp-hours (e.g., "50", "100")
  - Icon: `Icons.battery_std`
  - Hint: "e.g., 50, 100"

**Database**: Upgraded to version 8 with migration to add battery columns
**Files Modified**:
- `lib/models/machine.dart` - Added batteryVoltage and batteryCapacity to model
- `lib/services/database_service.dart` - Version 7→8 migration, added battery columns to schema
- `lib/screens/add_machine_screen.dart` - Added battery voltage/capacity input fields
- `lib/screens/edit_machine_screen.dart` - Added battery voltage/capacity input fields
- `lib/services/machine_provider.dart` - Updated copyWith to include battery fields
- `lib/screens/machine_detail_screen.dart` - Added Battery section displaying voltage (V) and capacity (Ah)

**Display Logic**:
- Battery section appears between Tires and Other Information sections
- Only shows when at least one battery field is set (voltage OR capacity)
- Uses `Icons.battery_charging_full` for section header
- Formats display: "Voltage: 12 V", "Capacity: 50 Ah"

#### Battery Maintenance Type
**Feature**: Added battery maintenance tracking capability.

**New Maintenance Type**:
- `maintenanceTypeBattery` - Icon: `Icons.battery_charging_full`
- Display name: "Battery"
- No database migration needed (maintenance types stored as TEXT)

**Files Modified**:
- `lib/utils/constants.dart` - Added constant and display name
- `lib/screens/machine_detail_screen.dart` - Added icon case in `_getMaintenanceIcon()`

**Usage**: Users can now log battery maintenance, configure intervals, and track battery maintenance status.

#### Machine Type Tag UI Enhancement
**Change**: Updated machine type display on home screen cards to have a "tag" appearance.

**Before**: Plain icon with gray color
**After**: Icon wrapped in Container with:
- Padding: `horizontal: 6, vertical: 4`
- Background: `AppTheme.accentBlue` with 15% opacity
- Border radius: 4px
- Icon color: `AppTheme.accentBlue` (bright blue)
- Compact tag-like appearance

**Files Modified**:
- `lib/widgets/machine_card.dart` - Changed Row layout to include Container wrapper

**Visual Impact**: Machine type icon now stands out as a small colored tag, improving visual hierarchy while maintaining icon-only design.

#### Button Color Standardization
**Change**: Standardized action button colors across the app for consistency.

**Updated Buttons**:
1. **"View All" button** on Machine Detail Screen (Maintenance Status section)
2. **"View All" button** on Machine Detail Screen (Maintenance History section)
3. **"Edit" button** on Maintenance Intervals Screen

**Before**: Dark blue color (low contrast, hard to see)
**After**: Bright blue (`AppTheme.accentBlue`) for better visibility and consistency

**Files Modified**:
- `lib/screens/machine_detail_screen.dart` - Added `foregroundColor: AppTheme.accentBlue` to both View All buttons
- `lib/screens/maintenance_intervals_screen.dart` - Added `foregroundColor: AppTheme.accentBlue` to Edit button

**Implementation Pattern**:
```dart
OutlinedButton.icon(
  style: OutlinedButton.styleFrom(
    foregroundColor: AppTheme.accentBlue,
    // ... other style properties
  ),
)
```

#### Updated Field Order and Properties

**Current Machine Form Field Order** (updated):
1. Image Picker
2. Machine Type
3. Brand (required)
4. Model (required)
5. Nickname (optional)
6. Year (optional)
7. Serial Number (optional)
8. Spark Plug Type (optional)
9. Spark Plug Gap (mm) (optional)
10. Oil Type (optional)
11. Oil Capacity (optional)
12. Fuel Type (optional)
13. Front Tires Size (optional)
14. Rear Tires Size (optional)
15. Front Tire Pressure (PSI) (optional)
16. Rear Tire Pressure (PSI) (optional)
17. Battery Voltage (V) (optional)
18. Battery Capacity (Ah) (optional)
19. Battery Type/Model (optional)
20. Tank Size (optional)
21. Current Odometer (required)

**Machine Detail Screen Sections**:
- **Oil Information**: Oil Type, Oil Capacity
- **Spark Plug**: Spark Plug Type, Spark Plug Gap
- **Tires**: Front/Rear Size, Front/Rear Pressure (with smart label logic)
- **Battery**: Type/Model, Voltage (V), Capacity (Ah)
- **Other Information**: Serial Number, Fuel Type

**Complete Machine Properties** (as of database version 9):
- Basic: type, brand, model, nickname, year, serialNumber
- Oil: oilType, oilCapacity
- Spark: sparkPlugType, sparkPlugGap
- Fuel: fuelType, tankSize
- Tires: frontTiresSize, rearTiresSize, frontTirePressure, rearTirePressure
- Battery: batteryVoltage, batteryCapacity, batteryType
- Other: imagePath, currentOdometer, odometerUnit

**Updated Maintenance Types** (13 total):
1. Oil Change
2. Filter Cleaning
3. Chain Oiling
4. Brake Fluid
5. Coolant
6. Spark Plug
7. Brake Inspection
8. General Service
9. Fuel
10. Front Tires
11. Rear Tires
12. Belts/Chains
13. Battery ← NEW