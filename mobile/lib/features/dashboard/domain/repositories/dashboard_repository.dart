import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kpi_summary.dart';

abstract class DashboardRepository {
  Future<Either<Failure, KpiSummary>> getKpiSummary();
}
