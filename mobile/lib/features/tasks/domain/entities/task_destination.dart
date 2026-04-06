import 'package:equatable/equatable.dart';
import 'task.dart';

class TaskDestination extends Equatable {
  final String id;
  final String taskId;
  final String? leadId;
  final String? customerId;
  final int sequenceOrder;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Joined fields
  final String? targetName;
  final double? targetLatitude;
  final double? targetLongitude;
  final String? targetAddress;

  const TaskDestination({
    required this.id,
    required this.taskId,
    this.leadId,
    this.customerId,
    required this.sequenceOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.targetName,
    this.targetLatitude,
    this.targetLongitude,
    this.targetAddress,
  });

  @override
  List<Object?> get props => [
        id,
        taskId,
        leadId,
        customerId,
        sequenceOrder,
        status,
        createdAt,
        updatedAt,
        targetName,
        targetLatitude,
        targetLongitude,
        targetAddress,
      ];
}
