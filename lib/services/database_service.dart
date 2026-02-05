import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/machine.dart';
import '../models/maintenance_record.dart';
import '../models/maintenance_interval.dart';
import '../models/app_notification.dart';

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
      version: 3,
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
    
    if (oldVersion < 3) {
      // Create notifications table
      await db.execute('''
        CREATE TABLE notifications(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          machineId INTEGER,
          createdAt TEXT NOT NULL,
          isRead INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (machineId) REFERENCES machines (id) ON DELETE CASCADE
        )
      ''');
      
      // Create index for better query performance
      await db.execute('''
        CREATE INDEX idx_notifications_isRead 
        ON notifications(isRead)
      ''');
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

    // Create notifications table
    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        machineId INTEGER,
        createdAt TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (machineId) REFERENCES machines (id) ON DELETE CASCADE
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

    await db.execute('''
      CREATE INDEX idx_notifications_isRead 
      ON notifications(isRead)
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

  // ========== Notification CRUD Operations ==========

  Future<int> insertNotification(AppNotification notification) async {
    final db = await database;
    return await db.insert('notifications', notification.toMap());
  }

  Future<List<AppNotification>> getAllNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => AppNotification.fromMap(maps[i]));
  }

  Future<int> getUnreadNotificationCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE isRead = 0'
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> updateNotification(AppNotification notification) async {
    final db = await database;
    return await db.update(
      'notifications',
      notification.toMap(),
      where: 'id = ?',
      whereArgs: [notification.id],
    );
  }

  Future<int> markNotificationAsRead(int id) async {
    final db = await database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNotification(int id) async {
    final db = await database;
    return await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllNotifications() async {
    final db = await database;
    return await db.delete('notifications');
  }

  // ========== Utility Operations ==========

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
