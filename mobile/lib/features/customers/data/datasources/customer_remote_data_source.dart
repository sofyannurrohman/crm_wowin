import 'package:dio/dio.dart';
import '../../domain/entities/customer.dart';

abstract class CustomerRemoteDataSource {
  Future<List<Customer>> getCustomers({String? query, String? status});
  Future<Customer> getCustomerDetail(String id);
  Future<Customer> createCustomer(Customer customer);
  Future<Customer> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final Dio _dio;

  CustomerRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Customer>> getCustomers({String? query, String? status}) async {
    final queryParams = <String, dynamic>{};
    if (query != null && query.isNotEmpty) queryParams['search'] = query;
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }

    final response = await _dio.get(
      '/customers',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final List? data = response.data['data'];
    if (data == null) return [];
    return data.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Customer> getCustomerDetail(String id) async {
    final response = await _dio.get('/customers/$id');
    return Customer.fromJson(response.data['data']);
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    final response = await _dio.post(
      '/customers',
      data: customer.toJson(),
    );
    return Customer.fromJson(response.data['data']);
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    final response = await _dio.put(
      '/customers/${customer.id}',
      data: customer.toJson(),
    );
    return Customer.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _dio.delete('/customers/$id');
  }
}
