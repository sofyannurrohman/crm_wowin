import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/kpi_summary.dart';
import '../../domain/entities/kpi_dashboard.dart';
import '../../../deals/domain/entities/deal.dart';
import '../../../visits/domain/entities/visit_activity.dart';

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
    final dynamic dataRaw = response.data['data'];
    if (dataRaw == null || dataRaw is! Map) {
      // Return a default set if data is missing or malformed
      return KpiDashboard(
        summary: const KpiSummary(
          totalSales: 0,
          newLeads: 0,
          activeDeals: 0,
          visitsToday: 0,
          targetMetPercentage: 0,
          monthlyRevenue: 0,
          monthlyTarget: 65000,
          visitsTarget: 150,
        ),
        daysLeft: 0,
      );
    }
    final data = dataRaw as Map<String, dynamic>;
    final summary = KpiSummary.fromJson(data);

    final hotDealsRaw = data['hot_deals'] as List?;
    final hotDeals = hotDealsRaw?.map((e) => Deal.fromJson(e)).toList() ?? [];

    final recentActivitiesRaw = data['recent_activities'] as List?;
    final recentActivities = recentActivitiesRaw?.map((e) => VisitActivity.fromJson(e)).toList() ?? [];

    return KpiDashboard(
      summary: summary,
      daysLeft: (data['days_left'] as num?)?.toInt() ?? 0,
      hotDeals: hotDeals,
      recentActivities: recentActivities,
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
