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
      taskDestinationId: json['task_destination_id'] as String?,
      activityType: json['activity_type'] as String,
      notes: json['description'] as String,
      activityAt:
          const DateTimeUtcConverter().fromJson(json['activity_at'] as String),
      createdAt: const DateTimeUtcNullableConverter()
          .fromJson(json['created_at'] as String?),
      updatedAt: const DateTimeUtcNullableConverter()
          .fromJson(json['updated_at'] as String?),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      checkInTime: const DateTimeUtcNullableConverter()
          .fromJson(json['check_in_time'] as String?),
      checkOutTime: const DateTimeUtcNullableConverter()
          .fromJson(json['check_out_time'] as String?),
      selfiePhotoPath: json['selfie_photo_path'] as String?,
      placePhotoPath: json['place_photo_path'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      isOffline: json['is_offline'] as bool? ?? false,
      address: json['address'] as String?,
      outcome: json['outcome'] as String?,
    );

Map<String, dynamic> _$SalesActivityModelToJson(_SalesActivityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'user_id': instance.userId,
      'lead_id': instance.leadId,
      'customer_id': instance.customerId,
      'deal_id': instance.dealId,
      'task_destination_id': instance.taskDestinationId,
      'activity_type': instance.activityType,
      'description': instance.notes,
      'activity_at': const DateTimeUtcConverter().toJson(instance.activityAt),
      'created_at':
          const DateTimeUtcNullableConverter().toJson(instance.createdAt),
      'updated_at':
          const DateTimeUtcNullableConverter().toJson(instance.updatedAt),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'check_in_time':
          const DateTimeUtcNullableConverter().toJson(instance.checkInTime),
      'check_out_time':
          const DateTimeUtcNullableConverter().toJson(instance.checkOutTime),
      'selfie_photo_path': instance.selfiePhotoPath,
      'place_photo_path': instance.placePhotoPath,
      'distance': instance.distance,
      'is_offline': instance.isOffline,
      'address': instance.address,
      'outcome': instance.outcome,
    };
