import 'kpi_summary.dart';
import '../../domain/entities/visit_recommendation.dart';
import '../../../deals/domain/entities/deal.dart';
import '../../../visits/domain/entities/visit_activity.dart';

/// Wrapper that extends KpiSummary with extra dashboard fields
/// parsed from the backend response that aren't in the freezed entity.
class KpiDashboard {
  final KpiSummary summary;
  final int daysLeft;

  final List<Deal> hotDeals;
  final List<VisitActivity> recentActivities;

  const KpiDashboard({
    required this.summary,
    required this.daysLeft,
    this.hotDeals = const [],
    this.recentActivities = const [],
  });

  // Convenience getters
  int get visitsToday => summary.visitsToday;
  int get newLeads => summary.newLeads;
  int get activeDeals => summary.activeDeals;
  double get totalSales => summary.totalSales;
  double get targetMetPercentage => summary.targetMetPercentage;
  double get monthlyRevenue => summary.monthlyRevenue;
  double get monthlyTarget => summary.monthlyTarget;
  int get visitsTarget => summary.visitsTarget;
  VisitRecommendation? get nextStop => summary.nextStop;
}
