import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/kpi_summary.dart';
import '../../domain/entities/kpi_dashboard.dart';

abstract class DashboardRemoteDataSource {
  Future<KpiDashboard> getKpiSummary();
  Future<List<Map<String, dynamic>>> getVisitRecommendations();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSourceImpl(this._dio);

  @override
  Future<KpiDashboard> getKpiSummary() async {
    final response = await _dio.get(ApiEndpoints.kpiSummary);
    final data = response.data['data'] as Map<String, dynamic>;
    final summary = KpiSummary.fromJson(data);
    return KpiDashboard(
      summary: summary,
      monthlyRevenue: (data['monthly_revenue'] as num?)?.toDouble() ?? 0,
      monthlyTarget: (data['monthly_target'] as num?)?.toDouble() ?? 65000,
      daysLeft: (data['days_left'] as num?)?.toInt() ?? 10,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getVisitRecommendations() async {
    try {
      final response = await _dio.get(ApiEndpoints.visitRecommendations);
      final List data = response.data['data'] ?? [];
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
