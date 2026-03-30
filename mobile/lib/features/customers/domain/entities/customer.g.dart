// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Customer _$CustomerFromJson(Map<String, dynamic> json) => _Customer(
      id: json['id'] as String,
      code: json['code'] as String?,
      name: json['name'] as String,
      companyName: json['company_name'] as String?,
      type: json['type'] as String?,
      industry: json['industry'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      checkinRadius: (json['checkin_radius'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CustomerToJson(_Customer instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'company_name': instance.companyName,
      'type': instance.type,
      'industry': instance.industry,
      'email': instance.email,
      'phone': instance.phone,
      'status': instance.status,
      'address': instance.address,
      'city': instance.city,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'checkin_radius': instance.checkinRadius,
    };
