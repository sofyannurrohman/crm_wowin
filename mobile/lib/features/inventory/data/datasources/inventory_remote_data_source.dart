import 'package:dio/dio.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/stock_transfer.dart';

abstract class InventoryRemoteDataSource {
  Future<List<InventoryItem>> getMyInventory();
  Future<List<StockTransfer>> getTransfers({String? status});
  Future<StockTransfer> createTransfer(StockTransfer transfer);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final Dio dio;

  InventoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<InventoryItem>> getMyInventory() async {
    try {
      final response = await dio.get('/inventory/me');
      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => InventoryItem.fromJson(json)).toList();
      }
      throw Exception('Failed to load inventory');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<StockTransfer>> getTransfers({String? status}) async {
    try {
      final response = await dio.get('/inventory/transfers', queryParameters: {
        if (status != null) 'status': status,
      });
      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => StockTransfer.fromJson(json)).toList();
      }
      throw Exception('Failed to load transfers');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StockTransfer> createTransfer(StockTransfer transfer) async {
    try {
      final response = await dio.post('/inventory/transfers', data: transfer.toJson());
      if (response.statusCode == 201) {
        return StockTransfer.fromJson(response.data['data']);
      }
      throw Exception('Failed to create transfer');
    } catch (e) {
      rethrow;
    }
  }
}
