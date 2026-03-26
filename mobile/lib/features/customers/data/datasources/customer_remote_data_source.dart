import 'package:dio/dio.dart';
import '../../domain/entities/customer.dart';

abstract class CustomerRemoteDataSource {
  Future<List<Customer>> getCustomers({String? query});
  Future<Customer> getCustomerDetail(String id);
  Future<Customer> createCustomer(Customer customer);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final Dio _dio;

  CustomerRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Customer>> getCustomers({String? query}) async {
    final response = await _dio.get(
      '/customers',
      queryParameters: query != null ? {'q': query} : null,
    );
    
    final List data = response.data['data'];
    return data.map((e) => Customer.fromJson(e)).toList();
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
}
