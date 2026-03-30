import 'package:equatable/equatable.dart';
import '../../domain/entities/deal.dart';
import '../../domain/entities/deal_item.dart';

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

class DealDetailLoaded extends DealState {
  final Deal deal;
  const DealDetailLoaded(this.deal);

  @override
  List<Object> get props => [deal];
}

class DealItemsLoaded extends DealState {
  final List<DealItem> items;
  const DealItemsLoaded(this.items);

  @override
  List<Object> get props => [items];
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
