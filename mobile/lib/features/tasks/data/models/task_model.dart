import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.salesId,
    super.customerId,
    super.customerName,
    required super.title,
    required super.description,
    required super.priority,
    required super.status,
    super.dueDate,
    super.completedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      salesId: json['sales_id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      title: json['title'],
      description: json['description'] ?? '',
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.MEDIUM,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.TODO,
      ),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sales_id': salesId,
      'customer_id': customerId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
