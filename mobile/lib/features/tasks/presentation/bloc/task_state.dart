import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/warehouse.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class WarehousesLoaded extends TaskState {
  final List<Warehouse> warehouses;

  const WarehousesLoaded(this.warehouses);

  @override
  List<Object?> get props => [warehouses];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;

  const TasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskOperationSuccess extends TaskState {
  final String message;

  const TaskOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
