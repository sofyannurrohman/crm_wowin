import 'package:equatable/equatable.dart';
import '../../domain/entities/visit_activity.dart';

abstract class VisitState extends Equatable {
  const VisitState();

  @override
  List<Object?> get props => [];
}

class VisitInitial extends VisitState {}

class VisitLoading extends VisitState {}

class VisitSuccess extends VisitState {
  final String message;
  final String? scheduleId;
  final String? customerId;
  final String? leadId;
  final String? customerName;
  final DateTime? checkInTime;
  final String? currentDealId;
  final bool isTaskCompleted;
  final String? taskDestinationId;

  const VisitSuccess(this.message, {
    this.scheduleId,
    this.customerId,
    this.leadId,
    this.customerName,
    this.checkInTime,
    this.currentDealId,
    this.isTaskCompleted = false,
    this.taskDestinationId,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'scheduleId': scheduleId,
      'customerId': customerId,
      'leadId': leadId,
      'customerName': customerName,
      'checkInTime': checkInTime?.toIso8601String(),
      'currentDealId': currentDealId,
      'isTaskCompleted': isTaskCompleted,
      'taskDestinationId': taskDestinationId,
    };
  }

  factory VisitSuccess.fromMap(Map<String, dynamic> map) {
    return VisitSuccess(
      map['message'] ?? '',
      scheduleId: map['scheduleId'],
      customerId: map['customerId'],
      leadId: map['leadId'],
      customerName: map['customerName'],
      checkInTime: map['checkInTime'] != null ? DateTime.parse(map['checkInTime']) : null,
      currentDealId: map['currentDealId'],
      isTaskCompleted: map['isTaskCompleted'] ?? false,
      taskDestinationId: map['taskDestinationId'],
    );
  }

  @override
  List<Object?> get props => [message, scheduleId, customerId, leadId, customerName, checkInTime, currentDealId, isTaskCompleted, taskDestinationId];
}

class VisitError extends VisitState {
  final String message;
  const VisitError(this.message);

  @override
  List<Object> get props => [message];
}

class ActivitiesLoaded extends VisitState {
  final List<VisitActivity> activities;
  const ActivitiesLoaded(this.activities);

  @override
  List<Object> get props => [activities];
}
