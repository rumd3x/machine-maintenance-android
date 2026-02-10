// App version - single source of truth for display purposes
// Note: pubspec.yaml version is used for build/packaging
const String appVersion = '0.0.1';
const int appBuildNumber = 4;

// Maintenance types
const String maintenanceTypeOilChange = 'oil_change';
const String maintenanceTypeFilterCleaning = 'filter_cleaning';
const String maintenanceTypeChainOiling = 'chain_oiling';
const String maintenanceTypeBrakeFluid = 'brake_fluid_change';
const String maintenanceTypeCoolant = 'coolant_change';
const String maintenanceTypeSparkPlug = 'spark_plug_change';
const String maintenanceTypeBrakeInspection = 'brake_inspection';
const String maintenanceTypeGeneral = 'general_maintenance';
const String maintenanceTypeFuel = 'fuel';
const String maintenanceTypeFrontTires = 'front_tires';
const String maintenanceTypeRearTires = 'rear_tires';
const String maintenanceTypeBeltsChains = 'belts_chains';
const String maintenanceTypeBattery = 'battery';

// Maintenance type display names
const Map<String, String> maintenanceTypeNames = {
  maintenanceTypeOilChange: 'Oil Change',
  maintenanceTypeFilterCleaning: 'Filter Cleaning',
  maintenanceTypeChainOiling: 'Chain Oiling',
  maintenanceTypeBrakeFluid: 'Brake Fluid',
  maintenanceTypeCoolant: 'Coolant',
  maintenanceTypeSparkPlug: 'Spark Plug',
  maintenanceTypeBrakeInspection: 'Brakes',
  maintenanceTypeGeneral: 'General Service',
  maintenanceTypeFuel: 'Fuel',
  maintenanceTypeFrontTires: 'Front Tires',
  maintenanceTypeRearTires: 'Rear Tires',
  maintenanceTypeBeltsChains: 'Belts/Chains',
  maintenanceTypeBattery: 'Battery',
};

// Machine types
const String machineTypeVehicle = 'vehicle';
const String machineTypeMachine = 'machine';
const String machineTypeGenerator = 'generator';
const String machineTypeMotorcycle = 'motorcycle';
const String machineTypeCar = 'car';

// Machine type display names
const Map<String, String> machineTypeNames = {
  machineTypeVehicle: 'Vehicle',
  machineTypeMachine: 'Machine',
  machineTypeGenerator: 'Generator',
  machineTypeMotorcycle: 'Motorcycle',
  machineTypeCar: 'Car',
};

// Odometer units
const String odometerUnitKm = 'km';
const String odometerUnitHours = 'hours';

// Status thresholds
const double statusOptimalThreshold = 0.7; // 70% of interval remaining
const double statusWarningThreshold = 0.3; // 30% of interval remaining
// Below warning threshold = overdue
