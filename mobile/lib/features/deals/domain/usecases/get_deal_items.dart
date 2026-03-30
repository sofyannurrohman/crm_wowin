import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/deal_item.dart';
import '../repositories/deal_repository.dart';

class GetDealItems {
  final DealRepository repository;

  GetDealItems(this.repository);

  Future<Either<Failure, List<DealItem>>> call(String dealId) async {
    return await repository.getDealItems(dealId);
  }
}
