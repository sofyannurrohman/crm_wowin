// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SalesActivity _$SalesActivityFromJson(Map<String, dynamic> json) =>
    _SalesActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      userId: json['user_id'] as String,
      leadId: json['lead_id'] as String?,
      customerId: json['customer_id'] as String?,
      dealId: json['deal_id'] as String?,
      activityType: json['activity_type'] as String,
      notes: json['notes'] as String,
      activityAt: DateTime.parse(json['activity_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      lead: json['lead'] == null
          ? null
          : Lead.fromJson(json['lead'] as Map<String, dynamic>),
      customer: json['customer'] == null
          ? null
          : Customer.fromJson(json['customer'] as Map<String, dynamic>),
      deal: json['deal'] == null
          ? null
          : Deal.fromJson(json['deal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SalesActivityToJson(_SalesActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'user_id': instance.userId,
      'lead_id': instance.leadId,
      'customer_id': instance.customerId,
      'deal_id': instance.dealId,
      'activity_type': instance.activityType,
      'notes': instance.notes,
      'activity_at': instance.activityAt.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'lead': instance.lead,
      'customer': instance.customer,
      'deal': instance.deal,
    };
