/// Represents a vehicle or machine in the garage
class Machine {
  final int? id;
  final String type; // 'vehicle' or 'machine'
  final String brand;
  final String model;
  final String? nickname;
  final String? year;
  final String? serialNumber;
  final String? sparkPlugType;
  final String? oilType;
  final String? oilCapacity; // Oil capacity in liters
  final String? fuelType;
  final double? tankSize;
  final String? frontTiresSize; // e.g., "205/55 R16"
  final String? rearTiresSize; // e.g., "225/50 R17"
  final String? imagePath;
  final double currentOdometer; // km for vehicles, hours for machines
  final String odometerUnit; // 'km' or 'hours'
  final DateTime createdAt;
  final DateTime updatedAt;

  Machine({
    this.id,
    required this.type,
    required this.brand,
    required this.model,
    this.nickname,
    this.year,
    this.serialNumber,
    this.sparkPlugType,
    this.oilType,
    this.oilCapacity,
    this.fuelType,
    this.tankSize,
    this.frontTiresSize,
    this.rearTiresSize,
    this.imagePath,
    required this.currentOdometer,
    required this.odometerUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert Machine to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'brand': brand,
      'model': model,
      'nickname': nickname,
      'year': year,
      'serialNumber': serialNumber,
      'sparkPlugType': sparkPlugType,
      'oilType': oilType,
      'oilCapacity': oilCapacity,
      'fuelType': fuelType,
      'tankSize': tankSize,
      'frontTiresSize': frontTiresSize,
      'rearTiresSize': rearTiresSize,
      'imagePath': imagePath,
      'currentOdometer': currentOdometer,
      'odometerUnit': odometerUnit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create Machine from Map (database record)
  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(
      id: map['id'] as int?,
      type: map['type'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      nickname: map['nickname'] as String?,
      year: map['year'] as String?,
      serialNumber: map['serialNumber'] as String?,
      sparkPlugType: map['sparkPlugType'] as String?,
      oilType: map['oilType'] as String?,
      oilCapacity: map['oilCapacity'] as String?,
      fuelType: map['fuelType'] as String?,
      tankSize: map['tankSize'] as double?,
      frontTiresSize: map['frontTiresSize'] as String?,
      rearTiresSize: map['rearTiresSize'] as String?,
      imagePath: map['imagePath'] as String?,
      currentOdometer: map['currentOdometer'] as double,
      odometerUnit: map['odometerUnit'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Create a copy of Machine with updated fields
  Machine copyWith({
    int? id,
    String? type,
    String? brand,
    String? model,
    String? nickname,
    String? year,
    String? serialNumber,
    String? sparkPlugType,
    String? oilType,
    String? oilCapacity,
    String? fuelType,
    double? tankSize,
    String? frontTiresSize,
    String? rearTiresSize,
    String? imagePath,
    double? currentOdometer,
    String? odometerUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Machine(
      id: id ?? this.id,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      nickname: nickname ?? this.nickname,
      year: year ?? this.year,
      serialNumber: serialNumber ?? this.serialNumber,
      sparkPlugType: sparkPlugType ?? this.sparkPlugType,
      oilType: oilType ?? this.oilType,
      oilCapacity: oilCapacity ?? this.oilCapacity,
      fuelType: fuelType ?? this.fuelType,
      tankSize: tankSize ?? this.tankSize,
      frontTiresSize: frontTiresSize ?? this.frontTiresSize,
      rearTiresSize: rearTiresSize ?? this.rearTiresSize,
      imagePath: imagePath ?? this.imagePath,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      odometerUnit: odometerUnit ?? this.odometerUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display name (nickname or model)
  String get displayName => nickname ?? model;
}
