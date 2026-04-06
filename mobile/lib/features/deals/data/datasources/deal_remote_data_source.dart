import 'package:dio/dio.dart';
import '../../domain/entities/deal.dart';
import '../../domain/entities/deal_item.dart';

abstract class DealRemoteDataSource {
  Future<List<Deal>> getDeals();
  Future<Deal> getDeal(String id);
  Future<Deal> createDeal(Deal deal);
  Future<Deal> updateDeal(Deal deal);
  Future<void> deleteDeal(String id);
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
    final List data = response.data['data'] ?? [];
    return data.map((e) => Deal.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Deal> getDeal(String id) async {
    final response = await _dio.get('/deals/$id');
    final data = response.data['data'];
    
    // Some endpoints wrap the deal in a "deal" key
    final Map<String, dynamic> dealPart = data['deal'] ?? data;
    
    if (data['customer'] != null && dealPart['customer'] == null) {
      dealPart['customer'] = data['customer'];
    }
    
    return Deal.fromJson(dealPart);
  }

  @override
  Future<Deal> createDeal(Deal deal) async {
    final response = await _dio.post('/deals', data: deal.toJson());
    final data = response.data['data'];
    final Map<String, dynamic> dealPart = data['deal'] ?? data;
    return Deal.fromJson(dealPart);
  }

  @override
  Future<Deal> updateDeal(Deal deal) async {
    final response = await _dio.put('/deals/${deal.id}', data: deal.toJson());
    final data = response.data['data'];
    final Map<String, dynamic> dealPart = data['deal'] ?? data;
    return Deal.fromJson(dealPart);
  }

  @override
  Future<void> deleteDeal(String id) async {
    await _dio.delete('/deals/$id');
  }

  @override
  Future<Deal> updateDealStage(String id, String stage) async {
    final response = await _dio.patch(
      '/deals/$id/stage',
      data: {'stage': stage},
    );
    final data = response.data['data'];
    
    // Ensure we extract the deal part even if it's nested
    final Map<String, dynamic> dealData = data is Map && data.containsKey('deal') 
        ? data['deal'] 
        : (data ?? response.data);
        
    return Deal.fromJson(dealData as Map<String, dynamic>);
  }

  @override
  Future<List<DealItem>> getDealItems(String dealId) async {
    final response = await _dio.get('/deals/$dealId/items');
    final List data = response.data['data'] ?? [];
    return data.map((e) => DealItem.fromJson(e as Map<String, dynamic>)).toList();
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
