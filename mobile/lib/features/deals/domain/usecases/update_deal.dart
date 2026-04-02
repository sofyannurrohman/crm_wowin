import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/deal.dart';
import '../repositories/deal_repository.dart';

class UpdateDeal {
  final DealRepository repository;

  UpdateDeal(this.repository);

  Future<Either<Failure, Deal>> call(Deal deal) async {
    return await repository.updateDeal(deal);
  }
}
