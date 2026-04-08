import 'package:equatable/equatable.dart';
import '../../domain/entities/customer.dart';
import 'package:wowin_crm/features/deals/domain/entities/deal.dart';
import 'package:wowin_crm/features/visits/domain/entities/visit_activity.dart';
import 'package:wowin_crm/features/visits/domain/entities/visit_schedule.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomersLoaded extends CustomerState {
  final List<Customer> customers;
  const CustomersLoaded(this.customers);

  @override
  List<Object> get props => [customers];
}

class CustomerDetailLoaded extends CustomerState {
  final Customer customer;
  final List<VisitActivity> activities;
  final List<Deal> deals;
  final List<VisitSchedule> schedules;

  const CustomerDetailLoaded({
    required this.customer,
    this.activities = const [],
    this.deals = const [],
    this.schedules = const [],
  });

  @override
  List<Object> get props => [customer, activities, deals, schedules];
}

class CustomerOperationSuccess extends CustomerState {
  final String message;
  const CustomerOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);

  @override
  List<Object> get props => [message];
}
