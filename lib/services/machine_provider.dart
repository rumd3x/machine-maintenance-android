import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../models/maintenance_record.dart';
import '../models/maintenance_interval.dart';
import '../services/database_service.dart';

class MachineProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
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
}
