import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_transfer.freezed.dart';
part 'stock_transfer.g.dart';

enum StockTransferType {
  @JsonValue('loading')
  loading,
  @JsonValue('unloading')
  unloading,
}

enum StockTransferStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('rejected')
  rejected,
}

@freezed
abstract class StockTransfer with _$StockTransfer {
  const factory StockTransfer({
    required String id,
    @JsonKey(name: 'warehouse_id') required String warehouseId,
    @JsonKey(name: 'sales_id') required String salesId,
    required StockTransferType type,
    required StockTransferStatus status,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @Default([]) List<StockTransferItem> items,
  }) = _StockTransfer;

  factory StockTransfer.fromJson(Map<String, dynamic> json) => _$StockTransferFromJson(json);
}

@freezed
abstract class StockTransferItem with _$StockTransferItem {
  const factory StockTransferItem({
    required String id,
    @JsonKey(name: 'transfer_id') required String transferId,
    @JsonKey(name: 'product_id') required String productId,
    required double quantity,
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'product_unit') String? productUnit,
  }) = _StockTransferItem;

  factory StockTransferItem.fromJson(Map<String, dynamic> json) => _$StockTransferItemFromJson(json);
}
