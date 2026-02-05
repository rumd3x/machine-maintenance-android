import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/machine.dart';
import '../models/maintenance_status.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
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
  }

  /// Schedule a notification for a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
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
  }) async {
    // Cancel existing notifications for this machine
    await cancelMachineNotifications(machine.id!);

    int notificationId = machine.id! * 1000; // Base ID for this machine

    for (final entry in statuses.entries) {
      final maintenanceType = entry.key;
      final status = entry.value;

      // Only schedule for checkSoon and overdue statuses
      if (status.status == MaintenanceStatusType.checkSoon ||
          status.status == MaintenanceStatusType.overdue) {
        
        final scheduledDate = _calculateNotificationDate(status);
        if (scheduledDate == null) continue;

        final title = _getNotificationTitle(machine, maintenanceType, status);
        final body = _getNotificationBody(machine, maintenanceType, status);

        await scheduleNotification(
          id: notificationId++,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          payload: 'machine_${machine.id}_$maintenanceType',
        );
      }
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
