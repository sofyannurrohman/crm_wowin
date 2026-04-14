import '../../data/datasources/inventory_remote_data_source.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/stock_transfer.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<InventoryItem>> getMyInventory() {
    return remoteDataSource.getMyInventory();
  }

  @override
  Future<List<StockTransfer>> getTransfers({String? status}) {
    return remoteDataSource.getTransfers(status: status);
  }

  @override
  Future<StockTransfer> createTransfer(StockTransfer transfer) {
    return remoteDataSource.createTransfer(transfer);
  }
}
