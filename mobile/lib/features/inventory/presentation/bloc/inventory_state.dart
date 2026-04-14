import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/stock_transfer.dart';

part 'inventory_state.freezed.dart';

@freezed
abstract class InventoryState with _$InventoryState {
  const factory InventoryState.initial() = InventoryInitial;
  const factory InventoryState.loading() = InventoryLoading;
  const factory InventoryState.success({
    @Default([]) List<InventoryItem> items,
    @Default([]) List<StockTransfer> transfers,
    String? message,
  }) = InventorySuccess;
  const factory InventoryState.error(String message) = InventoryError;
}
