import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kpi_dashboard.dart';

abstract class DashboardRepository {
  Future<Either<Failure, KpiDashboard>> getKpiSummary();
}
