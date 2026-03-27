import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal.freezed.dart';
part 'deal.g.dart';

@freezed
class Deal with _$Deal {
  const factory Deal({
    required String id,
    required String title,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'contact_id') String? contactId,
    required String stage,
    required String status,
    double? amount,
    int? probability,
    @JsonKey(name: 'expected_close') DateTime? expectedClose,
    String? description,
  }) = _Deal;

  factory Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);
}
