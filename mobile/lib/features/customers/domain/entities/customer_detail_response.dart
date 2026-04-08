import 'customer.dart';
import 'package:wowin_crm/features/deals/domain/entities/deal.dart';
import 'package:wowin_crm/features/visits/domain/entities/visit_activity.dart';
import 'package:wowin_crm/features/visits/domain/entities/visit_schedule.dart';

class CustomerDetailResponse {
  final Customer customer;
  final List<VisitActivity> activities;
  final List<Deal> deals;
  final List<VisitSchedule> schedules;

  CustomerDetailResponse({
    required this.customer,
    this.activities = const [],
    this.deals = const [],
    this.schedules = const [],
  });
}
