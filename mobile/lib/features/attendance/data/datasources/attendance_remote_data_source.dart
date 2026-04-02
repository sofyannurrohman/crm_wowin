import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/attendance_model.dart';

class AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSource(this.dio);

  Future<AttendanceModel> clockIn({
    required List<int> photoBytes,
    required String photoName,
    required double latitude,
    required double longitude,
    String? address,
    String? notes,
  }) async {
    return _submitAttendance(
        ApiEndpoints.clockIn, photoBytes, photoName, latitude, longitude, address, notes);
  }

  Future<AttendanceModel> clockOut({
    required List<int> photoBytes,
    required String photoName,
    required double latitude,
    required double longitude,
    String? address,
    String? notes,
  }) async {
    return _submitAttendance(
        ApiEndpoints.clockOut, photoBytes, photoName, latitude, longitude, address, notes);
  }

  Future<AttendanceModel> _submitAttendance(
    String endpoint,
    List<int> photoBytes,
    String photoName,
    double latitude,
    double longitude,
    String? address,
    String? notes,
  ) async {
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(
        photoBytes,
        filename: photoName,
        contentType: MediaType('image', 'jpeg'),
      ),
      'latitude': latitude,
      'longitude': longitude,
      'address': address ?? '',
      'notes': notes ?? '',
    });

    final response = await dio.post(endpoint, data: formData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AttendanceModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Gagal memproses absensi');
    }
  }

  Future<List<AttendanceModel>> getHistory(int month, int year) async {
    final response = await dio.get(
      ApiEndpoints.attendanceHistory,
      queryParameters: {'month': month, 'year': year},
    );

    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((json) => AttendanceModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil riwayat absensi');
    }
  }
}
