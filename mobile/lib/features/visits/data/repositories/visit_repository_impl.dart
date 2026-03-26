import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/visit_request_entities.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_remote_data_source.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource remoteDataSource;

  VisitRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> checkIn(CheckInRequest request) async {
    try {
      await remoteDataSource.checkIn(request);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan yang tidak terduga saat Check-in'));
    }
  }

  @override
  Future<Either<Failure, void>> checkOut(CheckOutRequest request) async {
    try {
      await remoteDataSource.checkOut(request);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan yang tidak terduga saat Check-out'));
    }
  }
}
