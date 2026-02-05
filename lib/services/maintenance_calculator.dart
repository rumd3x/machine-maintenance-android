import '../models/machine.dart';
import '../models/maintenance_record.dart';
import '../models/maintenance_interval.dart';
import '../models/maintenance_status.dart';
import '../utils/constants.dart';

/// Service to calculate maintenance status based on intervals and usage
class MaintenanceCalculator {
  /// Calculate status for a specific maintenance type
  MaintenanceStatus calculateStatus({
    required Machine machine,
    required MaintenanceInterval? interval,
    required MaintenanceRecord? lastRecord,
  }) {
    // If no interval is configured, return optimal
    if (interval == null || !interval.enabled) {
      return MaintenanceStatus(
        maintenanceType: interval?.maintenanceType ?? '',
        status: MaintenanceStatusType.optimal,
      );
    }

    // If no previous record exists, check if overdue based on current odometer
    if (lastRecord == null) {
      return _calculateWithoutHistory(machine, interval);
    }

    // Calculate based on distance/time since last service
    return _calculateWithHistory(machine, interval, lastRecord);
  }

  /// Calculate status when no maintenance history exists
  MaintenanceStatus _calculateWithoutHistory(
    Machine machine,
    MaintenanceInterval interval,
  ) {
    double? distanceUntilDue;
    int? daysUntilDue;

    // Distance-based check
    if (interval.intervalDistance != null) {
      distanceUntilDue = interval.intervalDistance! - machine.currentOdometer;
      
      if (distanceUntilDue <= 0) {
        return MaintenanceStatus(
          maintenanceType: interval.maintenanceType,
          status: MaintenanceStatusType.overdue,
          distanceUntilDue: distanceUntilDue,
        );
      }
      
      final threshold = interval.intervalDistance! * statusWarningThreshold;
      if (distanceUntilDue <= threshold) {
        return MaintenanceStatus(
          maintenanceType: interval.maintenanceType,
          status: MaintenanceStatusType.checkSoon,
          distanceUntilDue: distanceUntilDue,
        );
      }
    }

    // Time-based check (days since machine was added)
    if (interval.intervalDays != null) {
      final daysSinceCreated = DateTime.now().difference(machine.createdAt).inDays;
      daysUntilDue = interval.intervalDays! - daysSinceCreated;
      
      if (daysUntilDue <= 0) {
        return MaintenanceStatus(
          maintenanceType: interval.maintenanceType,
          status: MaintenanceStatusType.overdue,
          daysUntilDue: daysUntilDue,
        );
      }
      
      final threshold = (interval.intervalDays! * statusWarningThreshold).round();
      if (daysUntilDue <= threshold) {
        return MaintenanceStatus(
          maintenanceType: interval.maintenanceType,
          status: MaintenanceStatusType.checkSoon,
          daysUntilDue: daysUntilDue,
        );
      }
    }

    return MaintenanceStatus(
      maintenanceType: interval.maintenanceType,
      status: MaintenanceStatusType.optimal,
      distanceUntilDue: distanceUntilDue,
      daysUntilDue: daysUntilDue,
    );
  }

  /// Calculate status based on last maintenance record
  MaintenanceStatus _calculateWithHistory(
    Machine machine,
    MaintenanceInterval interval,
    MaintenanceRecord lastRecord,
  ) {
    MaintenanceStatusType worstStatus = MaintenanceStatusType.optimal;
    double? distanceUntilDue;
    int? daysUntilDue;

    // Distance-based check
    if (interval.intervalDistance != null) {
      final distanceSinceService = machine.currentOdometer - lastRecord.odometerAtService;
      distanceUntilDue = interval.intervalDistance! - distanceSinceService;
      
      final status = _getStatusFromRemaining(
        distanceUntilDue,
        interval.intervalDistance!,
      );
      
      if (status.index > worstStatus.index) {
        worstStatus = status;
      }
    }

    // Time-based check
    if (interval.intervalDays != null) {
      final daysSinceService = DateTime.now().difference(lastRecord.date).inDays;
      daysUntilDue = interval.intervalDays! - daysSinceService;
      
      final status = _getStatusFromRemaining(
        daysUntilDue.toDouble(),
        interval.intervalDays!.toDouble(),
      );
      
      if (status.index > worstStatus.index) {
        worstStatus = status;
      }
    }

    return MaintenanceStatus(
      maintenanceType: interval.maintenanceType,
      status: worstStatus,
      distanceUntilDue: distanceUntilDue,
      daysUntilDue: daysUntilDue,
      lastServiceDate: lastRecord.date,
      lastServiceOdometer: lastRecord.odometerAtService,
    );
  }

