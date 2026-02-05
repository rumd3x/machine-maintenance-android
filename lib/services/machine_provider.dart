import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../models/maintenance_record.dart';
import '../models/maintenance_interval.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/maintenance_calculator.dart';

class MachineProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final MaintenanceCalculator _calculator = MaintenanceCalculator();
  List<Machine> _machines = [];
  bool _isLoading = false;

  List<Machine> get machines => _machines;
  bool get isLoading => _isLoading;

  /// Load all machines from database
  Future<void> loadMachines() async {
    _isLoading = true;
    notifyListeners();

    try {
      _machines = await _databaseService.getAllMachines();
    } catch (e) {
      debugPrint('Error loading machines: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new machine
  Future<void> addMachine(Machine machine) async {
    try {
      final id = await _databaseService.insertMachine(machine);
      final newMachine = machine.copyWith(id: id);
      _machines.insert(0, newMachine);
      notifyListeners();
      
      // Schedule notifications for new machine
      await _scheduleNotificationsForMachine(newMachine);
    } catch (e) {
      debugPrint('Error adding machine: $e');
      rethrow;
    }
  }

  /// Update an existing machine
  Future<void> updateMachine(Machine machine) async {
    try {
      await _databaseService.updateMachine(machine);
      final index = _machines.indexWhere((m) => m.id == machine.id);
      if (index != -1) {
        _machines[index] = machine;
        notifyListeners();
        
        // Reschedule notifications after update
        await _scheduleNotificationsForMachine(machine);
      }
    } catch (e) {
      debugPrint('Error updating machine: $e');
      rethrow;
    }
  }

  /// Delete a machine
  Future<void> deleteMachine(int id) async {
    try {
      await _databaseService.deleteMachine(id);
      _machines.removeWhere((m) => m.id == id);
      
      // Cancel notifications for deleted machine
      await _notificationService.cancelMachineNotifications(id);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting machine: $e');
      rethrow;
    }
  }

  /// Get a specific machine
  Machine? getMachine(int id) {
    try {
      return _machines.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add maintenance record
  Future<void> addMaintenanceRecord(MaintenanceRecord record) async {
    try {
      await _databaseService.insertMaintenanceRecord(record);
      notifyListeners();
      
      // Reschedule notifications after maintenance is added
      final machine = getMachine(record.machineId);
      if (machine != null) {
        // Get intervals and records to calculate new statuses
        final intervals = await getMaintenanceIntervals(record.machineId);
        final records = await getMaintenanceRecords(record.machineId);
        
        // Calculate all statuses to check which are back to OK
        final statuses = await _calculator.calculateAllStatuses(
          machine: machine,
          intervals: intervals,
          records: records,
        );
        
        // Find maintenance types that are now optimal (OK status)
        final okMaintenanceTypes = statuses.entries
            .where((entry) => entry.value.status == MaintenanceStatusType.optimal)
            .map((entry) => entry.key)
            .toList();
        
        // Reset notification flags for maintenance types that are back to OK
        if (okMaintenanceTypes.isNotEmpty) {
          await _databaseService.resetNotificationFlagsForOkIntervals(
            record.machineId,
            okMaintenanceTypes,
          );
          debugPrint('Reset notification flags for: ${okMaintenanceTypes.join(", ")}');
        }
        
        // Reschedule notifications
        await _scheduleNotificationsForMachine(machine);
      }
    } catch (e) {
      debugPrint('Error adding maintenance record: $e');
      rethrow;
    }
  }

  /// Get maintenance records for a machine
  Future<List<MaintenanceRecord>> getMaintenanceRecords(int machineId) async {
    try {
      return await _databaseService.getMaintenanceRecords(machineId);
    } catch (e) {
      debugPrint('Error getting maintenance records: $e');
      return [];
    }
  }

  /// Add or update maintenance interval
  Future<void> saveMaintenanceInterval(MaintenanceInterval interval) async {
    try {
      await _databaseService.insertMaintenanceInterval(interval);
      notifyListeners();
      
      // Reschedule notifications after interval change
      final machine = getMachine(interval.machineId);
      if (machine != null) {
        await _scheduleNotificationsForMachine(machine);
      }
    } catch (e) {
      debugPrint('Error saving maintenance interval: $e');
      rethrow;
    }
  }

  /// Get maintenance intervals for a machine
  Future<List<MaintenanceInterval>> getMaintenanceIntervals(int machineId) async {
    try {
      return await _databaseService.getMaintenanceIntervals(machineId);
    } catch (e) {
      debugPrint('Error getting maintenance intervals: $e');
      return [];
    }
  }

  /// Schedule notifications for a machine based on its maintenance status
  Future<void> _scheduleNotificationsForMachine(Machine machine) async {
    try {
      if (machine.id == null) return;

      // Get intervals and records
      final intervals = await getMaintenanceIntervals(machine.id!);
      final records = await getMaintenanceRecords(machine.id!);

      // Calculate all statuses
      final statuses = await _calculator.calculateAllStatuses(
        machine: machine,
        intervals: intervals,
        records: records,
      );

      // Schedule notifications
      await _notificationService.scheduleMaintenanceReminders(
        machine: machine,
        statuses: statuses,
        intervals: intervals,
      );
    } catch (e) {
      debugPrint('Error scheduling notifications for machine: $e');
    }
  }

  /// Reschedule all notifications for all machines
  Future<void> rescheduleAllNotifications() async {
    for (final machine in _machines) {
      await _scheduleNotificationsForMachine(machine);
    }
  }
}
