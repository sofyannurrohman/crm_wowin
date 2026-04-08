import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/sales_activity.dart';

part 'sales_activity_model.freezed.dart';
part 'sales_activity_model.g.dart';

class DateTimeUtcConverter implements JsonConverter<DateTime, String> {
  const DateTimeUtcConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json).toLocal();

  @override
  String toJson(DateTime date) => date.toUtc().toIso8601String();
}

class DateTimeUtcNullableConverter implements JsonConverter<DateTime?, String?> {
  const DateTimeUtcNullableConverter();

  @override
  DateTime? fromJson(String? json) => json != null ? DateTime.parse(json).toLocal() : null;

  @override
  String? toJson(DateTime? date) => date?.toUtc().toIso8601String();
}

@freezed
abstract class SalesActivityModel with _$SalesActivityModel {
  const SalesActivityModel._();

  const factory SalesActivityModel({
    required String id,
    required String title,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'lead_id') String? leadId,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'deal_id') String? dealId,
    @JsonKey(name: 'task_destination_id') String? taskDestinationId,
    @JsonKey(name: 'activity_type') required String activityType,
    @JsonKey(name: 'description') required String notes,
    @DateTimeUtcConverter() @JsonKey(name: 'activity_at') required DateTime activityAt,
    @DateTimeUtcNullableConverter() @JsonKey(name: 'created_at') DateTime? createdAt,
    @DateTimeUtcNullableConverter() @JsonKey(name: 'updated_at') DateTime? updatedAt,
    double? latitude,
    double? longitude,
    @DateTimeUtcNullableConverter() @JsonKey(name: 'check_in_time') DateTime? checkInTime,
    @DateTimeUtcNullableConverter() @JsonKey(name: 'check_out_time') DateTime? checkOutTime,
    @JsonKey(name: 'selfie_photo_path') String? selfiePhotoPath,
    @JsonKey(name: 'place_photo_path') String? placePhotoPath,
    double? distance,
    @JsonKey(name: 'is_offline') @Default(false) bool isOffline,
    String? address,
    String? outcome,
  }) = _SalesActivityModel;

  factory SalesActivityModel.fromJson(Map<String, dynamic> json) =>
      _$SalesActivityModelFromJson(json);

  factory SalesActivityModel.fromEntity(SalesActivity entity) {
    return SalesActivityModel(
      id: entity.id,
      title: entity.title,
      userId: entity.userId,
      leadId: entity.leadId,
      customerId: entity.customerId,
      dealId: entity.dealId,
      taskDestinationId: entity.taskDestinationId,
      activityType: entity.activityType,
      notes: entity.notes,
      activityAt: entity.activityAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      latitude: entity.latitude,
      longitude: entity.longitude,
      checkInTime: entity.checkInTime,
      checkOutTime: entity.checkOutTime,
      selfiePhotoPath: entity.selfiePhotoPath,
      placePhotoPath: entity.placePhotoPath,
      distance: entity.distance,
      isOffline: entity.isOffline,
      address: entity.address,
      outcome: entity.outcome,
    );
  }

  SalesActivity toEntity() {
    return SalesActivity(
      id: id,
      title: title,
      userId: userId,
      leadId: leadId,
      customerId: customerId,
      dealId: dealId,
      taskDestinationId: taskDestinationId,
      activityType: activityType,
      notes: notes,
      activityAt: activityAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      latitude: latitude,
      longitude: longitude,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      selfiePhotoPath: selfiePhotoPath,
      placePhotoPath: placePhotoPath,
      distance: distance,
      isOffline: isOffline,
      address: address,
      outcome: outcome,
    );
  }
}
