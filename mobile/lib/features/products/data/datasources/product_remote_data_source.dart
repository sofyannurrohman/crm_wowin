import 'package:dio/dio.dart';
import '../../domain/entities/product.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> getProducts({String? category, String? query});
  Future<Product> getProductDetail(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Product>> getProducts({String? category, String? query}) async {
    final Map<String, dynamic> queryParams = {};
    if (category != null) queryParams['category'] = category;
    if (query != null) queryParams['search'] = query;

    final response = await _dio.get(
      '/products',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final List data = response.data['data'];
    return data.map((e) => Product.fromJson(e)).toList();
  }

  @override
  Future<Product> getProductDetail(String id) async {
    final response = await _dio.get('/products/$id');
    return Product.fromJson(response.data['data']);
  }
}
