import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/location_point.dart';

class TrackingRemoteDataSource {
  final Dio dio;

  TrackingRemoteDataSource(this.dio);

  Future<void> syncBatch(List<LocationPoint> points) async {
    if (points.isEmpty) return;

    final body = {
      'points': points.map((p) => p.toJsonApi()).toList(),
    };

    final response = await dio.post(
      ApiEndpoints.locationBatch,
      data: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Server menolak sinkronisasi batch log');
    }
  }
}
