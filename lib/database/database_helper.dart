import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/health_record.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'healthtrack.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_health_records_date ON health_records(date DESC, id DESC)',
          );
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE health_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        weight REAL,
        height REAL,
        bloodPressure TEXT,
        heartRate INTEGER,
        notes TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_health_records_date ON health_records(date DESC, id DESC)',
    );
  }

  Future<int> insertHealthRecord(HealthRecord record) async {
    final db = await database;
    return db.insert('health_records', record.toMap());
  }

  Future<int> getHealthRecordCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) AS total FROM health_records');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<HealthRecord?> getLatestHealthRecord() async {
    final records = await getRecentHealthRecords(limit: 1);
    return records.isEmpty ? null : records.first;
  }

  Future<List<HealthRecord>> getRecentHealthRecords({int limit = 5}) async {
    final db = await database;
    final result = await db.query(
      'health_records',
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    return result.map(HealthRecord.fromMap).toList();
  }

  Future<List<HealthRecord>> getHealthRecords() async {
    final db = await database;
    final result =
        await db.query('health_records', orderBy: 'date DESC, id DESC');
    return result.map(HealthRecord.fromMap).toList();
  }

  Future<HealthRecord?> getHealthRecordById(int id) async {
    final db = await database;
    final result = await db.query(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return HealthRecord.fromMap(result.first);
  }

  Future<int> updateHealthRecord(HealthRecord record) async {
    final db = await database;
    return db.update(
      'health_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteHealthRecord(int id) async {
    final db = await database;
    return db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }
}
