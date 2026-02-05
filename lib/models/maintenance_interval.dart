/// Represents maintenance interval configuration for a specific maintenance type
class MaintenanceInterval {
  final int? id;
  final int machineId;
  final String maintenanceType; // 'oil_change', 'filter_cleaning', 'chain_oiling', etc.
  final double? intervalDistance; // km or hours
  final int? intervalDays; // time-based interval
  final bool enabled;
  final bool notificationSent; // Track if notification was already sent for current due status

  MaintenanceInterval({
    this.id,
    required this.machineId,
    required this.maintenanceType,
    this.intervalDistance,
    this.intervalDays,
    this.enabled = true,
    this.notificationSent = false,
  });

  /// Convert MaintenanceInterval to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'machineId': machineId,
      'maintenanceType': maintenanceType,
      'intervalDistance': intervalDistance,
      'intervalDays': intervalDays,
      'enabled': enabled ? 1 : 0,
      'notificationSent': notificationSent ? 1 : 0,
    };
  }

  /// Create MaintenanceInterval from Map (database record)
  factory MaintenanceInterval.fromMap(Map<String, dynamic> map) {
    return MaintenanceInterval(
      id: map['id'] as int?,
      machineId: map['machineId'] as int,
      maintenanceType: map['maintenanceType'] as String,
      intervalDistance: map['intervalDistance'] as double?,
      intervalDays: map['intervalDays'] as int?,
      enabled: (map['enabled'] as int) == 1,
      notificationSent: (map['notificationSent'] as int?) == 1,
    );
  }

  /// Create a copy of MaintenanceInterval with updated fields
  MaintenanceInterval copyWith({
    int? id,
    int? machineId,
    String? maintenanceType,
    double? intervalDistance,
    int? intervalDays,
    bool? enabled,
    bool? notificationSent,
  }) {
    return MaintenanceInterval(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      intervalDistance: intervalDistance ?? this.intervalDistance,
      intervalDays: intervalDays ?? this.intervalDays,
      enabled: enabled ?? this.enabled,
      notificationSent: notificationSent ?? this.notificationSent,
    );
  }
}
