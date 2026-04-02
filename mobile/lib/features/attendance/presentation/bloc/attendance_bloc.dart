import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc({required this.repository}) : super(AttendanceInitial()) {
    on<FetchAttendanceHistory>(_onFetchHistory);
    on<ClockInSubmitted>(_onClockIn);
    on<ClockOutSubmitted>(_onClockOut);
  }

  Future<void> _onFetchHistory(
    FetchAttendanceHistory event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    final result = await repository.getHistory(event.month, event.year);

    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (history) => emit(AttendanceHistoryLoaded(history)),
    );
  }

  Future<void> _onClockIn(
    ClockInSubmitted event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    final result = await repository.clockIn(
      lat: event.lat,
      lng: event.lng,
      photoPath: event.photoPath,
      address: event.address,
      notes: event.notes,
    );

    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (record) {
        emit(AttendanceSuccess(record, 'Berhasil Clock In!'));
        add(FetchAttendanceHistory(
          month: DateTime.now().month,
          year: DateTime.now().year,
        ));
      },
    );
  }

  Future<void> _onClockOut(
    ClockOutSubmitted event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    final result = await repository.clockOut(
      lat: event.lat,
      lng: event.lng,
      photoPath: event.photoPath,
      address: event.address,
      notes: event.notes,
    );

    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (record) {
        emit(AttendanceSuccess(record, 'Berhasil Clock Out!'));
        add(FetchAttendanceHistory(
          month: DateTime.now().month,
          year: DateTime.now().year,
        ));
      },
    );
  }
}
