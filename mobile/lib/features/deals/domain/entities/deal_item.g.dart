// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DealItem _$DealItemFromJson(Map<String, dynamic> json) => _DealItem(
      id: json['id'] as String,
      dealId: json['deal_id'] as String,
      productId: json['product_id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DealItemToJson(_DealItem instance) => <String, dynamic>{
      'id': instance.id,
      'deal_id': instance.dealId,
      'product_id': instance.productId,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'unit_price': instance.unitPrice,
      'discount': instance.discount,
      'subtotal': instance.subtotal,
      'notes': instance.notes,
    };
