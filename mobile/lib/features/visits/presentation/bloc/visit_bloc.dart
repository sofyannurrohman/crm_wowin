import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../domain/usecases/check_in_usecase.dart';
import '../../domain/usecases/check_out_usecase.dart';
import '../../domain/usecases/get_activities.dart';
import '../../domain/usecases/get_active_visit.dart';
import '../../domain/entities/visit_request_entities.dart';
import 'visit_event.dart';
import 'visit_state.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> with HydratedMixin {
  final CheckInUseCase checkInUseCase;
  final CheckOutUseCase checkOutUseCase;
  final GetActivities getActivitiesUseCase;
  final GetActiveVisitUseCase getActiveVisitUseCase;

  VisitBloc({
    required this.checkInUseCase,
    required this.checkOutUseCase,
    required this.getActivitiesUseCase,
    required this.getActiveVisitUseCase,
  }) : super(VisitInitial()) {
    on<CheckInSubmitted>(_onCheckInSubmitted);
    on<CheckOutSubmitted>(_onCheckOutSubmitted);
    on<FetchActivities>(_onFetchActivities);
    on<LinkDealToVisit>(_onLinkDealToVisit);
    on<RestoreActiveVisit>(_onRestoreActiveVisit);
    hydrate();
  }

  Future<void> _onRestoreActiveVisit(
    RestoreActiveVisit event,
    Emitter<VisitState> emit,
  ) async {
    // Only restore/sync if we are currently in an ongoing state or initial
    if (state is VisitSuccess || state is VisitInitial) {
      final result = await getActiveVisitUseCase();
      result.fold(
        (failure) => null, // Ignore failures during reconciliation for now
        (activity) {
          if (activity != null) {
            emit(VisitSuccess(
              'Sesi kunjungan dilanjutkan.',
              customerId: activity.customerId,
              leadId: activity.leadId,
              customerName: null, // We might need to fetch this if missing, but UI handles ID
              checkInTime: activity.createdAt,
              scheduleId: activity.id, // Using activity ID if scheduleId is not direct
            ));
          } else {
            // If backend says no active visit but we have local state, clear it
            if (state is VisitSuccess) {
              emit(VisitInitial());
            }
          }
        },
      );
    }
  }

  @override
  VisitState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'VisitSuccess') {
        return VisitSuccess.fromMap(json['state']);
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(VisitState state) {
    if (state is VisitSuccess) {
      return {
        'type': 'VisitSuccess',
        'state': state.toMap(),
      };
    }
    return null;
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
        taskDestinationId: event.taskDestinationId,
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
      outcome: event.outcome,
      priceOverride: event.priceOverride,
      priceOverrideNote: event.priceOverrideNote,
      dealId: event.dealId,
      dealItems: event.dealItems,
      paymentMethod: event.paymentMethod,
      paymentRef: event.paymentRef,
      signatureBytes: event.signatureBytes,
    );

    final result = await checkOutUseCase(request);

    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (data) => emit(VisitSuccess(
        'Laporan Kunjungan Berhasil Disimpan!',
        isTaskCompleted: data['task_completed'] == true,
        currentDealId: data['deal_id'],
      )),
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
