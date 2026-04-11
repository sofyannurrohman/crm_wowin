import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal_item.freezed.dart';
part 'deal_item.g.dart';

@freezed
abstract class DealItem with _$DealItem {
  const DealItem._();

  const factory DealItem({
    required String id,
    @JsonKey(name: 'deal_id') String? dealId,
    @JsonKey(name: 'product_id') required String productId,
    required String name,
    required double quantity,
    required String unit,
    @JsonKey(name: 'unit_price') required double unitPrice,
    required double discount,
    required double subtotal,
    String? notes,
  }) = _DealItem;

  double get price => unitPrice;

  factory DealItem.fromJson(Map<String, dynamic> json) =>
      _$DealItemFromJson(json);
}
