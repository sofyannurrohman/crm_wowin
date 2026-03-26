import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_leads.dart';
import '../../domain/usecases/update_lead_status.dart';
import 'lead_event.dart';
import 'lead_state.dart';

class LeadBloc extends Bloc<LeadEvent, LeadState> {
  final GetLeads getLeads;
  final UpdateLeadStatus updateLeadStatus;

  LeadBloc({
    required this.getLeads,
    required this.updateLeadStatus,
  }) : super(LeadInitial()) {
    on<FetchLeads>(_onFetchLeads);
    on<UpdateLeadStatusSubmitted>(_onUpdateLeadStatusSubmitted);
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
      (lead) => emit(const LeadOperationSuccess('Berhasil memperbarui status lead')),
    );
  }
}
