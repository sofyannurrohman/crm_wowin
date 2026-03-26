import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

import '../../../../core/api/dio_client.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/db/database_helper.dart';

import '../data/datasources/tracking_local_data_source.dart';
import '../data/datasources/tracking_remote_data_source.dart';
import '../data/repositories/tracking_repository_impl.dart';
import '../domain/entities/location_point.dart';

/// Nama unik untuk task WorkManager
const fetchBackgroundLocationTask = "fetchBackgroundLocationTask";

@pragma('vm:entry-point') // Mandated for background execution on Flutter
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    log("Native Background Task Executed");

    try {
      // 1. Inisialisasi dependensi mentah (Karena GetIt mungkin tidak aktif di Isolate Latar Belakang)
      final tokenStorage = TokenStorage(const FlutterSecureStorage());
      final dio = DioClient(tokenStorage).dio;
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
        (syncedCount) => log("Sync Background Success. Transmitted $syncedCount points."),
      );

    } catch (e) {
      log("Background Task Error: ${e.toString()}");
      return Future.value(false); // Task butuh retry oleh OS Native
    }
    
    return Future.value(true);
  });
}

class TrackingBackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Ubah ke true untuk testing notif log native
    );
  }

  static Future<void> startTrackingJob() async {
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
      "1", // Unique Name
      fetchBackgroundLocationTask,
      frequency: const Duration(minutes: 15), // OS Constraints limits min 15 minutes
      constraints: Constraints(
        networkType: NetworkType.connected, 
      ),
    );
  }

  static Future<void> stopTrackingJob() async {
    await Workmanager().cancelAll();
  }
}
