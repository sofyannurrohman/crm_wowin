import 'package:equatable/equatable.dart';
import '../../domain/entities/kpi_dashboard.dart';
import '../../domain/entities/visit_recommendation.dart';

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

  const DashboardLoaded(this.dashboard, {this.recommendations = const []});

  @override
  List<Object> get props => [dashboard, recommendations];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
