// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kpi_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KpiSummary _$KpiSummaryFromJson(Map<String, dynamic> json) => _KpiSummary(
  totalSales: (json['total_sales'] as num).toDouble(),
  newLeads: (json['new_leads'] as num).toInt(),
  activeDeals: (json['active_deals'] as num).toInt(),
  visitsToday: (json['visits_today'] as num).toInt(),
  targetMetPercentage: (json['target_met_percentage'] as num).toDouble(),
  monthlyRevenue: (json['monthly_revenue'] as num).toDouble(),
  monthlyTarget: (json['monthly_target'] as num).toDouble(),
  visitsTarget: (json['visits_target'] as num).toInt(),
  todayBooking: (json['today_booking'] as num).toDouble(),
  todayCollection: (json['today_collection'] as num).toDouble(),
  totalBooking: (json['total_booking'] as num).toDouble(),
  totalCollection: (json['total_collection'] as num).toDouble(),
  nextStop: json['next_stop'] == null
      ? null
      : VisitRecommendation.fromJson(json['next_stop'] as Map<String, dynamic>),
);

Map<String, dynamic> _$KpiSummaryToJson(_KpiSummary instance) =>
    <String, dynamic>{
      'total_sales': instance.totalSales,
      'new_leads': instance.newLeads,
      'active_deals': instance.activeDeals,
      'visits_today': instance.visitsToday,
      'target_met_percentage': instance.targetMetPercentage,
      'monthly_revenue': instance.monthlyRevenue,
      'monthly_target': instance.monthlyTarget,
      'visits_target': instance.visitsTarget,
      'today_booking': instance.todayBooking,
      'today_collection': instance.todayCollection,
      'total_booking': instance.totalBooking,
      'total_collection': instance.totalCollection,
      'next_stop': instance.nextStop,
    };
