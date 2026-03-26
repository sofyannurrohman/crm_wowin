import 'package:dio/dio.dart';
import '../../domain/entities/deal.dart';

abstract class DealRemoteDataSource {
  Future<List<Deal>> getDeals();
  Future<Deal> updateDealStage(String id, String stage);
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
  Future<Deal> updateDealStage(String id, String stage) async {
    final response = await _dio.patch(
      '/deals/$id',
      data: {'stage': stage},
    );
    return Deal.fromJson(response.data['data']);
  }
}
