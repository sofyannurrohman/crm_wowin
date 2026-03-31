import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../domain/usecases/get_kpi_summary.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

import '../../domain/entities/visit_recommendation.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetKpiSummary getKpiSummary;
  final DashboardRepository repository;

  DashboardBloc({
    required this.getKpiSummary,
    required this.repository,
  }) : super(DashboardInitial()) {
    on<FetchDashboardKpis>(_onFetchDashboardKpis);
  }

  Future<void> _onFetchDashboardKpis(
    FetchDashboardKpis event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final kpiResult = await getKpiSummary();
    final recsResult = await repository.getVisitRecommendations();

    kpiResult.fold(
      (failure) => emit(DashboardError(failure.message)),
      (dashboard) {
        final List<VisitRecommendation> recommendations = [];
        recsResult.fold(
          (_) => null,
          (data) {
            recommendations.addAll(
              data.map((e) => VisitRecommendation.fromJson(e)).toList(),
            );
          },
        );

        emit(DashboardLoaded(dashboard, recommendations: recommendations));
      },
    );
  }
}
