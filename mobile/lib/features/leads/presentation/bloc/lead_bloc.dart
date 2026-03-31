import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_leads.dart';
import '../../domain/usecases/update_lead_status.dart';
import '../../domain/usecases/create_lead.dart';
import '../../domain/usecases/update_lead.dart';
import '../../domain/usecases/delete_lead.dart';
import '../../domain/usecases/convert_lead.dart';
import 'lead_event.dart';
import 'lead_state.dart';

class LeadBloc extends Bloc<LeadEvent, LeadState> {
  final GetLeads getLeads;
  final UpdateLeadStatus updateLeadStatus;
  final CreateLead createLead;
  final UpdateLead updateLead;
  final DeleteLead deleteLead;
  final ConvertLead convertLead;

  LeadBloc({
    required this.getLeads,
    required this.updateLeadStatus,
    required this.createLead,
    required this.updateLead,
    required this.deleteLead,
    required this.convertLead,
  }) : super(LeadInitial()) {
    on<FetchLeads>(_onFetchLeads);
    on<UpdateLeadStatusSubmitted>(_onUpdateLeadStatusSubmitted);
    on<CreateLeadSubmitted>(_onCreateLeadSubmitted);
    on<UpdateLeadSubmitted>(_onUpdateLeadSubmitted);
    on<DeleteLeadSubmitted>(_onDeleteLeadSubmitted);
    on<ConvertLeadSubmitted>(_onConvertLeadSubmitted);
  }

  Future<void> _onFetchLeads(
    FetchLeads event,
    Emitter<LeadState> emit,
  ) async {
    emit(LeadLoading());
    final result = await getLeads(query: event.query, status: event.status);
    result.fold(
      (failure) => emit(LeadError(failure.message)),
      (leads) => emit(LeadsLoaded(leads)),
    );
  }

  Future<void> _onUpdateLeadStatusSubmitted(
    UpdateLeadStatusSubmitted event,
    Emitter<LeadState> emit,
  ) async {
    emit(LeadLoading());
    final result = await updateLeadStatus(event.id, event.status);
    result.fold(
      (failure) => emit(LeadError(failure.message)),
      (lead) =>
          emit(const LeadOperationSuccess('Berhasil memperbarui status lead')),
    );
  }

  Future<void> _onCreateLeadSubmitted(
    CreateLeadSubmitted event,
    Emitter<LeadState> emit,
  ) async {
    emit(LeadLoading());
    final result = await createLead(event.lead);
    result.fold(
      (failure) => emit(LeadError(failure.message)),
      (lead) => emit(const LeadOperationSuccess('Berhasil membuat lead baru')),
    );
  }

  Future<void> _onUpdateLeadSubmitted(
    UpdateLeadSubmitted event,
    Emitter<LeadState> emit,
  ) async {
    emit(LeadLoading());
    final result = await updateLead(event.lead);
    result.fold(
      (failure) => emit(LeadError(failure.message)),
      (lead) => emit(const LeadOperationSuccess('Berhasil memperbarui data lead')),
    );
  }

  Future<void> _onDeleteLeadSubmitted(
    DeleteLeadSubmitted event,
    Emitter<LeadState> emit,
  ) async {
    emit(LeadLoading());
    final result = await deleteLead(event.id);
    result.fold(
      (failure) => emit(LeadError(failure.message)),
      (_) => emit(const LeadOperationSuccess('Berhasil menghapus data lead')),
    );
  }

  Future<void> _onConvertLeadSubmitted(
    ConvertLeadSubmitted event,
    Emitter<LeadState> emit,
  ) async {
    emit(LeadLoading());
    final result = await convertLead(event.id);
    result.fold(
      (failure) => emit(LeadError(failure.message)),
      (unit) => emit(const LeadOperationSuccess(
          'Berhasil melakukan konversi lead ke customer/deal')),
    );
  }
}