  /// Determine status based on remaining value and total interval
  MaintenanceStatusType _getStatusFromRemaining(double remaining, double total) {
    if (remaining <= 0) {
      return MaintenanceStatusType.overdue;
    }
    
    final percentRemaining = remaining / total;
    
    if (percentRemaining <= statusWarningThreshold) {
      return MaintenanceStatusType.checkSoon;
    }
    
    return MaintenanceStatusType.optimal;
  }

  /// Calculate all maintenance statuses for a machine
  Future<Map<String, MaintenanceStatus>> calculateAllStatuses({
    required Machine machine,
    required List<MaintenanceInterval> intervals,
    required List<MaintenanceRecord> records,
  }) async {
    final Map<String, MaintenanceStatus> statuses = {};

    for (final interval in intervals) {
      // Find the most recent record for this maintenance type
      MaintenanceRecord? lastRecord;
      try {
        lastRecord = records
            .where((r) => r.maintenanceType == interval.maintenanceType)
            .reduce((a, b) => a.date.isAfter(b.date) ? a : b);
      } catch (e) {
        lastRecord = null;
      }

      final status = calculateStatus(
        machine: machine,
        interval: interval,
        lastRecord: lastRecord,
      );

      statuses[interval.maintenanceType] = status;
    }

    return statuses;
  }

  /// Get overall machine health status (worst status among all maintenance types)
  MaintenanceStatusType getOverallStatus(Map<String, MaintenanceStatus> statuses) {
    if (statuses.isEmpty) {
      return MaintenanceStatusType.optimal;
    }

    MaintenanceStatusType worst = MaintenanceStatusType.optimal;
    
    for (final status in statuses.values) {
      if (status.status.index > worst.index) {
        worst = status.status;
      }
    }

    return worst;
  }

  /// Get default maintenance intervals for a new machine
  List<MaintenanceInterval> getDefaultIntervals(int machineId, String machineType) {
    final List<MaintenanceInterval> defaults = [];

    // Oil change - common for all types
    defaults.add(MaintenanceInterval(
      machineId: machineId,
      maintenanceType: maintenanceTypeOilChange,
      intervalDistance: machineType == machineTypeGenerator || machineType == machineTypeMachine
          ? 100.0 // 100 hours for machines
          : 5000.0, // 5000 km for vehicles
      intervalDays: 180, // 6 months
    ));

    // Filter cleaning
    defaults.add(MaintenanceInterval(
      machineId: machineId,
      maintenanceType: maintenanceTypeFilterCleaning,
      intervalDistance: machineType == machineTypeGenerator || machineType == machineTypeMachine
          ? 50.0
          : 10000.0,
      intervalDays: 365,
    ));

    // Chain oiling (only for motorcycles)
    if (machineType == machineTypeMotorcycle) {
      defaults.add(MaintenanceInterval(
        machineId: machineId,
        maintenanceType: maintenanceTypeChainOiling,
        intervalDistance: 500.0, // 500 km
        intervalDays: 30, // monthly
      ));
    }

    // Brake inspection (vehicles and motorcycles)
    if (machineType == machineTypeVehicle || 
        machineType == machineTypeMotorcycle ||
        machineType == machineTypeCar) {
      defaults.add(MaintenanceInterval(
        machineId: machineId,
        maintenanceType: maintenanceTypeBrakeInspection,
        intervalDistance: 10000.0,
        intervalDays: 180,
      ));
    }

    // Coolant change (vehicles)
    if (machineType == machineTypeVehicle || machineType == machineTypeCar) {
      defaults.add(MaintenanceInterval(
        machineId: machineId,
        maintenanceType: maintenanceTypeCoolant,
        intervalDistance: 40000.0,
        intervalDays: 730, // 2 years
      ));
    }

    return defaults;
  }
}
