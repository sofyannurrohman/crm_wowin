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
  final String? customerName;
  final DateTime? checkInTime;
  final String? currentDealId;

  const VisitSuccess(this.message, {
    this.scheduleId,
    this.customerId,
    this.customerName,
    this.checkInTime,
    this.currentDealId,
  });

  @override
  List<Object?> get props => [message, scheduleId, customerId, customerName, checkInTime, currentDealId];
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
