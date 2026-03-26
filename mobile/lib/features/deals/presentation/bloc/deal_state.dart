import 'package:equatable/equatable.dart';
import '../../domain/entities/deal.dart';

abstract class DealState extends Equatable {
  const DealState();

  @override
  List<Object?> get props => [];
}

class DealInitial extends DealState {}

class DealLoading extends DealState {}

class DealsLoaded extends DealState {
  final List<Deal> deals;
  const DealsLoaded(this.deals);

  @override
  List<Object> get props => [deals];
}

class DealOperationSuccess extends DealState {
  final String message;
  const DealOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class DealError extends DealState {
  final String message;
  const DealError(this.message);

  @override
  List<Object> get props => [message];
}
