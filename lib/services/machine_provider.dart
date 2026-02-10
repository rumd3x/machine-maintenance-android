import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../models/maintenance_record.dart';
import '../models/maintenance_interval.dart';
import '../models/maintenance_status.dart';
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
      final newMachine = machine.copyWith(
        id: id,
        type: machine.type,
        brand: machine.brand,
        model: machine.model,
        nickname: machine.nickname,
        year: machine.year,
        serialNumber: machine.serialNumber,
        sparkPlugType: machine.sparkPlugType,
        sparkPlugGap: machine.sparkPlugGap,
        oilType: machine.oilType,
        oilCapacity: machine.oilCapacity,
        fuelType: machine.fuelType,
        tankSize: machine.tankSize,
        frontTiresSize: machine.frontTiresSize,
        rearTiresSize: machine.rearTiresSize,
        frontTirePressure: machine.frontTirePressure,
        rearTirePressure: machine.rearTirePressure,
        batteryVoltage: machine.batteryVoltage,
        batteryCapacity: machine.batteryCapacity,
        batteryType: machine.batteryType,
        imagePath: machine.imagePath,
        currentOdometer: machine.currentOdometer,
        odometerUnit: machine.odometerUnit,
        createdAt: machine.createdAt,
        updatedAt: machine.updatedAt,
      );
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
        
        // Calculate all statuses to check which are no longer overdue
        final statuses = await _calculator.calculateAllStatuses(
          machine: machine,
          intervals: intervals,
          records: records,
        );
        
        // Find maintenance types that are NOT overdue (optimal or checkSoon)
        // Reset flag so they can notify again if they become overdue later
        final notOverdueMaintenanceTypes = statuses.entries
            .where((entry) => entry.value.status != MaintenanceStatusType.overdue)
            .map((entry) => entry.key)
            .toList();
        
        // Reset notification flags for maintenance types that are not overdue
        if (notOverdueMaintenanceTypes.isNotEmpty) {
          await _databaseService.resetNotificationFlagsForOkIntervals(
            record.machineId,
            notOverdueMaintenanceTypes,
          );
          debugPrint('Reset notification flags for non-overdue: ${notOverdueMaintenanceTypes.join(", ")}');
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

  /// Delete maintenance record and recalculate maintenance statuses
  Future<void> deleteMaintenanceRecord(int recordId) async {
    try {
      // Get the record before deleting to know which machine it belongs to
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'maintenance_records',
        where: 'id = ?',
        whereArgs: [recordId],
      );
      
      if (maps.isEmpty) {
        throw Exception('Maintenance record not found');
      }
      
      final record = MaintenanceRecord.fromMap(maps.first);
      final machineId = record.machineId;
      
      // Delete the record
      await _databaseService.deleteMaintenanceRecord(recordId);
      notifyListeners();
      
      // Recalculate maintenance statuses and reschedule notifications
      final machine = getMachine(machineId);
      if (machine != null) {
        final intervals = await getMaintenanceIntervals(machineId);
        final records = await getMaintenanceRecords(machineId);
        
        // Calculate all statuses
        final statuses = await _calculator.calculateAllStatuses(
          machine: machine,
          intervals: intervals,
          records: records,
        );
        
        // Check if any maintenance types are now due (not optimal)
        // This will trigger notifications for overdue maintenance
        await _scheduleNotificationsForMachine(machine);
        
        debugPrint('Deleted maintenance record $recordId and recalculated statuses');
      }
    } catch (e) {
      debugPrint('Error deleting maintenance record: $e');
      rethrow;
    }
  }

  /// Update an existing maintenance record
  Future<void> updateMaintenanceRecord(MaintenanceRecord record) async {
    try {
      await _databaseService.updateMaintenanceRecord(record);
      notifyListeners();
      
      // Recalculate maintenance statuses and reschedule notifications
      final machine = getMachine(record.machineId);
      if (machine != null) {
        final intervals = await getMaintenanceIntervals(record.machineId);
        final records = await getMaintenanceRecords(record.machineId);
        
        // Calculate all statuses
        final statuses = await _calculator.calculateAllStatuses(
          machine: machine,
          intervals: intervals,
          records: records,
        );
        
        // Reschedule notifications based on updated maintenance
        await _scheduleNotificationsForMachine(machine);
        
        debugPrint('Updated maintenance record ${record.id} and recalculated statuses');
      }
    } catch (e) {
      debugPrint('Error updating maintenance record: $e');
      rethrow;
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

  /// Delete a maintenance interval
  Future<void> deleteMaintenanceInterval(int intervalId, int machineId) async {
    try {
      await _databaseService.deleteMaintenanceInterval(intervalId);
      notifyListeners();
      
      // Reschedule notifications after interval deletion
      final machine = getMachine(machineId);
      if (machine != null) {
        await _scheduleNotificationsForMachine(machine);
      }
    } catch (e) {
      debugPrint('Error deleting maintenance interval: $e');
      rethrow;
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
