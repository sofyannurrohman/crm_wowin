import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class LocalDbHelper {
  static final LocalDbHelper _instance = LocalDbHelper._internal();
  factory LocalDbHelper() => _instance;
  LocalDbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'wowin_offline.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table for pending check-ins
    await db.execute('''
      CREATE TABLE pending_check_ins(
        id TEXT PRIMARY KEY,
        schedule_id TEXT,
        latitude REAL,
        longitude REAL,
        photo_path TEXT,
        selfie_photo_path TEXT,
        notes TEXT,
        deal_id TEXT,
        override_reason TEXT,
        created_at TEXT
      )
    ''');

    // Table for pending check-outs
    await db.execute('''
      CREATE TABLE pending_check_outs(
        id TEXT PRIMARY KEY,
        schedule_id TEXT,
        latitude REAL,
        longitude REAL,
        visit_result TEXT,
        next_action TEXT,
        next_visit_date TEXT,
        signature_path TEXT,
        inventory_json TEXT,
        created_at TEXT
      )
    ''');
  }

  // Generic methods
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await database;
    return await db.query(table, orderBy: 'created_at ASC');
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
