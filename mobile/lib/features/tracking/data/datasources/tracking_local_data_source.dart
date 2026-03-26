import 'package:sqflite/sqflite.dart';
import '../../../../core/db/database_helper.dart';
import '../../domain/entities/location_point.dart';

class TrackingLocalDataSource {
  final DatabaseHelper dbHelper;

  TrackingLocalDataSource(this.dbHelper);

  Future<void> cacheLocation(LocationPoint point) async {
    final db = await dbHelper.database;
    await db.insert(
      'locations',
      point.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocationPoint>> getUnsyncedLocations() async {
    final db = await dbHelper.database;
    // Ambil max 10 data paling awal untuk ditransmisikan
    final result = await db.query(
      'locations',
      orderBy: 'captured_at ASC',
      limit: 10,
    );
    
    return result.map((json) => LocationPoint.fromMap(json)).toList();
  }

  Future<void> removeSyncedLocations(List<int> ids) async {
    if (ids.isEmpty) return;
    
    final db = await dbHelper.database;
    await db.delete(
      'locations',
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
  }
}
