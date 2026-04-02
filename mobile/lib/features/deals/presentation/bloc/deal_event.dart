import 'package:equatable/equatable.dart';
import '../../domain/entities/deal.dart';

abstract class DealEvent extends Equatable {
  const DealEvent();

  @override
  List<Object?> get props => [];
}

class FetchDeals extends DealEvent {}

class FetchDealDetail extends DealEvent {
  final String id;
  const FetchDealDetail(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateDealStageSubmitted extends DealEvent {
  final String id;
  final String stage;
  const UpdateDealStageSubmitted({required this.id, required this.stage});

  @override
  List<Object> get props => [id, stage];
}

class FetchDealItems extends DealEvent {
  final String dealId;
  const FetchDealItems(this.dealId);

  @override
  List<Object> get props => [dealId];
}

class AddDealItemSubmitted extends DealEvent {
  final String dealId;
  final String productId;
  final int quantity;
  final double price;
  final double discount;
  final String? notes;

  const AddDealItemSubmitted({
    required this.dealId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.discount = 0,
    this.notes,
  });

  @override
  List<Object?> get props => [dealId, productId, quantity, price, discount, notes];
}

class RemoveDealItemSubmitted extends DealEvent {
  final String itemId;
  final String dealId; // To refetch
  const RemoveDealItemSubmitted(this.itemId, this.dealId);

  @override
  List<Object> get props => [itemId, dealId];
}
class CreateDealSubmitted extends DealEvent {
  final Deal deal;
  const CreateDealSubmitted(this.deal);

  @override
  List<Object> get props => [deal];
}

class UpdateDealSubmitted extends DealEvent {
  final Deal deal;
  const UpdateDealSubmitted(this.deal);

  @override
  List<Object> get props => [deal];
}

class DeleteDealSubmitted extends DealEvent {
  final String id;
  const DeleteDealSubmitted(this.id);

  @override
  List<Object> get props => [id];
}
