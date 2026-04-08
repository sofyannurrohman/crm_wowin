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
      taskDestinationId: json['task_destination_id'] as String?,
      activityType: json['type'] as String,
      notes: json['notes'] as String,
      activityAt: DateTime.parse(json['activity_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      checkInTime: json['check_in_time'] == null
          ? null
          : DateTime.parse(json['check_in_time'] as String),
      checkOutTime: json['check_out_time'] == null
          ? null
          : DateTime.parse(json['check_out_time'] as String),
      selfiePhotoPath: json['selfie_photo_path'] as String?,
      placePhotoPath: json['place_photo_path'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      isOffline: json['is_offline'] as bool? ?? false,
      address: json['address'] as String?,
      outcome: json['outcome'] as String?,
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
      'task_destination_id': instance.taskDestinationId,
      'type': instance.activityType,
      'notes': instance.notes,
      'activity_at': instance.activityAt.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'check_in_time': instance.checkInTime?.toIso8601String(),
      'check_out_time': instance.checkOutTime?.toIso8601String(),
      'selfie_photo_path': instance.selfiePhotoPath,
      'place_photo_path': instance.placePhotoPath,
      'distance': instance.distance,
      'is_offline': instance.isOffline,
      'address': instance.address,
      'outcome': instance.outcome,
      'lead': instance.lead,
      'customer': instance.customer,
      'deal': instance.deal,
    };
