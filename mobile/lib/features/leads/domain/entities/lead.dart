import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead.freezed.dart';
part 'lead.g.dart';

@freezed
abstract class Lead with _$Lead {
  const factory Lead({
    required String id,
    required String title,
    required String name,
    @JsonKey(name: 'company_name') String? company,
    String? email,
    String? phone,
    required String source,
    required String status,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'estimated_value') double? estimatedValue,
    @JsonKey(name: 'potential_products') List<String>? potentialProducts,
    String? notes,
    @JsonKey(name: 'converted_at') DateTime? convertedAt,
    double? latitude,
    double? longitude,
  }) = _Lead;

  factory Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);
}
