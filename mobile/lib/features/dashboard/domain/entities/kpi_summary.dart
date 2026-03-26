import 'package:freezed_annotation/freezed_annotation.dart';

part 'kpi_summary.freezed.dart';
part 'kpi_summary.g.dart';

@freezed
class KpiSummary with _$KpiSummary {
  const factory KpiSummary({
    @JsonKey(name: 'total_sales') required double totalSales,
    @JsonKey(name: 'new_leads') required int newLeads,
    @JsonKey(name: 'active_deals') required int activeDeals,
    @JsonKey(name: 'visits_today') required int visitsToday,
    @JsonKey(name: 'target_met_percentage') required double targetMetPercentage,
  }) = _KpiSummary;

  factory KpiSummary.fromJson(Map<String, dynamic> json) =>
      _$KpiSummaryFromJson(json);
}
