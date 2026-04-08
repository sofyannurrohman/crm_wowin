import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/deal.dart';
import '../repositories/deal_repository.dart';

class GetDeals {
  final DealRepository repository;

  GetDeals(this.repository);

  Future<Either<Failure, List<Deal>>> call({String? customerId}) async {
    return await repository.getDeals(customerId: customerId);
  }
}
