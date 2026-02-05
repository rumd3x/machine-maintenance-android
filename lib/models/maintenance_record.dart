/// Represents a maintenance record for a machine
class MaintenanceRecord {
  final int? id;
  final int machineId;
  final String maintenanceType;
  final DateTime date;
  final double odometerAtService;
  final String? notes;
  final DateTime createdAt;

  MaintenanceRecord({
    this.id,
    required this.machineId,
    required this.maintenanceType,
    required this.date,
    required this.odometerAtService,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert MaintenanceRecord to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'machineId': machineId,
      'maintenanceType': maintenanceType,
      'date': date.toIso8601String(),
      'odometerAtService': odometerAtService,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create MaintenanceRecord from Map (database record)
  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    return MaintenanceRecord(
      id: map['id'] as int?,
      machineId: map['machineId'] as int,
      maintenanceType: map['maintenanceType'] as String,
      date: DateTime.parse(map['date'] as String),
      odometerAtService: map['odometerAtService'] as double,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Create a copy of MaintenanceRecord with updated fields
  MaintenanceRecord copyWith({
    int? id,
    int? machineId,
    String? maintenanceType,
    DateTime? date,
    double? odometerAtService,
    String? notes,
    DateTime? createdAt,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      date: date ?? this.date,
      odometerAtService: odometerAtService ?? this.odometerAtService,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
