import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kpi_dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, KpiDashboard>> getKpiSummary() async {
    try {
      final dashboard = await remoteDataSource.getKpiSummary();
      return Right(dashboard);
    } catch (_) {
      return const Left(ServerFailure('Gagal mengambil ringkasan KPI'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getVisitRecommendations() async {
    try {
      final recommendations = await remoteDataSource.getVisitRecommendations();
      return Right(recommendations);
    } catch (_) {
      return const Left(ServerFailure('Gagal mengambil rekomendasi kunjungan'));
    }
  }
}
