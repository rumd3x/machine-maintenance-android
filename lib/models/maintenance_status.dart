/// Enum for maintenance status
enum MaintenanceStatusType {
  optimal, // Everything is good
  checkSoon, // Approaching maintenance due
  overdue, // Past due for maintenance
}

/// Represents the status of a specific maintenance type for a machine
class MaintenanceStatus {
  final String maintenanceType;
  final MaintenanceStatusType status;
  final double? distanceUntilDue;
  final int? daysUntilDue;
  final DateTime? lastServiceDate;
  final double? lastServiceOdometer;

  MaintenanceStatus({
    required this.maintenanceType,
    required this.status,
    this.distanceUntilDue,
    this.daysUntilDue,
    this.lastServiceDate,
    this.lastServiceOdometer,
  });
}
