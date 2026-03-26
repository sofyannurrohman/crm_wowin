// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kpi_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KpiSummaryImpl _$$KpiSummaryImplFromJson(Map<String, dynamic> json) =>
    _$KpiSummaryImpl(
      totalSales: (json['total_sales'] as num).toDouble(),
      newLeads: (json['new_leads'] as num).toInt(),
      activeDeals: (json['active_deals'] as num).toInt(),
      visitsToday: (json['visits_today'] as num).toInt(),
      targetMetPercentage: (json['target_met_percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$$KpiSummaryImplToJson(_$KpiSummaryImpl instance) =>
    <String, dynamic>{
      'total_sales': instance.totalSales,
      'new_leads': instance.newLeads,
      'active_deals': instance.activeDeals,
      'visits_today': instance.visitsToday,
      'target_met_percentage': instance.targetMetPercentage,
    };
