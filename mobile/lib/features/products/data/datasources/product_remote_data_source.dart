import 'package:dio/dio.dart';
import '../../domain/entities/product.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> getProducts({String? category, String? query});
  Future<Product> getProductDetail(String id);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Product>> getProducts({String? category, String? query}) async {
    final Map<String, dynamic> queryParams = {};
    if (category != null) queryParams['category_id'] = category;
    if (query != null) queryParams['search'] = query;
    queryParams['is_active'] = 'true'; // Salesmen only see active products

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

  @override
  Future<Product> createProduct(Product product) async {
    final response = await _dio.post('/products', data: {
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'unit': product.unit,
      'sku': product.sku,
      'category_id': product.categoryId,
      'is_active': product.isActive,
    });
    return Product.fromJson(response.data['data']);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final response = await _dio.put('/products/${product.id}', data: {
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'unit': product.unit,
      'sku': product.sku,
      'category_id': product.categoryId,
      'is_active': product.isActive,
    });
    return Product.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _dio.delete('/products/$id');
  }
}

