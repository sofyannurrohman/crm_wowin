// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StockTransfer _$StockTransferFromJson(Map<String, dynamic> json) =>
    _StockTransfer(
      id: json['id'] as String,
      warehouseId: json['warehouse_id'] as String,
      salesId: json['sales_id'] as String,
      type: $enumDecode(_$StockTransferTypeEnumMap, json['type']),
      status: $enumDecode(_$StockTransferStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => StockTransferItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StockTransferToJson(_StockTransfer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'warehouse_id': instance.warehouseId,
      'sales_id': instance.salesId,
      'type': _$StockTransferTypeEnumMap[instance.type]!,
      'status': _$StockTransferStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'items': instance.items,
    };

const _$StockTransferTypeEnumMap = {
  StockTransferType.loading: 'loading',
  StockTransferType.unloading: 'unloading',
};

const _$StockTransferStatusEnumMap = {
  StockTransferStatus.pending: 'pending',
  StockTransferStatus.confirmed: 'confirmed',
  StockTransferStatus.rejected: 'rejected',
};

_StockTransferItem _$StockTransferItemFromJson(Map<String, dynamic> json) =>
    _StockTransferItem(
      id: json['id'] as String,
      transferId: json['transfer_id'] as String,
      productId: json['product_id'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      productName: json['product_name'] as String?,
      productUnit: json['product_unit'] as String?,
    );

Map<String, dynamic> _$StockTransferItemToJson(_StockTransferItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transfer_id': instance.transferId,
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'product_name': instance.productName,
      'product_unit': instance.productUnit,
    };
