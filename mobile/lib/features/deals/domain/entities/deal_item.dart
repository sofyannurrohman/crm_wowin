import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal_item.freezed.dart';
part 'deal_item.g.dart';

@freezed
abstract class DealItem with _$DealItem {
  const factory DealItem({
    required String id,
    @JsonKey(name: 'deal_id') required String dealId,
    @JsonKey(name: 'product_id') required String productId,
    required int quantity,
    @JsonKey(name: 'unit_price') required double unitPrice,
    required double discount,
    required double subtotal,
    String? notes,
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'product_sku') String? productSku,
  }) = _DealItem;

  factory DealItem.fromJson(Map<String, dynamic> json) =>
      _$DealItemFromJson(json);
}
