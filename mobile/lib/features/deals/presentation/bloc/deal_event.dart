import 'package:equatable/equatable.dart';
import '../../domain/entities/deal.dart';

abstract class DealEvent extends Equatable {
  const DealEvent();

  @override
  List<Object?> get props => [];
}

class FetchDeals extends DealEvent {}

class UpdateDealStageSubmitted extends DealEvent {
  final String id;
  final String stage;
  const UpdateDealStageSubmitted({required this.id, required this.stage});

  @override
  List<Object> get props => [id, stage];
}
