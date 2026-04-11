import 'package:dio/dio.dart';
import '../../domain/entities/inventory_item.dart';

abstract class InventoryRemoteDataSource {
  Future<List<InventoryItem>> getMyInventory();
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
}
