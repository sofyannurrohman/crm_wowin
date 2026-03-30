import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Task>>> getTasks({String? customerId, TaskStatus? status}) async {
    try {
      final result = await remoteDataSource.getTasks(customerId: customerId, status: status);
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
        title: task.title,
        description: task.description,
        priority: task.priority,
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
        title: task.title,
        description: task.description,
        priority: task.priority,
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
}
