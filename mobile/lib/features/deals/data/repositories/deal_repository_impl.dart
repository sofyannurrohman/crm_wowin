import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/deal.dart';
import '../../domain/repositories/deal_repository.dart';
import '../datasources/deal_remote_data_source.dart';

class DealRepositoryImpl implements DealRepository {
  final DealRemoteDataSource remoteDataSource;

  DealRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Deal>>> getDeals() async {
    try {
      final deals = await remoteDataSource.getDeals();
      return Right(deals);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal mengambil data deals'));
    }
  }

  @override
  Future<Either<Failure, Deal>> updateDealStage(String id, String stage) async {
    try {
      final deal = await remoteDataSource.updateDealStage(id, stage);
      return Right(deal);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal memperbarui tahapan deal'));
    }
  }
}
