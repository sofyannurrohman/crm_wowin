import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/stock_transfer.dart';

part 'inventory_event.freezed.dart';

@freezed
abstract class InventoryEvent with _$InventoryEvent {
  const factory InventoryEvent.fetchInventory() = FetchInventory;
  const factory InventoryEvent.fetchTransfers({String? status}) = FetchTransfers;
  const factory InventoryEvent.submitStockTransfer(StockTransfer transfer) = SubmitStockTransfer;
}
