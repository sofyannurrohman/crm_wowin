import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/sales_activity.dart';
import '../../domain/repositories/sales_activity_repository.dart';
import '../datasources/sales_activity_remote_data_source.dart';
import '../models/sales_activity_model.dart';

class SalesActivityRepositoryImpl implements SalesActivityRepository {
  final SalesActivityRemoteDataSource remoteDataSource;

  SalesActivityRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SalesActivity>>> getActivities({
    String? salesId,
    String? leadId,
    String? customerId,
    String? dealId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final remoteActivities = await remoteDataSource.getActivities(
        salesId: salesId,
        leadId: leadId,
        customerId: customerId,
        dealId: dealId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(remoteActivities.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SalesActivity>> createActivity(SalesActivity activity) async {
    try {
      final model = SalesActivityModel.fromEntity(activity);
      final createdModel = await remoteDataSource.createActivity(model);
      return Right(createdModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SalesActivity>> updateActivity(SalesActivity activity) async {
    try {
      final model = SalesActivityModel.fromEntity(activity);
      final updatedModel = await remoteDataSource.updateActivity(model);
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteActivity(String id) async {
    try {
      await remoteDataSource.deleteActivity(id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
