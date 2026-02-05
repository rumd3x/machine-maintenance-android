import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/machine.dart';
import '../models/maintenance_record.dart';
import '../models/maintenance_interval.dart';

/// Database service for local SQLite storage
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'machine_maintenance.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add fuelType column to machines table
      await db.execute('ALTER TABLE machines ADD COLUMN fuelType TEXT');
      
      // Add fuelAmount column to maintenance_records table
      await db.execute('ALTER TABLE maintenance_records ADD COLUMN fuelAmount REAL');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create machines table
    await db.execute('''
      CREATE TABLE machines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        nickname TEXT,
        year TEXT,
        serialNumber TEXT,
        sparkPlugType TEXT,
        oilType TEXT,
        fuelType TEXT,
        tankSize REAL,
        imagePath TEXT,
        currentOdometer REAL NOT NULL,
        odometerUnit TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create maintenance_records table
    await db.execute('''
      CREATE TABLE maintenance_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        machineId INTEGER NOT NULL,
        maintenanceType TEXT NOT NULL,
        date TEXT NOT NULL,
        odometerAtService REAL NOT NULL,
        fuelAmount REAL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (machineId) REFERENCES machines (id) ON DELETE CASCADE
      )
    ''');

    // Create maintenance_intervals table
    await db.execute('''
      CREATE TABLE maintenance_intervals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        machineId INTEGER NOT NULL,
        maintenanceType TEXT NOT NULL,
        intervalDistance REAL,
        intervalDays INTEGER,
        enabled INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (machineId) REFERENCES machines (id) ON DELETE CASCADE,
        UNIQUE(machineId, maintenanceType)
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_maintenance_records_machineId 
      ON maintenance_records(machineId)
    ''');

    await db.execute('''
      CREATE INDEX idx_maintenance_intervals_machineId 
      ON maintenance_intervals(machineId)
    ''');
  }

  // ========== Machine CRUD Operations ==========

  Future<int> insertMachine(Machine machine) async {
    final db = await database;
    return await db.insert('machines', machine.toMap());
  }

  Future<List<Machine>> getAllMachines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'machines',
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => Machine.fromMap(maps[i]));
  }

  Future<Machine?> getMachine(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'machines',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Machine.fromMap(maps.first);
  }

  Future<int> updateMachine(Machine machine) async {
    final db = await database;
    return await db.update(
      'machines',
      machine.toMap(),
      where: 'id = ?',
      whereArgs: [machine.id],
    );
  }

  Future<int> deleteMachine(int id) async {
    final db = await database;
    return await db.delete(
      'machines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== Maintenance Record CRUD Operations ==========

  Future<int> insertMaintenanceRecord(MaintenanceRecord record) async {
    final db = await database;
    return await db.insert('maintenance_records', record.toMap());
  }

  Future<List<MaintenanceRecord>> getMaintenanceRecords(int machineId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'maintenance_records',
      where: 'machineId = ?',
      whereArgs: [machineId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => MaintenanceRecord.fromMap(maps[i]));
  }

  Future<MaintenanceRecord?> getLastMaintenanceRecord(
    int machineId,
    String maintenanceType,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'maintenance_records',
      where: 'machineId = ? AND maintenanceType = ?',
      whereArgs: [machineId, maintenanceType],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MaintenanceRecord.fromMap(maps.first);
  }

  Future<int> updateMaintenanceRecord(MaintenanceRecord record) async {
    final db = await database;
    return await db.update(
      'maintenance_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteMaintenanceRecord(int id) async {
    final db = await database;
    return await db.delete(
      'maintenance_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== Maintenance Interval CRUD Operations ==========

  Future<int> insertMaintenanceInterval(MaintenanceInterval interval) async {
    final db = await database;
    return await db.insert(
      'maintenance_intervals',
      interval.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MaintenanceInterval>> getMaintenanceIntervals(int machineId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'maintenance_intervals',
      where: 'machineId = ?',
      whereArgs: [machineId],
    );
    return List.generate(maps.length, (i) => MaintenanceInterval.fromMap(maps[i]));
  }

  Future<MaintenanceInterval?> getMaintenanceInterval(
    int machineId,
    String maintenanceType,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'maintenance_intervals',
      where: 'machineId = ? AND maintenanceType = ?',
      whereArgs: [machineId, maintenanceType],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MaintenanceInterval.fromMap(maps.first);
  }

  Future<int> updateMaintenanceInterval(MaintenanceInterval interval) async {
    final db = await database;
    return await db.update(
      'maintenance_intervals',
      interval.toMap(),
      where: 'id = ?',
      whereArgs: [interval.id],
    );
  }

  Future<int> deleteMaintenanceInterval(int id) async {
    final db = await database;
    return await db.delete(
      'maintenance_intervals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== Utility Operations ==========

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
