import 'package:workmanager/workmanager.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import '../datasources/visit_local_data_source.dart';
import '../datasources/visit_remote_data_source.dart';
import '../../domain/entities/visit_request_entities.dart';

class OfflineSyncManager {
  static const String syncTaskName = "com.wowin.crm.sync_visits";

  final VisitLocalDataSource localDataSource;
  final VisitRemoteDataSource remoteDataSource;

  OfflineSyncManager({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      // Background sync logic will depend on how we inject dependencies here.
      // Usually requires a separate entry point or Service Locator (GetIt).
      return Future.value(true);
    });
  }

  Future<void> syncPendingActivities() async {
    final pendingCheckIns = await localDataSource.getPendingCheckIns();
    for (var data in pendingCheckIns) {
      try {
        final selfiePhotoPath = data['selfie_photo_path'] as String?;
        final request = CheckInRequest(
          scheduleId: data['schedule_id'],
          latitude: data['latitude'],
          longitude: data['longitude'],
          photoFile: XFile(data['photo_path']),
          selfiePhotoFile: selfiePhotoPath != null && selfiePhotoPath.isNotEmpty
              ? XFile(selfiePhotoPath)
              : null,
          checkInNotes: data['notes'] ?? '',
          dealId: data['deal_id'],
          overrideReason: data['override_reason'],
        );
        await remoteDataSource.checkIn(request);
        await localDataSource.clearCheckIn(data['id']);
      } catch (e) {
        // Keep in local DB if still failing
      }
    }

    final pendingCheckOuts = await localDataSource.getPendingCheckOuts();
    for (var data in pendingCheckOuts) {
      try {
        final request = CheckOutRequest(
          scheduleId: data['schedule_id'],
          latitude: data['latitude'],
          longitude: data['longitude'],
          visitResult: data['visit_result'],
          nextAction: data['next_action'],
          nextVisitDate: data['next_visit_date'] ?? '',
          signaturePath: data['signature_path'],
          inventoryData: data['inventory_json'],
        );
        await remoteDataSource.checkOut(request);
        await localDataSource.clearCheckOut(data['id']);
      } catch (e) {
        // Keep in local DB if still failing
      }
    }
  }
}
