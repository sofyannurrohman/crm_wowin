import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../domain/usecases/get_kpi_summary.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetKpiSummary getKpiSummary;
  final DashboardRemoteDataSource remoteDataSource;

  DashboardBloc({
    required this.getKpiSummary,
    required this.remoteDataSource,
  }) : super(DashboardInitial()) {
    on<FetchDashboardKpis>(_onFetchDashboardKpis);
  }

  Future<void> _onFetchDashboardKpis(
    FetchDashboardKpis event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final kpiResult = await getKpiSummary();
    final schedules = await remoteDataSource.getVisitSchedules();

    kpiResult.fold(
      (failure) => emit(DashboardError(failure.message)),
      (dashboard) =>
          emit(DashboardLoaded(dashboard, schedules: schedules)),
    );
  }
}
