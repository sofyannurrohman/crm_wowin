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
      id: json['id'] ?? '',
      salesId: json['sales_id'] ?? '',
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (json['priority'] ?? 'MEDIUM'),
        orElse: () => TaskPriority.MEDIUM,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'TODO'),
        orElse: () => TaskStatus.TODO,
      ),
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date']) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now() 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now() 
          : DateTime.now(),
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
