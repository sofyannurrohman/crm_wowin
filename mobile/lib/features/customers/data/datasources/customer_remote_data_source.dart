import 'package:dio/dio.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_detail_response.dart';
import 'package:wowin_crm/features/deals/domain/entities/deal.dart';
import 'package:wowin_crm/features/visits/domain/entities/visit_activity.dart';
import 'package:wowin_crm/features/visits/domain/entities/visit_schedule.dart';

abstract class CustomerRemoteDataSource {
  Future<List<Customer>> getCustomers({String? query, String? status, String? salesId});
  Future<CustomerDetailResponse> getCustomerDetail(String id);
  Future<Customer> createCustomer(Customer customer);
  Future<Customer> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final Dio _dio;

  CustomerRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Customer>> getCustomers({String? query, String? status, String? salesId}) async {
    final queryParams = <String, dynamic>{};
    if (query != null && query.isNotEmpty) queryParams['search'] = query;
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }
    if (salesId != null && salesId.isNotEmpty) {
      queryParams['sales_id'] = salesId;
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
  Future<CustomerDetailResponse> getCustomerDetail(String id) async {
    final response = await _dio.get('/customers/$id');
    final dynamic data = response.data['data'] ?? response.data;
    
    if (data == null) {
      throw Exception('Data pelanggan tidak ditemukan dalam respon API');
    }

    final customerJson = data['customer'] as Map<String, dynamic>;
    final customer = _mapToCustomer(customerJson);

    final List<VisitActivity> activities = (data['activities'] as List? ?? [])
        .map((e) => VisitActivity.fromJson(e as Map<String, dynamic>))
        .toList();

    final List<Deal> deals = (data['deals'] as List? ?? [])
        .map((e) => Deal.fromJson(e as Map<String, dynamic>))
        .toList();

    final List<VisitSchedule> schedules = (data['schedules'] as List? ?? [])
        .map((e) => VisitSchedule.fromJson(e as Map<String, dynamic>))
        .toList();

    return CustomerDetailResponse(
      customer: customer,
      activities: activities,
      deals: deals,
      schedules: schedules,
    );
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

    if (normalized['sales_id'] != null) {
      normalized['sales_id'] = normalized['sales_id'].toString();
    }
    
    if (normalized['salesman_name'] != null) {
      normalized['salesman_name'] = normalized['salesman_name'].toString();
    }

    return Customer.fromJson(normalized);
  }
}
