import 'package:equatable/equatable.dart';
import '../../domain/entities/sales_activity.dart';

abstract class SalesActivityState extends Equatable {
  const SalesActivityState();

  @override
  List<Object?> get props => [];
}

class SalesActivityInitial extends SalesActivityState {}

class SalesActivityLoading extends SalesActivityState {}

class SalesActivityLoaded extends SalesActivityState {
  final List<SalesActivity> activities;
  const SalesActivityLoaded(this.activities);

  @override
  List<Object> get props => [activities];
}

class SalesActivityOperationSuccess extends SalesActivityState {
  final String message;
  const SalesActivityOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class SalesActivityError extends SalesActivityState {
  final String message;
  const SalesActivityError(this.message);

  @override
  List<Object> get props => [message];
}
