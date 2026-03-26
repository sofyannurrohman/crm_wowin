// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeadImpl _$$LeadImplFromJson(Map<String, dynamic> json) => _$LeadImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      name: json['name'] as String,
      company: json['company'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      source: json['source'] as String,
      status: json['status'] as String,
      customerId: json['customer_id'] as String?,
      estimatedValue: (json['estimated_value'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      convertedAt: json['converted_at'] == null
          ? null
          : DateTime.parse(json['converted_at'] as String),
    );

Map<String, dynamic> _$$LeadImplToJson(_$LeadImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'name': instance.name,
      'company': instance.company,
      'email': instance.email,
      'phone': instance.phone,
      'source': instance.source,
      'status': instance.status,
      'customer_id': instance.customerId,
      'estimated_value': instance.estimatedValue,
      'notes': instance.notes,
      'converted_at': instance.convertedAt?.toIso8601String(),
    };
