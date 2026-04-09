import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';
import '../models/task_destination_model.dart';
import '../models/warehouse_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Task>>> getTasks({String? customerId, String? salesId, TaskStatus? status}) async {
    try {
      final result = await remoteDataSource.getTasks(customerId: customerId, salesId: salesId, status: status);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      final model = TaskModel(
        id: task.id,
        salesId: task.salesId,
        customerId: task.customerId,
        customerName: task.customerName,
        warehouseId: task.warehouseId,
        warehouse: task.warehouse != null ? WarehouseModel(
          id: task.warehouse!.id,
          name: task.warehouse!.name,
          address: task.warehouse!.address,
          latitude: task.warehouse!.latitude,
          longitude: task.warehouse!.longitude,
        ) : null,
        title: task.title,
        description: task.description,
        destinations: task.destinations.map((e) => TaskDestinationModel(
          id: e.id,
          taskId: e.taskId,
          leadId: e.leadId,
          customerId: e.customerId,
          dealId: e.dealId,
          sequenceOrder: e.sequenceOrder,
          status: e.status,
          createdAt: e.createdAt,
          updatedAt: e.updatedAt,
          targetName: e.targetName,
          targetAddress: e.targetAddress,
          targetLatitude: e.targetLatitude,
          targetLongitude: e.targetLongitude,
          dealTitle: e.dealTitle,
        )).toList(),
        status: task.status,
        dueDate: task.dueDate,
        completedAt: task.completedAt,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );
      final result = await remoteDataSource.createTask(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      final model = TaskModel(
        id: task.id,
        salesId: task.salesId,
        customerId: task.customerId,
        customerName: task.customerName,
        warehouseId: task.warehouseId,
        warehouse: task.warehouse != null ? WarehouseModel(
          id: task.warehouse!.id,
          name: task.warehouse!.name,
          address: task.warehouse!.address,
          latitude: task.warehouse!.latitude,
          longitude: task.warehouse!.longitude,
        ) : null,
        title: task.title,
        description: task.description,
        destinations: task.destinations.map((e) => TaskDestinationModel(
          id: e.id,
          taskId: e.taskId,
          leadId: e.leadId,
          customerId: e.customerId,
          dealId: e.dealId,
          sequenceOrder: e.sequenceOrder,
          status: e.status,
          createdAt: e.createdAt,
          updatedAt: e.updatedAt,
          targetName: e.targetName,
          targetAddress: e.targetAddress,
          targetLatitude: e.targetLatitude,
          targetLongitude: e.targetLongitude,
          dealTitle: e.dealTitle,
        )).toList(),
        status: task.status,
        dueDate: task.dueDate,
        completedAt: task.completedAt,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );
      final result = await remoteDataSource.updateTask(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeTask(String id) async {
    try {
      await remoteDataSource.completeTask(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await remoteDataSource.deleteTask(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Warehouse>>> getWarehouses() async {
    try {
      final result = await remoteDataSource.getWarehouses();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
