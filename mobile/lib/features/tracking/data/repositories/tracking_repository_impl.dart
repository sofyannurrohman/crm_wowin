import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_local_data_source.dart';
import '../datasources/tracking_remote_data_source.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingLocalDataSource localDataSource;
  final TrackingRemoteDataSource remoteDataSource;

  TrackingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, void>> saveLocationLocal(LocationPoint point) async {
    try {
      await localDataSource.cacheLocation(point);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Gagal menyimpan koordinat lokal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> syncBufferedLocations() async {
    try {
      final unsyncedPoints = await localDataSource.getUnsyncedLocations();
      
      if (unsyncedPoints.isEmpty) {
        return const Right(0);
      }

      await remoteDataSource.syncBatch(unsyncedPoints);
      
      // Jika sukses kirim, hapus dari lokal
      final syncedIds = unsyncedPoints.map((p) => p.id!).toList();
      await localDataSource.removeSyncedLocations(syncedIds);
      
      return Right(syncedIds.length);
    } on ServerException catch (e) {
       return Left(ServerFailure(e.message));
    } catch (e) {
       return const Left(ServerFailure('Gagal menyinkronkan data lokasi ke server'));
    }
  }
}
