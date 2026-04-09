import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../entities/kpi_dashboard.dart';
import 'package:wowin_crm/features/tasks/domain/entities/task.dart';

abstract class DashboardRepository {
  Future<Either<Failure, KpiDashboard>> getKpiSummary();
  Future<Either<Failure, List<Map<String, dynamic>>>> getVisitRecommendations();
  Future<Either<Failure, List<Task>>> getRouteTasks({String? salesId});
}
