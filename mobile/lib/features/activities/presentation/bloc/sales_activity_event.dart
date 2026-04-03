import 'package:equatable/equatable.dart';
import '../../domain/entities/sales_activity.dart';

abstract class SalesActivityEvent extends Equatable {
  const SalesActivityEvent();

  @override
  List<Object?> get props => [];
}

class FetchSalesActivities extends SalesActivityEvent {
  final String? salesId;
  final String? leadId;
  final String? customerId;
  final String? dealId;
  final DateTime? startDate;
  final DateTime? endDate;

  const FetchSalesActivities({
    this.salesId,
    this.leadId,
    this.customerId,
    this.dealId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [salesId, leadId, customerId, dealId, startDate, endDate];
}

class CreateSalesActivitySubmitted extends SalesActivityEvent {
  final SalesActivity activity;
  const CreateSalesActivitySubmitted(this.activity);

  @override
  List<Object> get props => [activity];
}

class UpdateSalesActivitySubmitted extends SalesActivityEvent {
  final SalesActivity activity;
  const UpdateSalesActivitySubmitted(this.activity);

  @override
  List<Object> get props => [activity];
}

class DeleteSalesActivitySubmitted extends SalesActivityEvent {
  final String id;
  const DeleteSalesActivitySubmitted(this.id);

  @override
  List<Object> get props => [id];
}
