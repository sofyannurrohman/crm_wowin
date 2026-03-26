import 'package:equatable/equatable.dart';
import '../../domain/entities/lead.dart';

abstract class LeadState extends Equatable {
  const LeadState();

  @override
  List<Object?> get props => [];
}

class LeadInitial extends LeadState {}

class LeadLoading extends LeadState {}

class LeadsLoaded extends LeadState {
  final List<Lead> leads;
  const LeadsLoaded(this.leads);

  @override
  List<Object> get props => [leads];
}

class LeadOperationSuccess extends LeadState {
  final String message;
  const LeadOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class LeadError extends LeadState {
  final String message;
  const LeadError(this.message);

  @override
  List<Object> get props => [message];
}
