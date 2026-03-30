import 'package:equatable/equatable.dart';
import '../../domain/entities/lead.dart';

abstract class LeadEvent extends Equatable {
  const LeadEvent();

  @override
  List<Object?> get props => [];
}

class FetchLeads extends LeadEvent {
  final String? status;
  const FetchLeads({this.status});

  @override
  List<Object?> get props => [status];
}

class UpdateLeadStatusSubmitted extends LeadEvent {
  final String id;
  final String status;
  const UpdateLeadStatusSubmitted({required this.id, required this.status});

  @override
  List<Object> get props => [id, status];
}

class CreateLeadSubmitted extends LeadEvent {
  final Lead lead;
  const CreateLeadSubmitted(this.lead);

  @override
  List<Object> get props => [lead];
}

class ConvertLeadSubmitted extends LeadEvent {
  final String id;
  const ConvertLeadSubmitted(this.id);

  @override
  List<Object> get props => [id];
}
