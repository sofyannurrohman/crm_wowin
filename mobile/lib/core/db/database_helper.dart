import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tracking.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE locations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  speed REAL NOT NULL,
  accuracy REAL,
  captured_at TEXT NOT NULL
)
''');
  }

  Future<void> flushDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tracking.db');
    await deleteDatabase(path);
    _database = null; // Forces reinit next call
  }
}
