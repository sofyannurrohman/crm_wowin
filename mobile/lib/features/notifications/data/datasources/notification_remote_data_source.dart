import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSource(this.dio);

  Future<List<NotificationModel>> getNotifications({int limit = 20, int offset = 0}) async {
    final response = await dio.get(
      ApiEndpoints.notifications,
      queryParameters: {'limit': limit, 'offset': offset},
    );

    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil notifikasi');
    }
  }

  Future<int> getUnreadCount() async {
    final response = await dio.get(ApiEndpoints.unreadCount);
    if (response.statusCode == 200) {
      return response.data['data']['unread_count'];
    }
    return 0;
  }

  Future<void> markAsRead(String id) async {
    await dio.patch('${ApiEndpoints.notifications}/$id/read');
  }

  Future<void> markAllAsRead() async {
    await dio.patch('${ApiEndpoints.notifications}/read-all');
  }
}
