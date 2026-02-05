import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'notification_service.dart';
import 'maintenance_calculator.dart';
import '../models/machine.dart';
import '../models/maintenance_interval.dart';
import '../models/maintenance_record.dart';

/// Background task names
const String maintenanceCheckTask = 'maintenance_check_task';
const String notificationRescheduleTask = 'notification_reschedule_task';

/// Callback dispatcher for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case maintenanceCheckTask:
          await _checkMaintenanceStatus();
          break;
        case notificationRescheduleTask:
          await _rescheduleAllNotifications();
          break;
        default:
          debugPrint('Unknown task: $task');
      }
      return Future.value(true);
    } catch (e) {
      debugPrint('Error executing background task: $e');
      return Future.value(false);
    }
  });
}

/// Check maintenance status for all machines and send notifications
Future<void> _checkMaintenanceStatus() async {
  try {
    final dbService = DatabaseService();
    final notificationService = NotificationService();
    final calculator = MaintenanceCalculator();

    // Initialize notification service
    await notificationService.initialize();

    // Get all machines
    final machines = await dbService.getAllMachines();

    for (final machine in machines) {
      if (machine.id == null) continue;

      // Get intervals and records
      final intervals = await dbService.getMaintenanceIntervals(machine.id!);
      final records = await dbService.getMaintenanceRecords(machine.id!);

      // Calculate statuses
      final statuses = await calculator.calculateAllStatuses(
        machine: machine,
        intervals: intervals,
        records: records,
      );

      // Schedule notifications
      await notificationService.scheduleMaintenanceReminders(
        machine: machine,
        statuses: statuses,
        intervals: intervals,
      );
    }

    debugPrint('Background maintenance check completed for ${machines.length} machines');
  } catch (e) {
    debugPrint('Error in background maintenance check: $e');
  }
}

/// Reschedule all notifications (used after boot)
Future<void> _rescheduleAllNotifications() async {
  await _checkMaintenanceStatus();
}

/// Background service manager
class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  bool _initialized = false;

  /// Initialize background service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      // Schedule periodic maintenance checks (every 6 hours)
      await Workmanager().registerPeriodicTask(
        'maintenance_check_periodic',
        maintenanceCheckTask,
        frequency: const Duration(hours: 6),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );

      _initialized = true;
      debugPrint('Background service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing background service: $e');
    }
  }

  /// Schedule notification reschedule (e.g., after boot)
  Future<void> scheduleNotificationReschedule() async {
    try {
      await Workmanager().registerOneOffTask(
        'notification_reschedule_oneoff',
        notificationRescheduleTask,
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
      debugPrint('Notification reschedule task scheduled');
    } catch (e) {
      debugPrint('Error scheduling notification reschedule: $e');
    }
  }

  /// Trigger immediate maintenance check
  Future<void> triggerImmediateCheck() async {
    try {
      await Workmanager().registerOneOffTask(
        'maintenance_check_immediate',
        maintenanceCheckTask,
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
      debugPrint('Immediate maintenance check triggered');
    } catch (e) {
      debugPrint('Error triggering immediate check: $e');
    }
  }

  /// Cancel all background tasks
  Future<void> cancelAll() async {
    try {
      await Workmanager().cancelAll();
      debugPrint('All background tasks cancelled');
    } catch (e) {
      debugPrint('Error cancelling background tasks: $e');
    }
  }
}
