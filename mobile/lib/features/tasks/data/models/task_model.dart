import '../../domain/entities/task.dart';
import 'task_destination_model.dart';
import 'warehouse_model.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.salesId,
    super.customerId,
    super.customerName,
    super.warehouseId,
    super.warehouse,
    required super.title,
    required super.description,
    super.destinations,
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
      warehouseId: json['warehouse_id'],
      warehouse: json['warehouse'] != null ? WarehouseModel.fromJson(json['warehouse']) : null,
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      destinations: json['destinations'] != null 
          ? (json['destinations'] as List).map((e) => TaskDestinationModel.fromJson(e)).toList() 
          : [],
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
      'customer_name': customerName,
      'warehouse_id': warehouseId,
      'title': title,
      'description': description,
      'destinations': destinations.map((e) => (e as TaskDestinationModel).toJson()).toList(),
      'priority': priority.name,
      'status': status.name,
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
