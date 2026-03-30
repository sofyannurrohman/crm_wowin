import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_leads.dart';
import '../../domain/usecases/update_lead_status.dart';
import '../../domain/usecases/create_lead.dart';
import '../../domain/usecases/convert_lead.dart';
import 'lead_event.dart';
import 'lead_state.dart';

class LeadBloc extends Bloc<LeadEvent, LeadState> {
  final GetLeads getLeads;
  final UpdateLeadStatus updateLeadStatus;
  final CreateLead createLead;
  final ConvertLead convertLead;

  LeadBloc({
    required this.getLeads,
    required this.updateLeadStatus,
    required this.createLead,
    required this.convertLead,
  }) : super(LeadInitial()) {
    on<FetchLeads>(_onFetchLeads);
    on<UpdateLeadStatusSubmitted>(_onUpdateLeadStatusSubmitted);
    on<CreateLeadSubmitted>(_onCreateLeadSubmitted);
    on<ConvertLeadSubmitted>(_onConvertLeadSubmitted);
  }

  Future<void> _onFetchLeads(
    FetchLeads event,
    Emitter<LeadState> emit,
  ) async {
    emit(LeadLoading());
    final result = await getLeads(status: event.status);
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
