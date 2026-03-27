import 'package:equatable/equatable.dart';

abstract class VisitState extends Equatable {
  const VisitState();

  @override
  List<Object?> get props => [];
}

class VisitInitial extends VisitState {}

class VisitLoading extends VisitState {}

class VisitSuccess extends VisitState {
  final String message;
  const VisitSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class VisitError extends VisitState {
  final String message;
  const VisitError(this.message);

  @override
  List<Object> get props => [message];
}
