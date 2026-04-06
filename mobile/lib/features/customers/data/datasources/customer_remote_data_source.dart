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

    final dynamic responseData = response.data;
    final List? data = responseData is Map ? responseData['data'] : responseData;
    
    if (data == null) return [];
    
    return data
        .where((e) => e != null)
        .map((e) => _mapToCustomer(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Customer> getCustomerDetail(String id) async {
    final response = await _dio.get('/customers/$id');
    final dynamic dataRaw = response.data['data'] ?? response.data;
    
    if (dataRaw == null) {
      throw Exception('Data pelanggan tidak ditemukan dalam respon API');
    }

    Map<String, dynamic> data;
    if (dataRaw is Map<String, dynamic> && dataRaw.containsKey('customer')) {
      data = dataRaw['customer'] as Map<String, dynamic>;
    } else {
      data = dataRaw as Map<String, dynamic>;
    }
    
    return _mapToCustomer(data);
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    final response = await _dio.post(
      '/customers',
      data: customer.toJson(),
    );
    final dynamic responseData = response.data;
    final Map<String, dynamic> data = responseData is Map && responseData.containsKey('data') 
        ? responseData['data'] 
        : responseData;
    return _mapToCustomer(data);
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    final response = await _dio.put(
      '/customers/${customer.id}',
      data: customer.toJson(),
    );
    final dynamic responseData = response.data;
    final Map<String, dynamic> data = responseData is Map && responseData.containsKey('data') 
        ? responseData['data'] 
        : responseData;
    return _mapToCustomer(data);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _dio.delete('/customers/$id');
  }

  /// Map JSON to Customer with type safety for key fields
  Customer _mapToCustomer(Map<String, dynamic> json) {
    // Ensure critical fields are strings even if they come back as numbers
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(json);
    
    if (normalized['id'] != null) {
      normalized['id'] = normalized['id'].toString();
    }
    
    if (normalized['name'] != null) {
      normalized['name'] = normalized['name'].toString();
    } else {
      normalized['name'] = 'No Name'; // Fallback for required field
    }

    // Handle checkin_radius as int if it comes back as string or double
    if (normalized['checkin_radius'] != null) {
      if (normalized['checkin_radius'] is String) {
        normalized['checkin_radius'] = int.tryParse(normalized['checkin_radius']) ?? 0;
      } else if (normalized['checkin_radius'] is double) {
        normalized['checkin_radius'] = (normalized['checkin_radius'] as double).toInt();
      }
    }

    return Customer.fromJson(normalized);
  }
}
