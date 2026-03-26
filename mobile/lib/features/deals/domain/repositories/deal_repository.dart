import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/deal.dart';

abstract class DealRepository {
  Future<Either<Failure, List<Deal>>> getDeals();
  Future<Either<Failure, Deal>> updateDealStage(String id, String stage);
}
