import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/visit_request_entities.dart';

abstract class VisitRemoteDataSource {
  Future<void> checkIn(CheckInRequest request);
  Future<void> checkOut(CheckOutRequest request);
}

class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  final Dio dio;

  VisitRemoteDataSourceImpl(this.dio);

  @override
  Future<void> checkIn(CheckInRequest request) async {
    try {
      final fileName = request.photoFile.path.split('/').last;
      
      final formData = FormData.fromMap({
        'visit_schedule_id': request.scheduleId,
        'activity_type': 'check_in',
        'latitude': request.latitude,
        'longitude': request.longitude,
        'notes': request.checkInNotes,
        'photo': await MultipartFile.fromFile(
          request.photoFile.path,
          filename: fileName,
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
         throw ServerException(e.response?.data['message'] ?? 'Kesalahan validasi data');
      }
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<void> checkOut(CheckOutRequest request) async {
    try {
      final data = {
        'visit_schedule_id': request.scheduleId,
        'activity_type': 'check_out',
        'latitude': request.latitude,
        'longitude': request.longitude,
        'visit_result': request.visitResult,
        'next_action': request.nextAction,
        'next_visit_date': request.nextVisitDate,
      };

      final response = await dio.post(
        ApiEndpoints.visitActivities,
        data: data,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(response.data['message'] ?? 'Check-out gagal');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }
}
