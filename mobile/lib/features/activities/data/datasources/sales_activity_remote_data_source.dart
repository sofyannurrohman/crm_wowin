import 'package:dio/dio.dart';
import '../models/sales_activity_model.dart';

abstract class SalesActivityRemoteDataSource {
  Future<List<SalesActivityModel>> getActivities({
    String? salesId,
    String? leadId,
    String? customerId,
    String? dealId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<SalesActivityModel> createActivity(SalesActivityModel activity);
  
  Future<SalesActivityModel> updateActivity(SalesActivityModel activity);
  
  Future<void> deleteActivity(String id);
}

class SalesActivityRemoteDataSourceImpl implements SalesActivityRemoteDataSource {
  final Dio _dio;

  SalesActivityRemoteDataSourceImpl(this._dio);

  @override
  Future<List<SalesActivityModel>> getActivities({
    String? salesId,
    String? leadId,
    String? customerId,
    String? dealId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (salesId != null) queryParams['sales_id'] = salesId;
    if (leadId != null) queryParams['lead_id'] = leadId;
    if (customerId != null) queryParams['customer_id'] = customerId;
    if (dealId != null) queryParams['deal_id'] = dealId;
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    final response = await _dio.get(
      '/activities',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final dynamic responseData = response.data;
    final List? data = responseData is Map ? responseData['data'] : responseData;
    
    if (data == null) return [];
    return data.map((e) => SalesActivityModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<SalesActivityModel> createActivity(SalesActivityModel activity) async {
    final response = await _dio.post(
      '/activities',
      data: activity.toJson(),
    );
    final dynamic responseData = response.data;
    final Map<String, dynamic> data = responseData is Map && responseData.containsKey('data') 
        ? responseData['data'] 
        : responseData;
        
    return SalesActivityModel.fromJson(data);
  }

  @override
  Future<SalesActivityModel> updateActivity(SalesActivityModel activity) async {
    final response = await _dio.put(
      '/activities/${activity.id}',
      data: activity.toJson(),
    );
    final dynamic responseData = response.data;
    final Map<String, dynamic> data = responseData is Map && responseData.containsKey('data') 
        ? responseData['data'] 
        : responseData;

    return SalesActivityModel.fromJson(data);
  }

  @override
  Future<void> deleteActivity(String id) async {
    await _dio.delete('/activities/$id');
  }
}
