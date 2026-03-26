import 'package:equatable/equatable.dart';
import '../../domain/entities/kpi_summary.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardKpis extends DashboardEvent {}
