import '../../../../core/database/local_db_helper.dart';
import '../../domain/entities/visit_request_entities.dart';
import 'package:uuid/uuid.dart';

abstract class VisitLocalDataSource {
  Future<void> cacheCheckIn(CheckInRequest request, String? overrideReason);
  Future<void> cacheCheckOut(CheckOutRequest request, String? signaturePath, String? inventoryJson);
  Future<List<Map<String, dynamic>>> getPendingCheckIns();
  Future<List<Map<String, dynamic>>> getPendingCheckOuts();
  Future<void> clearCheckIn(String id);
  Future<void> clearCheckOut(String id);
}

class VisitLocalDataSourceImpl implements VisitLocalDataSource {
  final LocalDbHelper dbHelper;
  final Uuid uuid = const Uuid();

  VisitLocalDataSourceImpl(this.dbHelper);

  @override
  Future<void> cacheCheckIn(CheckInRequest request, String? overrideReason) async {
    final data = {
      'id': uuid.v4(),
      'schedule_id': request.scheduleId,
      'latitude': request.latitude,
      'longitude': request.longitude,
      'photo_path': request.photoFile.path,
      'selfie_photo_path': request.selfiePhotoFile?.path,
      'notes': request.checkInNotes,
      'deal_id': request.dealId,
      'override_reason': overrideReason,
      'created_at': DateTime.now().toIso8601String(),
    };
    await dbHelper.insert('pending_check_ins', data);
  }

  @override
  Future<void> cacheCheckOut(CheckOutRequest request, String? signaturePath, String? inventoryJson) async {
    final data = {
      'id': uuid.v4(),
      'schedule_id': request.scheduleId,
      'latitude': request.latitude,
      'longitude': request.longitude,
      'visit_result': request.visitResult,
      'next_action': request.nextAction,
      'next_visit_date': request.nextVisitDate,
      'signature_path': signaturePath,
      'inventory_json': inventoryJson,
      'created_at': DateTime.now().toIso8601String(),
    };
    await dbHelper.insert('pending_check_outs', data);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingCheckIns() => dbHelper.query('pending_check_ins');

  @override
  Future<List<Map<String, dynamic>>> getPendingCheckOuts() => dbHelper.query('pending_check_outs');

  @override
  Future<void> clearCheckIn(String id) => dbHelper.delete('pending_check_ins', id);

  @override
  Future<void> clearCheckOut(String id) => dbHelper.delete('pending_check_outs', id);
}
