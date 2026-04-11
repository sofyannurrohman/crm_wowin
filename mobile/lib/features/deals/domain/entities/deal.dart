import 'package:freezed_annotation/freezed_annotation.dart';
import 'deal_item.dart';
import '../../../customers/domain/entities/customer.dart';

part 'deal.freezed.dart';
part 'deal.g.dart';

@freezed
abstract class Deal with _$Deal {
  const factory Deal({
    required String id,
    required String title,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'lead_id') String? leadId,
    @JsonKey(name: 'contact_id') String? contactId,
    required String stage,
    required String status,
    double? amount,
    int? probability,
    @JsonKey(name: 'expected_close') DateTime? expectedClose,
    String? description,
    List<DealItem>? items,
    Customer? customer,
    @JsonKey(name: 'sales_id') String? salesId,
    @JsonKey(name: 'salesman_name') String? salesmanName,
  }) = _Deal;

  factory Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);
}
