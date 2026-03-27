import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead.freezed.dart';
part 'lead.g.dart';

@freezed
class Lead with _$Lead {
  const factory Lead({
    required String id,
    required String title,
    required String name,
    String? company,
    String? email,
    String? phone,
    required String source,
    required String status,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'estimated_value') double? estimatedValue,
    String? notes,
    @JsonKey(name: 'converted_at') DateTime? convertedAt,
  }) = _Lead;

  factory Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);
}
