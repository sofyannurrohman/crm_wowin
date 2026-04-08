import 'package:equatable/equatable.dart';
import 'task_destination.dart';
import 'warehouse.dart';

enum TaskStatus { pending, in_progress, done, cancelled }

class Task extends Equatable {
  final String id;
  final String salesId;
  final String? customerId;
  final String? customerName;
  final String? warehouseId;
  final Warehouse? warehouse;
  final String title;
  final String description;
  final List<TaskDestination> destinations;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.salesId,
    this.customerId,
    this.customerName,
    this.warehouseId,
    this.warehouse,
    required this.title,
    required this.description,
    this.destinations = const [],
    required this.status,
    this.dueDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        salesId,
        customerId,
        customerName,
        warehouseId,
        warehouse,
        title,
        description,
        destinations,
        status,
        dueDate,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
