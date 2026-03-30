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
  }

  Future<void> _onFetchActivities(
    FetchActivities event,
    Emitter<VisitState> emit,
  ) async {
    emit(VisitLoading());
    final result = await getActivitiesUseCase(
        salesId: event.salesId, customerId: event.customerId);
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
      checkInNotes: event.notes,
    );

    final result = await checkInUseCase(request);

    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (_) => emit(const VisitSuccess('Check-in berhasil dilakukan!')),
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
    );

    final result = await checkOutUseCase(request);

    result.fold(
      (failure) => emit(VisitError(failure.message)),
      (_) => emit(const VisitSuccess('Check-out berhasil disimpan!')),
    );
  }
}
