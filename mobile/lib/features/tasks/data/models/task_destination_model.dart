import '../../domain/entities/task.dart';
import '../../domain/entities/task_destination.dart';

class TaskDestinationModel extends TaskDestination {
  const TaskDestinationModel({
    required super.id,
    required super.taskId,
    super.leadId,
    super.customerId,
    super.dealId,
    required super.sequenceOrder,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.targetName,
    super.targetAddress,
    super.targetLatitude,
    super.targetLongitude,
    super.dealTitle,
  });

  factory TaskDestinationModel.fromJson(Map<String, dynamic> json) {
    return TaskDestinationModel(
      id: json['id'] ?? '',
      taskId: json['task_id'] ?? '',
      leadId: json['lead_id'],
      customerId: json['customer_id'],
      dealId: json['deal_id'],
      sequenceOrder: json['sequence_order'] ?? 0,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => TaskStatus.pending,
      ),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now() 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now() 
          : DateTime.now(),
      targetName: json['target_name'],
      targetAddress: json['target_address'],
      targetLatitude: json['target_latitude'] != null ? (json['target_latitude'] as num).toDouble() : null,
      targetLongitude: json['target_longitude'] != null ? (json['target_longitude'] as num).toDouble() : null,
      dealTitle: json['deal_title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'lead_id': leadId,
      'customer_id': customerId,
      'deal_id': dealId,
      'sequence_order': sequenceOrder,
      'status': status.name,
    };
  }
}
