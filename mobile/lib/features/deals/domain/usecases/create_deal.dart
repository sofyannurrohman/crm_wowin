import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/deal.dart';
import '../repositories/deal_repository.dart';

class CreateDeal {
  final DealRepository repository;

  CreateDeal(this.repository);

  Future<Either<Failure, Deal>> call(Deal deal) async {
    return await repository.createDeal(deal);
  }
}
