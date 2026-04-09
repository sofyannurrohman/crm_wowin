import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/visit_request_entities.dart';
import '../../domain/usecases/check_in_usecase.dart';
import '../../domain/usecases/check_out_usecase.dart';
import '../../domain/usecases/get_activities.dart';
import 'visit_event.dart';
import 'visit_state.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final CheckInUseCase checkInUseCase;
  final CheckOutUseCase checkOutUseCase;
  final GetActivities getActivitiesUseCase;

  VisitBloc({
    required this.checkInUseCase,
    required this.checkOutUseCase,
    required this.getActivitiesUseCase,
  }) : super(VisitInitial()) {
    on<CheckInSubmitted>(_onCheckInSubmitted);
    on<CheckOutSubmitted>(_onCheckOutSubmitted);
    on<FetchActivities>(_onFetchActivities);
    on<LinkDealToVisit>(_onLinkDealToVisit);
  }

  Future<void> _onFetchActivities(
    FetchActivities event,
    Emitter<VisitState> emit,
  ) async {
    emit(VisitLoading());
    final result = await getActivitiesUseCase(
        salesId: event.salesId, customerId: event.customerId, leadId: event.leadId);
    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (activities) => emit(ActivitiesLoaded(activities)),
    );
  }

  Future<void> _onCheckInSubmitted(
    CheckInSubmitted event,
    Emitter<VisitState> emit,
  ) async {
    emit(VisitLoading());

    final request = CheckInRequest(
      scheduleId: event.scheduleId,
      latitude: event.latitude,
      longitude: event.longitude,
      photoFile: event.photoFile,
      selfiePhotoFile: event.selfiePhotoFile,
      checkInNotes: event.notes,
      dealId: event.dealId,
      overrideReason: event.overrideReason,
      taskDestinationId: event.taskDestinationId,
      customerId: event.customerId,
      leadId: event.leadId,
      dealItems: event.dealItems,
    );

    final result = await checkInUseCase(request);

    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (_) => emit(VisitSuccess(
        'Check-in Berhasil! Silakan catat hasil setelah selesai.',
        scheduleId: event.scheduleId,
        customerId: event.customerId,
        leadId: event.leadId,
        customerName: event.customerName,
        checkInTime: DateTime.now(),
      )),
    );
  }

  Future<void> _onCheckOutSubmitted(
    CheckOutSubmitted event,
    Emitter<VisitState> emit,
  ) async {
    emit(VisitLoading());

    final request = CheckOutRequest(
      scheduleId: event.scheduleId,
      latitude: event.latitude,
      longitude: event.longitude,
      visitResult: event.visitResult,
      nextAction: event.nextAction,
      nextVisitDate: event.nextVisitDate,
      signaturePath: event.signaturePath,
      inventoryData: event.inventoryData,
      taskDestinationId: event.taskDestinationId,
      customerId: event.customerId,
      leadId: event.leadId,
      priceOverride: event.priceOverride,
      priceOverrideNote: event.priceOverrideNote,
      dealId: event.dealId,
    );

    final result = await checkOutUseCase(request);

    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (_) => emit(const VisitSuccess('Laporan Kunjungan Berhasil Disimpan!')),
    );
  }

  void _onLinkDealToVisit(
    LinkDealToVisit event,
    Emitter<VisitState> emit,
  ) {
    if (state is VisitSuccess) {
      final s = state as VisitSuccess;
      emit(VisitSuccess(
        s.message,
        scheduleId: s.scheduleId,
        customerId: s.customerId,
        customerName: s.customerName,
        checkInTime: s.checkInTime,
        currentDealId: event.dealId,
      ));
    }
  }
}
