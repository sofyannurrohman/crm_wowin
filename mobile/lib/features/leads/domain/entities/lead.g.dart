// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Lead _$LeadFromJson(Map<String, dynamic> json) => _Lead(
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
      potentialProducts: (json['potential_products'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
      convertedAt: json['converted_at'] == null
          ? null
          : DateTime.parse(json['converted_at'] as String),
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LeadToJson(_Lead instance) => <String, dynamic>{
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
      'potential_products': instance.potentialProducts,
      'notes': instance.notes,
      'converted_at': instance.convertedAt?.toIso8601String(),
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
