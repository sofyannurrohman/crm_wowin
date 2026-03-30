import 'package:dio/dio.dart';
import '../../domain/entities/lead.dart';

abstract class LeadRemoteDataSource {
  Future<List<Lead>> getLeads({String? status});
  Future<Lead> updateLeadStatus(String id, String status);
  Future<Lead> createLead(Lead lead);
  Future<void> convertLead(String id);
}

class LeadRemoteDataSourceImpl implements LeadRemoteDataSource {
  final Dio _dio;

  LeadRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Lead>> getLeads({String? status}) async {
    final response = await _dio.get(
      '/leads',
      queryParameters: status != null ? {'status': status} : null,
    );

    final List data = response.data['data'];
    return data.map((e) => Lead.fromJson(e)).toList();
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
  Future<void> convertLead(String id) async {
    await _dio.post('/leads/$id/convert');
  }
}
