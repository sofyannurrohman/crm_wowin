import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/visit_request_entities.dart';
import '../../domain/entities/visit_activity.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_remote_data_source.dart';

import '../datasources/visit_local_data_source.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource remoteDataSource;
  final VisitLocalDataSource localDataSource;

  VisitRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, void>> checkIn(CheckInRequest request) async {
    try {
      await remoteDataSource.checkIn(request);
      return const Right(null);
    } catch (e) {
      // Fallback to offline cache
      try {
        await localDataSource.cacheCheckIn(request, request.overrideReason);
        return const Right(null);
      } catch (cacheError) {
        return Left(ServerFailure('Gagal menyimpan data kunjungan secara offline: ${cacheError.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> checkOut(CheckOutRequest request) async {
    try {
      await remoteDataSource.checkOut(request);
      return const Right(null);
    } catch (e) {
      // Fallback to offline cache
      try {
        await localDataSource.cacheCheckOut(request, request.signaturePath, request.inventoryData);
        return const Right(null);
      } catch (cacheError) {
        return Left(ServerFailure('Gagal menyimpan data check-out secara offline: ${cacheError.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, List<VisitActivity>>> getActivities({String? salesId, String? customerId, String? leadId}) async {
    try {
      final result = await remoteDataSource.getActivities(salesId: salesId, customerId: customerId, leadId: leadId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
