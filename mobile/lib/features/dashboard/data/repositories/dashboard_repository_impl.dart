import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kpi_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, KpiSummary>> getKpiSummary() async {
    try {
      final summary = await remoteDataSource.getKpiSummary();
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal mengambil ringkasan KPI'));
    }
  }
}
