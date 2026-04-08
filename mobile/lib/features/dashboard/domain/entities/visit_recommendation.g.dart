// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VisitRecommendation _$VisitRecommendationFromJson(Map<String, dynamic> json) =>
    _VisitRecommendation(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      reason: json['reason'] as String,
      lastVisitAt: json['last_visit_at'] as String?,
      daysSinceLast: (json['days_since_last'] as num).toInt(),
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$VisitRecommendationToJson(
        _VisitRecommendation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'status': instance.status,
      'priority': instance.priority,
      'reason': instance.reason,
      'last_visit_at': instance.lastVisitAt,
      'days_since_last': instance.daysSinceLast,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
