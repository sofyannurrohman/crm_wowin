import 'package:dio/dio.dart';
import '../../domain/entities/deal.dart';
import '../../domain/entities/deal_item.dart';

abstract class DealRemoteDataSource {
  Future<List<Deal>> getDeals();
  Future<Deal> getDeal(String id);
  Future<Deal> updateDealStage(String id, String stage);
  Future<List<DealItem>> getDealItems(String dealId);
  Future<DealItem> addDealItem(Map<String, dynamic> data);
  Future<void> removeDealItem(String id);
}

class DealRemoteDataSourceImpl implements DealRemoteDataSource {
  final Dio _dio;

  DealRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Deal>> getDeals() async {
    final response = await _dio.get('/deals');
    final List data = response.data['data'];
    return data.map((e) => Deal.fromJson(e)).toList();
  }

  @override
  Future<Deal> getDeal(String id) async {
    final response = await _dio.get('/deals/$id');
    final data = response.data['data'];
    final Map<String, dynamic> dealPart = data['deal'];
    if (data['customer'] != null) {
      dealPart['customer'] = data['customer'];
    }
    return Deal.fromJson(dealPart);
  }

  @override
  Future<Deal> updateDealStage(String id, String stage) async {
    final response = await _dio.patch(
      '/deals/$id/stage',
      data: {'stage': stage},
    );
    return Deal.fromJson(response.data['data']);
  }

  @override
  Future<List<DealItem>> getDealItems(String dealId) async {
    final response = await _dio.get('/deals/$dealId/items');
    final List data = response.data['data'];
    return data.map((e) => DealItem.fromJson(e)).toList();
  }

  @override
  Future<DealItem> addDealItem(Map<String, dynamic> data) async {
    final response = await _dio.post('/deal-items', data: data);
    return DealItem.fromJson(response.data['data']);
  }

  @override
  Future<void> removeDealItem(String id) async {
    await _dio.delete('/deal-items/$id');
  }
}
