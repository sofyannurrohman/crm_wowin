import 'package:equatable/equatable.dart';
import '../../domain/entities/customer.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class FetchCustomers extends CustomerEvent {
  final String? query;
  const FetchCustomers({this.query});

  @override
  List<Object?> get props => [query];
}

class FetchCustomerDetail extends CustomerEvent {
  final String id;
  const FetchCustomerDetail(this.id);

  @override
  List<Object> get props => [id];
}

class CreateCustomerSubmitted extends CustomerEvent {
  final Customer customer;
  const CreateCustomerSubmitted(this.customer);

  @override
  List<Object> get props => [customer];
}
