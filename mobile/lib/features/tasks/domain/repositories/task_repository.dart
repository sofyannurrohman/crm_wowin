import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../entities/task.dart';
import '../entities/warehouse.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasks({String? customerId, TaskStatus? status});
  Future<Either<Failure, Task>> createTask(Task task);
  Future<Either<Failure, Task>> updateTask(Task task);
  Future<Either<Failure, void>> completeTask(String id);
  Future<Either<Failure, void>> deleteTask(String id);
  Future<Either<Failure, List<Warehouse>>> getWarehouses();
}
