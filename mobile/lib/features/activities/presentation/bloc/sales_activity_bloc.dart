import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/sales_activity_repository.dart';
import 'sales_activity_event.dart';
import 'sales_activity_state.dart';

class SalesActivityBloc extends Bloc<SalesActivityEvent, SalesActivityState> {
  final SalesActivityRepository repository;

  SalesActivityBloc({required this.repository}) : super(SalesActivityInitial()) {
    on<FetchSalesActivities>(_onFetchSalesActivities);
    on<CreateSalesActivitySubmitted>(_onCreateSalesActivitySubmitted);
    on<UpdateSalesActivitySubmitted>(_onUpdateSalesActivitySubmitted);
    on<DeleteSalesActivitySubmitted>(_onDeleteSalesActivitySubmitted);
  }

  Future<void> _onFetchSalesActivities(
    FetchSalesActivities event,
    Emitter<SalesActivityState> emit,
  ) async {
    emit(SalesActivityLoading());
    final result = await repository.getActivities(
      salesId: event.salesId,
      leadId: event.leadId,
      customerId: event.customerId,
      dealId: event.dealId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(SalesActivityError(failure.message)),
      (activities) => emit(SalesActivityLoaded(activities)),
    );
  }

  Future<void> _onCreateSalesActivitySubmitted(
    CreateSalesActivitySubmitted event,
    Emitter<SalesActivityState> emit,
  ) async {
    emit(SalesActivityLoading());
    final result = await repository.createActivity(event.activity);

    result.fold(
      (failure) => emit(SalesActivityError(failure.message)),
      (activity) => emit(const SalesActivityOperationSuccess('Activity created successfully')),
    );
  }

  Future<void> _onUpdateSalesActivitySubmitted(
    UpdateSalesActivitySubmitted event,
    Emitter<SalesActivityState> emit,
  ) async {
    emit(SalesActivityLoading());
    final result = await repository.updateActivity(event.activity);

    result.fold(
      (failure) => emit(SalesActivityError(failure.message)),
      (activity) => emit(const SalesActivityOperationSuccess('Activity updated successfully')),
    );
  }

  Future<void> _onDeleteSalesActivitySubmitted(
    DeleteSalesActivitySubmitted event,
    Emitter<SalesActivityState> emit,
  ) async {
    emit(SalesActivityLoading());
    final result = await repository.deleteActivity(event.id);

    result.fold(
      (failure) => emit(SalesActivityError(failure.message)),
      (_) => emit(const SalesActivityOperationSuccess('Activity deleted successfully')),
    );
  }
}
