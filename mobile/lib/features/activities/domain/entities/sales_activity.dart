import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../leads/domain/entities/lead.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../deals/domain/entities/deal.dart';

part 'sales_activity.freezed.dart';
part 'sales_activity.g.dart';

@freezed
abstract class SalesActivity with _$SalesActivity {
  const SalesActivity._();

  const factory SalesActivity({
    required String id,
    required String title,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'lead_id') String? leadId,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'deal_id') String? dealId,
    @JsonKey(name: 'task_destination_id') String? taskDestinationId,
    @JsonKey(name: 'type') required String activityType,
    required String notes,
    @JsonKey(name: 'activity_at') required DateTime activityAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'check_in_time') DateTime? checkInTime,
    @JsonKey(name: 'check_out_time') DateTime? checkOutTime,
    @JsonKey(name: 'selfie_photo_path') String? selfiePhotoPath,
    @JsonKey(name: 'place_photo_path') String? placePhotoPath,
    double? distance,
    @JsonKey(name: 'is_offline') @Default(false) bool isOffline,
    String? address,
    String? outcome,
    Lead? lead,
    Customer? customer,
    Deal? deal,
  }) = _SalesActivity;

  factory SalesActivity.fromJson(Map<String, dynamic> json) =>
      _$SalesActivityFromJson(json);
}
