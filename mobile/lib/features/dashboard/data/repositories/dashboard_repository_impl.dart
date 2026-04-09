import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kpi_dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

import 'package:wowin_crm/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:wowin_crm/features/tasks/domain/entities/task.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final TaskRemoteDataSource taskRemoteDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.taskRemoteDataSource,
  });

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

  @override
  Future<Either<Failure, List<Task>>> getRouteTasks({String? salesId}) async {
    try {
      final tasks = await taskRemoteDataSource.getTasks(salesId: salesId);
      return Right(tasks);
    } catch (e) {
      return Left(ServerFailure('Gagal mengambil rencana kunjungan: ${e.toString()}'));
    }
  }
}
