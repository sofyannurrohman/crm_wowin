import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/sales_activity.dart';

part 'sales_activity_model.freezed.dart';
part 'sales_activity_model.g.dart';

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
    @JsonKey(name: 'activity_type') required String activityType,
    @JsonKey(name: 'description') required String notes,
    @JsonKey(name: 'activity_at') required DateTime activityAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
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
      activityType: entity.activityType,
      notes: entity.notes,
      activityAt: entity.activityAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
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
      activityType: activityType,
      notes: notes,
      activityAt: activityAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
