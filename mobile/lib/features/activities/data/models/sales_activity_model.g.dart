// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SalesActivityModel _$SalesActivityModelFromJson(Map<String, dynamic> json) =>
    _SalesActivityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      userId: json['user_id'] as String,
      leadId: json['lead_id'] as String?,
      customerId: json['customer_id'] as String?,
      dealId: json['deal_id'] as String?,
      activityType: json['activity_type'] as String,
      notes: json['description'] as String,
      activityAt: DateTime.parse(json['activity_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SalesActivityModelToJson(_SalesActivityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'user_id': instance.userId,
      'lead_id': instance.leadId,
      'customer_id': instance.customerId,
      'deal_id': instance.dealId,
      'activity_type': instance.activityType,
      'description': instance.notes,
      'activity_at': instance.activityAt.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
