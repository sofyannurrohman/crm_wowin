import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_kpi_summary.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetKpiSummary getKpiSummary;

  DashboardBloc({
    required this.getKpiSummary,
  }) : super(DashboardInitial()) {
    on<FetchDashboardKpis>(_onFetchDashboardKpis);
  }

  Future<void> _onFetchDashboardKpis(
    FetchDashboardKpis event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final result = await getKpiSummary();
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (summary) => emit(DashboardLoaded(summary)),
    );
  }
}
