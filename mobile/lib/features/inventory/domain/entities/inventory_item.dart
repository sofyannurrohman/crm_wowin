import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_item.freezed.dart';
part 'inventory_item.g.dart';

@freezed
class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String id,
    @JsonKey(name: 'product_id') required String productId,
    required double quantity,
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'product_sku') String? productSku,
    @JsonKey(name: 'product_unit') String? productUnit,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) => _$InventoryItemFromJson(json);
}
