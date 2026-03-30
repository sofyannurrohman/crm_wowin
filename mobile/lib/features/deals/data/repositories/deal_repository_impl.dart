import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/deal.dart';
import '../../domain/entities/deal_item.dart';
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
  Future<Either<Failure, Deal>> getDealDetail(String id) async {
    try {
      final deal = await remoteDataSource.getDeal(id);
      return Right(deal);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal mengambil detail deal'));
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

  @override
  Future<Either<Failure, List<DealItem>>> getDealItems(String dealId) async {
    try {
      final items = await remoteDataSource.getDealItems(dealId);
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal mengambil item deal'));
    }
  }

  @override
  Future<Either<Failure, DealItem>> addDealItem({
    required String dealId,
    required String productId,
    required int quantity,
    required double price,
    double discount = 0,
    String? notes,
  }) async {
    try {
      final item = await remoteDataSource.addDealItem({
        'deal_id': dealId,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': price,
        'discount': discount,
        'notes': notes,
      });
      return Right(item);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal menambahkan item ke deal'));
    }
  }

  @override
  Future<Either<Failure, void>> removeDealItem(String id) async {
    try {
      await remoteDataSource.removeDealItem(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal menghapus item deal'));
    }
  }
}
