import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskBloc({required this.repository}) : super(TaskInitial()) {
    on<FetchTasks>(_onFetchTasks);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<CompleteTask>(_onCompleteTask);
    on<DeleteTask>(_onDeleteTask);
    on<FetchWarehouses>(_onFetchWarehouses);
  }

  Future<void> _onFetchWarehouses(FetchWarehouses event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await repository.getWarehouses();
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (warehouses) => emit(WarehousesLoaded(warehouses)),
    );
  }

  Future<void> _onFetchTasks(FetchTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await repository.getTasks(
      customerId: event.customerId,
      salesId: event.salesId,
      status: event.status,
    );
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TasksLoaded(tasks)),
    );
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await repository.createTask(event.task);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (task) {
        emit(const TaskOperationSuccess('Tugas berhasil dibuat'));
        add(const FetchTasks());
      },
    );
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await repository.updateTask(event.task);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (task) {
        emit(const TaskOperationSuccess('Tugas berhasil diperbarui'));
        add(const FetchTasks());
      },
    );
  }

  Future<void> _onCompleteTask(CompleteTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await repository.completeTask(event.id);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) {
        emit(const TaskOperationSuccess('Tugas selesai!'));
        add(const FetchTasks());
      },
    );
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await repository.deleteTask(event.id);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) {
        emit(const TaskOperationSuccess('Tugas dihapus'));
        add(const FetchTasks());
      },
    );
  }
}
