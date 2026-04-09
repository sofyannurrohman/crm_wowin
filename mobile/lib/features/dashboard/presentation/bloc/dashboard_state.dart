import 'package:equatable/equatable.dart';
import '../../domain/entities/kpi_dashboard.dart';
import '../../domain/entities/visit_recommendation.dart';
import 'package:wowin_crm/features/tasks/domain/entities/task.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final KpiDashboard dashboard;
  final List<VisitRecommendation> recommendations;
  final List<Task> routeTasks;

  const DashboardLoaded(
    this.dashboard, {
    this.recommendations = const [],
    this.routeTasks = const [],
  });

  @override
  List<Object> get props => [dashboard, recommendations, routeTasks];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
