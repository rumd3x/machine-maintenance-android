# GitHub Copilot Instructions

**🚨 CRITICAL**: Before making ANY code changes, read [DOCUMENTATION-MANDATE.md](copilot-instructions/DOCUMENTATION-MANDATE.md). **All code changes MUST be documented immediately.**

## 🔴 MANDATORY DOCUMENTATION RULE

**ALWAYS** document every change made in this file (`copilot-instructions.md`):

1. **During active work**: Document significant changes, patterns, and decisions as you make them
2. **End of conversation**: Review ALL changes made and ensure they are documented in the appropriate section
3. **New features**: Document the feature, its location, usage patterns, and any gotchas
4. **Bug fixes**: Document what was broken, how it was fixed, and the correct pattern going forward
5. **Architecture changes**: Document the new approach, why it was changed, and migration notes
6. **UI/UX changes**: Document the pattern, component usage, and styling guidelines

**Never leave a conversation without updating this documentation file.**

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
   10. Oil Capacity (optional)
   11. Fuel Type (optional)
   12. Front Tires Size (optional)
   13. Rear Tires Size (optional)
   14. Current Odometer (required)
   15. Tank Size (optional)

3. **Field Properties** (must match exactly):
   - **Icons**: 
     - Brand: `Icons.business`
     - Model: `Icons.motorcycle`
     - Nickname: `Icons.label`
     - Year: `Icons.calendar_today`
     - Serial Number: `Icons.numbers`
     - Spark Plug: `Icons.electrical_services`
     - Oil Type: `Icons.water_drop`
     - Oil Capacity: `Icons.water_drop`
     - Fuel Type: `Icons.local_gas_station`
     - Front Tires Size: `Icons.circle_outlined`
     - Rear Tires Size: `Icons.circle_outlined`
     - Odometer: `Icons.speed`
     - Tank Size: `Icons.local_gas_station`
   
   - **Hints**:
     - Brand: `'e.g., Suzuki, Honda, Yamaha'`
     - Model: `'e.g., Intruder 125, CG 160'`
     - Nickname: `'e.g., My Bike, Work Car'`
     - Oil Type: `'e.g., 10W-40, 20W-50'`
     - Oil Capacity: `'e.g., 1.2L, 4 Liters'`
     - Fuel Type: `'e.g., Gasoline, Diesel, Ethanol'`
     - Front Tires Size: `'e.g., 205/55 R16'`
     - Rear Tires Size: `'e.g., 225/50 R17'`
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

**Current Version**: 5

#### Version History:
- **v1**: Initial schema (machines, maintenance_records, maintenance_intervals)
- **v2**: Added `fuelType` to machines, `fuelAmount` to maintenance_records
- **v3**: Added `notifications` table
- **v4**: Added `notificationSent` flag to maintenance_intervals
- **v5**: Added `oilCapacity`, `frontTiresSize`, `rearTiresSize` to machines

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

**Pipeline stages**: Checkout → Calculate Version → Update Version → Dependencies → Build APK → Build AAB (optional) → Commit → Tag → Push → GitHub Release → Play Store Publish (optional) → Archive

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
- `oilType`: e.g., "10W-40", "20W-50"
- `oilCapacity`: e.g., "1.2L", "4 Liters"
- `fuelType`: e.g., "Gasoline", "Diesel", "Ethanol"
- `tankSize`: Numeric value in liters
- `frontTiresSize`: e.g., "205/55 R16"
- `rearTiresSize`: e.g., "225/50 R17"
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

### Adding New Maintenance Types

1. Add constant to `lib/utils/constants.dart`
2. Add display name to `maintenanceTypeNames` map
3. Add icon case to `_getMaintenanceIcon()` in `machine_detail_screen.dart`
4. No database migration needed (maintenanceType is TEXT field)

## Recent Changes and Improvements

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
1. **Build App Bundle (AAB)**: Conditional stage that builds Android App Bundle for Play Store
2. **Publish to Play Store**: Automated upload to Google Play internal testing track

**Files Modified**:
- `android/app/build.gradle.kts`:
  - Added Gradle Play Publisher plugin (v3.10.1)
  - Configured Play Store credentials via environment variable
  - Dynamic track selection via `PLAY_STORE_TRACK` environment variable
  - Enabled App Bundle as default format

- `Jenkinsfile`:
  - Added `RELEASE_NOTES` text parameter
  - Added `PUBLISH_TO_PLAY_STORE` boolean parameter
  - Added `PLAY_STORE_TRACK` choice parameter (production/internal/beta/alpha)
  - Updated `PLAY_STORE_CREDENTIALS_ID` environment variable
  - Updated GitHub release body to include release notes
  - Added "Build App Bundle (AAB)" conditional stage
  - Added "Publish to Play Store" conditional stage with release notes generation
  - Dynamic track selection passed to Gradle via environment variable
  - Updated success message to show Play Store publish status and track
  - Updated Archive stage to include AAB artifacts

**Documentation Added**:
- Created comprehensive [play-store-publishing.md](copilot-instructions/play-store-publishing.md) guide:
  - **Public Repository Security** section with clear DO/DON'T guidelines
  - Secure workflow diagram showing secret flow
  - Google Play Console account setup
  - App signing configuration (Google Play App Signing vs manual)
  - Upload keystore creation with secure storage practices
  - Service account setup for API access
  - Jenkins credentials configuration (secrets never in repo)
  - Pipeline usage instructions
  - Release tracks and progression strategy
  - Comprehensive security audit checklist
  - Troubleshooting common issues
  - Security best practices for public repos
  - First-time publishing checklist

**Security Model**:
- All secrets stored in Jenkins credentials (never committed)
- `.gitignore` protects keystores, key.properties, service account JSON
- Build configuration safe to commit (reads from environment variables)
- Local development uses gitignored `key.properties` pointing to secure keystore location
- CI/CD injects secrets at build time via environment variables

**Key Features**:
- Release notes appear in both GitHub and Play Store
- Direct publishing to any Play Store track (production/internal/beta/alpha)
- Production releases automated (no manual promotion needed)
- AAB artifacts archived alongside APK
- Conditional execution - no performance impact when disabled
- Comprehensive error handling and validation

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