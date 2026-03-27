import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc({required this.repository}) : super(AttendanceInitial()) {
    on<FetchAttendanceHistory>(_onFetchHistory);
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
}
