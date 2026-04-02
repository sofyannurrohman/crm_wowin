import 'package:dio/dio.dart';
import '../../domain/entities/lead.dart';

abstract class LeadRemoteDataSource {
  Future<List<Lead>> getLeads({String? query, String? status});
  Future<Lead> updateLeadStatus(String id, String status);
  Future<Lead> createLead(Lead lead);
  Future<Lead> updateLead(Lead lead);
  Future<void> deleteLead(String id);
  Future<void> convertLead(String id);
}

class LeadRemoteDataSourceImpl implements LeadRemoteDataSource {
  final Dio _dio;

  LeadRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Lead>> getLeads({String? query, String? status}) async {
    final queryParams = <String, dynamic>{};
    if (query != null && query.isNotEmpty) queryParams['search'] = query;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final response = await _dio.get(
      '/leads',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final List? data = response.data['data'];
    if (data == null) return [];
    return data.map((e) => Lead.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Lead> updateLeadStatus(String id, String status) async {
    final response = await _dio.patch(
      '/leads/$id',
      data: {'status': status},
    );
    return Lead.fromJson(response.data['data']);
  }

  @override
  Future<Lead> createLead(Lead lead) async {
    final response = await _dio.post(
      '/leads',
      data: lead.toJson(),
    );
    return Lead.fromJson(response.data['data']);
  }

  @override
  Future<Lead> updateLead(Lead lead) async {
    final response = await _dio.put(
      '/leads/${lead.id}',
      data: lead.toJson(),
    );
    return Lead.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteLead(String id) async {
    await _dio.delete('/leads/$id');
  }

  @override
  Future<void> convertLead(String id) async {
    await _dio.post('/leads/$id/convert');
  }
}
