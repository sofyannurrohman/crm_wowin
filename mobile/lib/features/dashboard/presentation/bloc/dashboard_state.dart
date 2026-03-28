import 'package:equatable/equatable.dart';
import '../../domain/entities/kpi_dashboard.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final KpiDashboard dashboard;
  final List<Map<String, dynamic>> schedules;

  const DashboardLoaded(this.dashboard, {this.schedules = const []});

  @override
  List<Object> get props => [dashboard, schedules];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
