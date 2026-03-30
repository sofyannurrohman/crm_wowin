import 'package:equatable/equatable.dart';

enum TaskPriority { LOW, MEDIUM, HIGH }
enum TaskStatus { TODO, IN_PROGRESS, COMPLETED, CANCELLED }

class Task extends Equatable {
  final String id;
  final String salesId;
  final String? customerId;
  final String? customerName;
  final String title;
  final String description;
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
    required this.title,
    required this.description,
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
        title,
        description,
        priority,
        status,
        dueDate,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
