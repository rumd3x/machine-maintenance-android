# Data Persistence and Backup

## Overview

The Machine Maintenance Tracker app is configured to preserve user data across app updates and reinstallations using Android's Auto Backup feature.

## How It Works

### Android Auto Backup

The app uses Android's built-in Auto Backup system which automatically backs up app data to the user's Google Drive account (if they have one configured). This happens automatically without user intervention.

**What gets backed up:**
- ✅ SQLite database (`machine_maintenance.db`) - all machines, maintenance records, and intervals
- ✅ App files - stored machine images
- ✅ Shared preferences - user settings and notification preferences
- ❌ Cache files - excluded to save space

### Configuration Files

1. **AndroidManifest.xml**
   ```xml
   <application
       android:allowBackup="true"
       android:fullBackupContent="@xml/backup_rules">
   ```

2. **backup_rules.xml**
   Defines what data to include/exclude from backups.

## Data Restoration

### Automatic Restoration

When a user:
1. Uninstalls the app
2. Reinstalls the app (same version or newer)
3. Signs in with the same Google account

Android will automatically restore:
- All machines and their photos
- Complete maintenance history
- Notification schedules
- User preferences

### Manual Backup Testing

To test backup/restore manually:

```bash
# Enable backup for testing
adb shell bmgr enable true

# Trigger immediate backup
adb shell bmgr backupnow com.example.machine_maintenance

# Check backup status
adb shell dumpsys backup

# Clear app data (simulates uninstall)
adb shell pm clear com.example.machine_maintenance

# Trigger restore
adb shell bmgr restore com.example.machine_maintenance
```

## Limitations

### When Data Won't Persist:

1. **Different Google Account**: If user signs in with a different Google account on the new device
2. **Device-to-Device Transfer**: Auto Backup only works for same device reinstalls. For device changes, use Google's device transfer tool
3. **Manual Data Clear**: If user explicitly clears app data or storage before uninstall
4. **No Google Account**: Users without Google accounts won't have cloud backup (data still lost on uninstall)
5. **Backup Disabled**: If user has disabled backup for the app in Android settings

### Important Notes:

- **First Install**: No data to restore on first installation
- **Backup Delay**: Backups happen periodically (usually daily), not immediately after data changes
- **Storage Quota**: Google provides 25MB free backup space per app
- **WiFi Only**: By default, backups only occur when connected to WiFi and charging

## Alternative: Local Backup Feature

For users who want manual control or don't use Google accounts, consider implementing a future feature:

- Export database to Downloads folder (survives uninstall)
- Import database from file
- Share backup via email/cloud storage

This would require additional implementation and user action.

## Verifying Backup Is Working

After installation, you can verify backup is enabled:

1. Settings → Google → Backup
2. Check if "Machine Maintenance Tracker" appears in the app list
3. Last backup timestamp should be recent (within 24 hours)

## Database Location

The SQLite database is stored at:
```
/data/data/com.example.machine_maintenance/databases/machine_maintenance.db
```

This location is automatically included in Android's backup system.

## Images Storage

Machine photos are stored at:
```
/data/data/com.example.machine_maintenance/app_flutter/
```

This location is also included in the backup system via the `file` domain in backup_rules.xml.
