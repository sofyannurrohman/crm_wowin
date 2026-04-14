import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/stock_transfer.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getMyInventory();
  Future<List<StockTransfer>> getTransfers({String? status});
  Future<StockTransfer> createTransfer(StockTransfer transfer);
}
