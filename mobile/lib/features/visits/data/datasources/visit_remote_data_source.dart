import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/visit_request_entities.dart';
import '../models/visit_activity_model.dart';

abstract class VisitRemoteDataSource {
  Future<void> checkIn(CheckInRequest request);
  Future<void> checkOut(CheckOutRequest request);
  Future<List<VisitActivityModel>> getActivities({String? salesId, String? customerId, String? leadId});
}

class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  final Dio dio;

  VisitRemoteDataSourceImpl(this.dio);

  @override
  Future<List<VisitActivityModel>> getActivities({String? salesId, String? customerId, String? leadId}) async {
    final response = await dio.get(
      '/visits/activities', // Assuming unified endpoint
      queryParameters: {
        if (salesId != null) 'sales_id': salesId,
        if (customerId != null) 'customer_id': customerId,
        if (leadId != null) 'lead_id': leadId,
      },
    );

    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((json) => VisitActivityModel.fromJson(json)).toList();
    } else {
      throw ServerException('Gagal mengambil log aktivitas');
    }
  }

  @override
  Future<void> checkIn(CheckInRequest request) async {
    try {
      final formData = FormData.fromMap({
        'schedule_id': request.scheduleId == 'adhoc' ? null : request.scheduleId,
        'type': 'check-in',
        'latitude': request.latitude,
        'longitude': request.longitude,
        'notes': request.checkInNotes,
        'deal_id': request.dealId,
        'override_reason': request.overrideReason,
        'task_destination_id': request.taskDestinationId,
        'photo': await MultipartFile.fromFile(
          request.photoFile.path,
          filename: request.photoFile.path.split('/').last,
        ),
        if (request.selfiePhotoFile != null)
          'selfie_photo': await MultipartFile.fromFile(
            request.selfiePhotoFile!.path,
            filename: request.selfiePhotoFile!.path.split('/').last,
          ),
      });

      final response = await dio.post(
        ApiEndpoints.visitActivities,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(response.data['message'] ?? 'Check-in gagal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && e.response?.data != null) {
        // Detect if its a distance violation from backend (if blocking was enabled)
        // For now server handles it strictly or bypasses with warning.
        throw ServerException(
            e.response?.data['message'] ?? 'Kesalahan validasi data');
      }
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<void> checkOut(CheckOutRequest request) async {
    try {
      final formMap = <String, dynamic>{
        'schedule_id': request.scheduleId == 'adhoc' ? null : request.scheduleId,
        'type': 'check-out',
        'latitude': request.latitude,
        'longitude': request.longitude,
        'visit_result': request.visitResult,
        'next_action': request.nextAction,
        'next_visit_date': request.nextVisitDate,
        'inventory_data': request.inventoryData,
        'task_destination_id': request.taskDestinationId,
        'deal_id': request.dealId,
      };

      // Attach signature image if captured
      if (request.signaturePath != null && request.signaturePath!.isNotEmpty) {
        formMap['signature_photo'] = await MultipartFile.fromFile(
          request.signaturePath!,
          filename: request.signaturePath!.split('/').last,
        );
      }

      final formData = FormData.fromMap(formMap);

      final response = await dio.post(
        ApiEndpoints.visitActivities,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(response.data['message'] ?? 'Check-out gagal');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }
}
