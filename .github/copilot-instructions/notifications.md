# Notification System

## Overview
The app includes a comprehensive local notification system that alerts users when maintenance is due or overdue. Notifications are personalized with machine names and maintenance details.

## Features

### Smart Scheduling
- **Overdue maintenance**: Immediate notification
- **Check soon status**: 3-7 days before due date
- **Optimal status**: No notifications

### Automatic Updates
Notifications are automatically rescheduled when:
- Adding a new machine
- Updating machine information (odometer change)
- Adding maintenance records
- Updating maintenance intervals

### Notification Content
Example: "The oil on your Honda Shadow is due in 5 days"

Format includes:
- Machine display name (nickname or model)
- Maintenance type (oil change, brake check, etc.)
- Time or distance until due
- Status emoji (🔔 for due soon, ⚠️ for overdue)

## Android Permissions

All required permissions are configured in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

### Permission Details

- **POST_NOTIFICATIONS**: Required for Android 13+ (API 33+) to show notifications
- **SCHEDULE_EXACT_ALARM**: Schedule notifications at exact times
- **USE_EXACT_ALARM**: Alternative for exact scheduling
- **RECEIVE_BOOT_COMPLETED**: Restore scheduled notifications after device reboot
- **VIBRATE**: Vibrate device on notification
- **WAKE_LOCK**: Wake device to show notification

## Implementation

### NotificationService
Located in `lib/services/notification_service.dart`

Key methods:
- `initialize()`: Setup notification channels and timezone
- `requestPermissions()`: Request runtime permissions on Android 13+
- `scheduleMaintenanceReminders()`: Schedule notifications for a machine
- `cancelMachineNotifications()`: Cancel all notifications for a machine
- `showNotification()`: Show immediate notification

### Integration
The `MachineProvider` automatically calls notification scheduling:
- After adding a machine
- After updating a machine
- After adding a maintenance record
- When maintenance intervals are modified

### Notification IDs
Each machine gets a unique base ID: `machineId * 1000`
Individual maintenance types use sequential IDs from the base.

Example:
- Machine ID 1: notifications 1000, 1001, 1002...
- Machine ID 2: notifications 2000, 2001, 2002...

## Dependencies

```yaml
flutter_local_notifications: ^17.2.4
timezone: ^0.9.4
```

## Testing Notifications

1. Add a machine with current odometer
2. Add or configure maintenance intervals
3. Set a maintenance type to be due soon (e.g., in 5 days)
4. Wait for scheduled notification or trigger manually
5. Check notification tray for personalized message

## Boot Persistence

Notifications are restored after device reboot via:
- `ScheduledNotificationBootReceiver` configured in manifest
- Intent filters for `BOOT_COMPLETED` and `MY_PACKAGE_REPLACED`
- Automatic rescheduling on app launch

## Notification Channels

**Channel**: "maintenance_reminders"
**Name**: "Maintenance Reminders"
**Description**: "Notifications for upcoming vehicle maintenance"
**Importance**: High
**Priority**: High
**Style**: BigTextStyle (for long messages)

## Future Enhancements

- [ ] Tap notification to navigate to machine detail screen (payload handling)
- [ ] User settings to enable/disable notifications per machine
- [ ] Custom notification schedule preferences
- [ ] Snooze/dismiss from notification
- [ ] Daily summary of all upcoming maintenance
