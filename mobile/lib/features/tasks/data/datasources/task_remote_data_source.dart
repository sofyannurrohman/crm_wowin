import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/task_model.dart';
import '../models/warehouse_model.dart';
import '../../domain/entities/task.dart';

class TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSource(this.dio);

  Future<List<TaskModel>> getTasks({String? customerId, String? salesId, TaskStatus? status}) async {
    final response = await dio.get(
      ApiEndpoints.tasks,
      queryParameters: {
        if (customerId != null) 'customer_id': customerId,
        if (salesId != null) 'sales_id': salesId,
        if (status != null) 'status': status.name,
      },
    );

    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat daftar tugas');
    }
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final response = await dio.post(
      ApiEndpoints.tasks,
      data: task.toJson(),
    );

    if (response.statusCode == 201) {
      return TaskModel.fromJson(response.data['data']);
    } else {
      throw Exception('Gagal membuat tugas');
    }
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final response = await dio.put(
      '${ApiEndpoints.tasks}/${task.id}',
      data: task.toJson(),
    );

    if (response.statusCode == 200) {
      return TaskModel.fromJson(response.data['data']);
    } else {
      throw Exception('Gagal memperbarui tugas');
    }
  }

  Future<void> completeTask(String id) async {
    final response = await dio.patch('${ApiEndpoints.tasks}/$id/complete');
    if (response.statusCode != 200) {
      throw Exception('Gagal menyelesaikan tugas');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await dio.delete('${ApiEndpoints.tasks}/$id');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Gagal menghapus tugas');
    }
  }

  Future<List<WarehouseModel>> getWarehouses() async {
    final response = await dio.get(ApiEndpoints.warehouses);
    if (response.statusCode == 200) {
      final List data = response.data; // Backend returns List directly in this handler
      return data.map((json) => WarehouseModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat daftar gudang');
    }
  }
}
