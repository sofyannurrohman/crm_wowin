import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kpi_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetKpiSummary {
  final DashboardRepository repository;

  GetKpiSummary(this.repository);

  Future<Either<Failure, KpiSummary>> call() async {
    return await repository.getKpiSummary();
  }
}
