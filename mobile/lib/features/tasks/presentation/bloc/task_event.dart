import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class FetchTasks extends TaskEvent {
  final String? customerId;
  final String? salesId;
  final TaskStatus? status;

  const FetchTasks({this.customerId, this.salesId, this.status});

  @override
  List<Object?> get props => [customerId, salesId, status];
}

class CreateTask extends TaskEvent {
  final Task task;

  const CreateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class CompleteTask extends TaskEvent {
  final String id;

  const CompleteTask(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteTask extends TaskEvent {
  final String id;

  const DeleteTask(this.id);

  @override
  List<Object?> get props => [id];
}

class FetchWarehouses extends TaskEvent {
  const FetchWarehouses();
}
