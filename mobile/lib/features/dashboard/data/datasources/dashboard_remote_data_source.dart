import 'package:dio/dio.dart';
import '../../domain/entities/kpi_summary.dart';

abstract class DashboardRemoteDataSource {
  Future<KpiSummary> getKpiSummary();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSourceImpl(this._dio);

  @override
  Future<KpiSummary> getKpiSummary() async {
    final response = await _dio.get('/dashboard/kpis');
    return KpiSummary.fromJson(response.data['data']);
  }
}
