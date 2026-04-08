import 'package:equatable/equatable.dart';
import 'task.dart';

class TaskDestination extends Equatable {
  final String id;
  final String taskId;
  final String? leadId;
  final String? customerId;
  final String? dealId;
  final int sequenceOrder;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Joined fields
  final String? targetName;
  final String? targetAddress;
  final double? targetLatitude;
  final double? targetLongitude;
  final String? dealTitle;

  const TaskDestination({
    required this.id,
    required this.taskId,
    this.leadId,
    this.customerId,
    this.dealId,
    required this.sequenceOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.targetName,
    this.targetAddress,
    this.targetLatitude,
    this.targetLongitude,
    this.dealTitle,
  });

  TaskDestination copyWith({
    String? id,
    String? taskId,
    String? leadId,
    String? customerId,
    String? dealId,
    int? sequenceOrder,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? targetName,
    String? targetAddress,
    double? targetLatitude,
    double? targetLongitude,
    String? dealTitle,
  }) {
    return TaskDestination(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      leadId: leadId ?? this.leadId,
      customerId: customerId ?? this.customerId,
      dealId: dealId ?? this.dealId,
      sequenceOrder: sequenceOrder ?? this.sequenceOrder,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      targetName: targetName ?? this.targetName,
      targetAddress: targetAddress ?? this.targetAddress,
      targetLatitude: targetLatitude ?? this.targetLatitude,
      targetLongitude: targetLongitude ?? this.targetLongitude,
      dealTitle: dealTitle ?? this.dealTitle,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        leadId,
        customerId,
        dealId,
        sequenceOrder,
        status,
        createdAt,
        updatedAt,
        targetName,
        targetAddress,
        targetLatitude,
        targetLongitude,
        dealTitle,
      ];
}
