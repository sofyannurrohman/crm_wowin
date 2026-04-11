import 'package:freezed_annotation/freezed_annotation.dart';
import 'visit_recommendation.dart';

part 'kpi_summary.freezed.dart';
part 'kpi_summary.g.dart';

@freezed
abstract class KpiSummary with _$KpiSummary {
  const factory KpiSummary({
    @JsonKey(name: 'total_sales') required double totalSales,
    @JsonKey(name: 'new_leads') required int newLeads,
    @JsonKey(name: 'active_deals') required int activeDeals,
    @JsonKey(name: 'visits_today') required int visitsToday,
    @JsonKey(name: 'target_met_percentage') required double targetMetPercentage,
    @JsonKey(name: 'monthly_revenue') required double monthlyRevenue,
    @JsonKey(name: 'monthly_target') required double monthlyTarget,
    @JsonKey(name: 'visits_target') required int visitsTarget,
    @JsonKey(name: 'next_stop') VisitRecommendation? nextStop,
  }) = _KpiSummary;

  factory KpiSummary.fromJson(Map<String, dynamic> json) =>
      _$KpiSummaryFromJson(json);
}
