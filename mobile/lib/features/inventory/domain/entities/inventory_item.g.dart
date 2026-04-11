// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) =>
    _InventoryItem(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      productName: json['product_name'] as String?,
      productSku: json['product_sku'] as String?,
      productUnit: json['product_unit'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$InventoryItemToJson(_InventoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'product_name': instance.productName,
      'product_sku': instance.productSku,
      'product_unit': instance.productUnit,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
