import 'package:equatable/equatable.dart';
import 'task_destination.dart';
import 'warehouse.dart';

enum TaskPriority { LOW, MEDIUM, HIGH }
enum TaskStatus { TODO, IN_PROGRESS, COMPLETED, CANCELLED }

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
  final TaskPriority priority;
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
    required this.priority,
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
        priority,
        status,
        dueDate,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
