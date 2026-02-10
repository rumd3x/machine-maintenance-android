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
  final String? sparkPlugGap; // Spark plug gap in mm (e.g., "0.7", "0.8-0.9")
  final String? oilType;
  final String? oilCapacity; // Oil capacity in liters
  final String? fuelType;
  final double? tankSize;
  final String? frontTiresSize; // e.g., "205/55 R16"
  final String? rearTiresSize; // e.g., "225/50 R17"
  final String? frontTirePressure; // PSI (e.g., "32", "30-32")
  final String? rearTirePressure; // PSI (e.g., "36", "34-36")
  final String? batteryVoltage; // Volts (e.g., "12", "12.6")
  final String? batteryCapacity; // Amp-hours (e.g., "50", "100")
  final String? batteryType; // Battery model/type (e.g., "HTZ7L")
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
    this.sparkPlugGap,
    this.oilType,
    this.oilCapacity,
    this.fuelType,
    this.tankSize,
    this.frontTiresSize,
    this.rearTiresSize,
    this.frontTirePressure,
    this.rearTirePressure,
    this.batteryVoltage,
    this.batteryCapacity,
    this.batteryType,
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
      'sparkPlugGap': sparkPlugGap,
      'oilType': oilType,
      'oilCapacity': oilCapacity,
      'fuelType': fuelType,
      'tankSize': tankSize,
      'frontTiresSize': frontTiresSize,
      'rearTiresSize': rearTiresSize,
      'frontTirePressure': frontTirePressure,
      'rearTirePressure': rearTirePressure,
      'batteryVoltage': batteryVoltage,
      'batteryCapacity': batteryCapacity,
      'batteryType': batteryType,
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
      sparkPlugGap: map['sparkPlugGap'] as String?,
      oilType: map['oilType'] as String?,
      oilCapacity: map['oilCapacity'] as String?,
      fuelType: map['fuelType'] as String?,
      tankSize: map['tankSize'] as double?,
      frontTiresSize: map['frontTiresSize'] as String?,
      rearTiresSize: map['rearTiresSize'] as String?,
      frontTirePressure: map['frontTirePressure'] as String?,
      rearTirePressure: map['rearTirePressure'] as String?,
      batteryVoltage: map['batteryVoltage'] as String?,
      batteryCapacity: map['batteryCapacity'] as String?,
      batteryType: map['batteryType'] as String?,
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
    String? sparkPlugGap,
    String? oilType,
    String? oilCapacity,
    String? fuelType,
    double? tankSize,
    String? frontTiresSize,
    String? rearTiresSize,
    String? frontTirePressure,
    String? rearTirePressure,
    String? batteryVoltage,
    String? batteryCapacity,
    String? batteryType,
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
      nickname: nickname,  // Allow clearing to null
      year: year,  // Allow clearing to null
      serialNumber: serialNumber,  // Allow clearing to null
      sparkPlugType: sparkPlugType,  // Allow clearing to null
      sparkPlugGap: sparkPlugGap,  // Allow clearing to null
      oilType: oilType,  // Allow clearing to null
      oilCapacity: oilCapacity,  // Allow clearing to null
      fuelType: fuelType,  // Allow clearing to null
      tankSize: tankSize,  // Allow clearing to null
      frontTiresSize: frontTiresSize,  // Allow clearing to null
      rearTiresSize: rearTiresSize,  // Allow clearing to null
      frontTirePressure: frontTirePressure,  // Allow clearing to null
      rearTirePressure: rearTirePressure,  // Allow clearing to null
      batteryVoltage: batteryVoltage,  // Allow clearing to null
      batteryCapacity: batteryCapacity,  // Allow clearing to null
      batteryType: batteryType,  // Allow clearing to null
      imagePath: imagePath,  // Allow clearing to null
      currentOdometer: currentOdometer ?? this.currentOdometer,
      odometerUnit: odometerUnit ?? this.odometerUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display name (nickname or model)
  String get displayName => nickname ?? model;
}
