import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/machine.dart';
import '../models/maintenance_status.dart';
import '../models/maintenance_interval.dart';
import '../models/app_notification.dart';
import 'database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final DatabaseService _dbService = DatabaseService();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings (for future compatibility)
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Request notification permissions (required for Android 13+)
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    }
    return true;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        return await androidPlugin.areNotificationsEnabled() ?? false;
      }
    }
    return true;
  }

  /// Request exact alarm permission (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        return await androidPlugin.canScheduleExactNotifications() ?? false;
      }
    }
    return true;
  }

  /// Request exact alarm permission
  Future<void> requestExactAlarmPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.requestExactAlarmsPermission();
      }
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to machine detail screen based on payload
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    int? machineId,
    bool saveToDb = false,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'maintenance_reminders',
      'Maintenance Reminders',
      channelDescription: 'Notifications for upcoming vehicle maintenance',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    // Save to database only if requested (to avoid duplicates when called from provider)
    if (saveToDb) {
      final appNotification = AppNotification(
        title: title,
        body: body,
        machineId: machineId,
        createdAt: DateTime.now(),
      );
      await _dbService.insertNotification(appNotification);
    }
  }

  /// Schedule a notification for a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    int? machineId,
    bool saveToDb = true,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'maintenance_reminders',
      'Maintenance Reminders',
      channelDescription: 'Notifications for upcoming vehicle maintenance',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    // Save to database (scheduled notifications will be shown when triggered)
    if (saveToDb) {
      final appNotification = AppNotification(
        title: title,
        body: body,
        machineId: machineId,
        createdAt: scheduledDate,
      );
      await _dbService.insertNotification(appNotification);
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Schedule maintenance reminder notifications for a machine
  Future<void> scheduleMaintenanceReminders({
    required Machine machine,
    required Map<String, MaintenanceStatus> statuses,
    required List<MaintenanceInterval> intervals,
  }) async {
    // Cancel existing notifications for this machine
    await cancelMachineNotifications(machine.id!);

    int notificationId = machine.id! * 1000; // Base ID for this machine

    for (final entry in statuses.entries) {
      final maintenanceType = entry.key;
      final status = entry.value;

      // Find the corresponding interval
      final interval = intervals.firstWhere(
        (i) => i.maintenanceType == maintenanceType,
        orElse: () => MaintenanceInterval(
          machineId: machine.id!,
          maintenanceType: maintenanceType,
          enabled: false,
        ),
      );

      // Skip if interval is not enabled
      if (!interval.enabled) continue;

      // Only schedule for checkSoon and overdue statuses
      if (status.status == MaintenanceStatusType.checkSoon ||
          status.status == MaintenanceStatusType.overdue) {
        
        // For checkSoon status, reset flag to allow yellow->red transition
        // After reset, we'll re-check if already notified for this checkSoon cycle
        if (status.status == MaintenanceStatusType.checkSoon && interval.notificationSent) {
          await _dbService.resetNotificationSentFlag(interval.machineId, maintenanceType);
          debugPrint('Reset flag for ${machine.displayName} - $maintenanceType (checkSoon)');
          // Reload interval with reset flag
          interval = await _dbService.getMaintenanceInterval(
            interval.machineId,
            maintenanceType,
          ) ?? interval;
        }
        
        // For checkSoon, check the flag to prevent duplicate scheduled notifications
        // For overdue, check both flag AND notification history
        // - Flag prevents notification for newly added machines
        // - History check prevents duplicates but allows checkSoon->overdue transition
        if (status.status == MaintenanceStatusType.checkSoon && interval.notificationSent) {
          debugPrint('Notification already scheduled for ${machine.displayName} - $maintenanceType (checkSoon), skipping...');
          continue;
        }
        
        // For overdue status, check flag first, then notification history
        if (status.status == MaintenanceStatusType.overdue) {
          if (interval.notificationSent) {
            // Flag is set - could be from new machine or previous notification
            // Check if there's a recent overdue notification to determine if we should skip
            final hasRecentOverdue = await _hasRecentOverdueNotification(machine.id!, maintenanceType);
            if (hasRecentOverdue) {
              debugPrint('Recent overdue notification exists for ${machine.displayName} - $maintenanceType, skipping...');
              continue;
            } else {
              // Flag is set but no recent overdue notification
              // This means it's either a new machine or checkSoon->overdue transition
              // For new machines, skip (respect the flag)
              // For checkSoon->overdue, we need to detect this...
              // Simple heuristic: check if there's any recent notification (checkSoon or overdue)
              final hasAnyRecentNotification = await _hasRecentNotification(machine.id!, maintenanceType);
              if (!hasAnyRecentNotification) {
                // No recent notifications at all - this is a new machine, skip
                debugPrint('New machine with no history for ${machine.displayName} - $maintenanceType, skipping...');
                continue;
              }
              // Has recent notification but not overdue - this is checkSoon->overdue transition, allow
              debugPrint('Allowing overdue notification for ${machine.displayName} - $maintenanceType (checkSoon->overdue transition)');
            }
          }
        }

        final scheduledDate = _calculateNotificationDate(status);
        if (scheduledDate == null) continue;

        final title = _getNotificationTitle(machine, maintenanceType, status);
        final body = _getNotificationBody(machine, maintenanceType, status);

        // For overdue items, show notification immediately and save to DB
        if (status.status == MaintenanceStatusType.overdue) {
          // Save to database
          final appNotification = AppNotification(
            title: title,
            body: body,
            machineId: machine.id,
            createdAt: DateTime.now(),
          );
          await _dbService.insertNotification(appNotification);
          
          // Show system notification immediately
          await showNotification(
            id: notificationId++,
            title: title,
            body: body,
            payload: 'machine_${machine.id}_$maintenanceType',
            machineId: machine.id,
            saveToDb: false, // Already saved above
          );
          
          // Mark notification as sent for overdue status
          await _markNotificationSent(interval);
        } else {
          // For checkSoon, schedule for future notification
          await scheduleNotification(
            id: notificationId++,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
            payload: 'machine_${machine.id}_$maintenanceType',
            machineId: machine.id,
            saveToDb: true,
          );
          
          // Mark notification as sent to prevent duplicate checkSoon notifications
          await _markNotificationSent(interval);
        }
      }
    }
  }

  /// Mark notification as sent for a maintenance interval
  Future<void> _markNotificationSent(MaintenanceInterval interval) async {
    if (interval.id == null) return;
    
    final updatedInterval = interval.copyWith(notificationSent: true);
    await _dbService.updateMaintenanceInterval(updatedInterval);
    debugPrint('Marked notification as sent for interval ID ${interval.id}');
  }

  /// Check if there's a recent overdue notification for this maintenance type
  /// Returns true if notification exists within the last 24 hours with "overdue" in text
  Future<bool> _hasRecentOverdueNotification(int machineId, String maintenanceType) async {
    try {
      final notifications = await _dbService.getAllNotifications();
      final oneDayAgo = DateTime.now().subtract(const Duration(hours: 24));
      
      // Check if any notification matches this machine and maintenance type, and is overdue
      final hasRecent = notifications.any((notification) {
        if (notification.machineId != machineId) return false;
        if (notification.createdAt.isBefore(oneDayAgo)) return false;
        
        // Check if notification contains both the maintenance type and "overdue" keyword
        final notificationText = '${notification.title} ${notification.body}'.toLowerCase();
        final maintenanceTypeLower = maintenanceType.toLowerCase().replaceAll('_', ' ');
        return notificationText.contains(maintenanceTypeLower) && 
               notificationText.contains('overdue');
      });
      
      return hasRecent;
    } catch (e) {
      debugPrint('Error checking recent overdue notifications: $e');
      return false; // On error, allow notification
    }
  }

  /// Check if there's any recent notification (checkSoon or overdue) for this maintenance type
  /// Returns true if notification exists within the last 7 days
  Future<bool> _hasRecentNotification(int machineId, String maintenanceType) async {
    try {
      final notifications = await _dbService.getAllNotifications();
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      
      // Check if any notification matches this machine and maintenance type
      final hasRecent = notifications.any((notification) {
        if (notification.machineId != machineId) return false;
        if (notification.createdAt.isBefore(sevenDaysAgo)) return false;
        
        // Check if notification contains the maintenance type
        final notificationText = '${notification.title} ${notification.body}'.toLowerCase();
        final maintenanceTypeLower = maintenanceType.toLowerCase().replaceAll('_', ' ');
        return notificationText.contains(maintenanceTypeLower);
      });
      
      return hasRecent;
    } catch (e) {
      debugPrint('Error checking recent notifications: $e');
      return false; // On error, allow notification
    }
  }

  /// Cancel all notifications for a specific machine
  Future<void> cancelMachineNotifications(int machineId) async {
    final pending = await getPendingNotifications();
    final baseId = machineId * 1000;
    
    for (final notification in pending) {
      if (notification.id >= baseId && notification.id < baseId + 100) {
        await cancelNotification(notification.id);
      }
    }
  }

  /// Calculate when to show notification based on status
  DateTime? _calculateNotificationDate(MaintenanceStatus status) {
    if (status.status == MaintenanceStatusType.overdue) {
      // Show immediately for overdue
      return DateTime.now().add(const Duration(minutes: 1));
    } else if (status.status == MaintenanceStatusType.checkSoon) {
      // Calculate based on remaining percentage
      if (status.daysUntilDue != null && status.daysUntilDue! > 0) {
        // Show notification when getting close (e.g., 7 days before or half the remaining time)
        final daysToWait = status.daysUntilDue! > 14 
            ? status.daysUntilDue! ~/ 2 
            : (status.daysUntilDue! - 7).clamp(0, status.daysUntilDue!);
        
        return DateTime.now().add(Duration(days: daysToWait));
      } else if (status.distanceUntilDue != null) {
        // For distance-based, show notification sooner (e.g., in 3 days)
        return DateTime.now().add(const Duration(days: 3));
      }
    }
    return null;
  }

  /// Get notification title
  String _getNotificationTitle(
    Machine machine,
    String maintenanceType,
    MaintenanceStatus status,
  ) {
    final machineName = machine.displayName;
    final type = _formatMaintenanceType(maintenanceType);

    if (status.status == MaintenanceStatusType.overdue) {
      return '⚠️ $type Overdue - $machineName';
    } else {
      return '🔔 $type Due Soon - $machineName';
    }
  }

  /// Get notification body
  String _getNotificationBody(
    Machine machine,
    String maintenanceType,
    MaintenanceStatus status,
  ) {
    final type = _formatMaintenanceType(maintenanceType);
    
    if (status.status == MaintenanceStatusType.overdue) {
      // Calculate overdue amount
      if (status.daysUntilDue != null && status.daysUntilDue! < 0) {
        final daysOverdue = -status.daysUntilDue!;
        return 'The $type on your ${machine.displayName} is $daysOverdue days overdue!';
      } else if (status.distanceUntilDue != null && status.distanceUntilDue! < 0) {
        final distanceOverdue = -status.distanceUntilDue!;
        return 'The $type on your ${machine.displayName} is ${distanceOverdue.toInt()} ${machine.odometerUnit} overdue!';
      } else {
        return 'The $type on your ${machine.displayName} is overdue!';
      }
    } else {
      if (status.daysUntilDue != null && status.daysUntilDue! > 0) {
        return 'The $type on your ${machine.displayName} is due in ${status.daysUntilDue} days.';
      } else if (status.distanceUntilDue != null && status.distanceUntilDue! > 0) {
        return 'The $type on your ${machine.displayName} is due in ${status.distanceUntilDue!.toInt()} ${machine.odometerUnit}.';
      } else {
        return 'The $type on your ${machine.displayName} is due soon!';
      }
    }
  }

  /// Format maintenance type for display
  String _formatMaintenanceType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
