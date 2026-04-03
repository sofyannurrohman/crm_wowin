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
    @JsonKey(name: 'activity_type') required String activityType,
    required String notes,
    @JsonKey(name: 'activity_at') required DateTime activityAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    Lead? lead,
    Customer? customer,
    Deal? deal,
  }) = _SalesActivity;

  factory SalesActivity.fromJson(Map<String, dynamic> json) =>
      _$SalesActivityFromJson(json);
}
