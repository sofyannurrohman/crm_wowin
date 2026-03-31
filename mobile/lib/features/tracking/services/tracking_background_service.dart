import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

import '../../../../core/api/dio_client.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/db/database_helper.dart';
import '../../../../core/database/local_db_helper.dart';
import '../../visits/data/datasources/visit_local_data_source.dart';
import '../../visits/data/datasources/visit_remote_data_source.dart';
import '../../visits/data/sync/offline_sync_manager.dart';

import '../data/datasources/tracking_local_data_source.dart';
import '../data/datasources/tracking_remote_data_source.dart';
import '../data/repositories/tracking_repository_impl.dart';
import '../domain/entities/location_point.dart';

/// Nama unik untuk task WorkManager
const fetchBackgroundLocationTask = "fetchBackgroundLocationTask";
const syncPendingVisitsTask = "syncPendingVisitsTask";

@pragma('vm:entry-point') // Mandated for background execution on Flutter
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    log("Native Background Task Executed");

    try {
      // 1. Inisialisasi dependensi mentah (Karena GetIt mungkin tidak aktif di Isolate Latar Belakang)
      final tokenStorage = TokenStorage(const FlutterSecureStorage());
      final dio = DioClient().dio;
      final dbHelper = DatabaseHelper.instance;

      final localDataSource = TrackingLocalDataSource(dbHelper);
      final remoteDataSource = TrackingRemoteDataSource(dio);
      final repository = TrackingRepositoryImpl(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );

      // 2. Ambil Kordinat
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final point = LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        accuracy: position.accuracy,
        capturedAt: DateTime.now(),
      );

      // 3. Simpan ke SQLite
      await repository.saveLocationLocal(point);

      // 4. Coba Sinkronisasi Batch (Akan sukses jika ada internet)
      final syncResult = await repository.syncBufferedLocations();

      syncResult.fold(
        (l) => log("Sync Background Failed: ${l.message}"),
        (syncedCount) =>
            log("Sync Background Success. Transmitted $syncedCount points."),
      );
    } catch (e) {
      log("Background Task Error: ${e.toString()}");
      return Future.value(false);
    }

    if (taskName == syncPendingVisitsTask) {
      try {
        final localDataSource = VisitLocalDataSourceImpl(LocalDbHelper());
        final remoteDataSource = VisitRemoteDataSourceImpl(DioClient().dio);
        final syncManager = OfflineSyncManager(
          localDataSource: localDataSource,
          remoteDataSource: remoteDataSource,
        );
        await syncManager.syncPendingActivities();
        log("Sync Background: Pending visits processed.");
      } catch (e) {
        log("Sync Background Error: ${e.toString()}");
      }
    }

    return Future.value(true);
  });
}

class TrackingBackgroundService {
  static Future<void> initialize() async {
    if (kIsWeb) return;
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Ubah ke true untuk testing notif log native
    );
  }

  static Future<void> startTrackingJob() async {
    if (kIsWeb) return;
    // Memastikan izin lokasi 'Always' sebelumnya
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Perlu request Always untuk iOS & Android 10+
    if (permission == LocationPermission.whileInUse) {
      // Biasanya UI prompt khusus 'Always' dipanggil user dari in-app setting page
    }

    await Workmanager().registerPeriodicTask(
      "1", // Unique Name for location
      fetchBackgroundLocationTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> startSyncJob() async {
    if (kIsWeb) return;
    await Workmanager().registerPeriodicTask(
      "2", // Unique Name for sync
      syncPendingVisitsTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected, // Only sync when online
      ),
    );
  }

  static Future<void> stopTrackingJob() async {
    if (kIsWeb) return;
    await Workmanager().cancelAll();
  }
}
