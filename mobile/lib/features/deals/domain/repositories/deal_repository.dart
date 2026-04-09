import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/deal.dart';
import '../entities/deal_item.dart';

abstract class DealRepository {
  Future<Either<Failure, List<Deal>>> getDeals({String? customerId, String? salesId});
  Future<Either<Failure, Deal>> getDealDetail(String id);
  Future<Either<Failure, Deal>> createDeal(Deal deal);
  Future<Either<Failure, Deal>> updateDeal(Deal deal);
  Future<Either<Failure, void>> deleteDeal(String id);
  Future<Either<Failure, Deal>> updateDealStage(String id, String stage);
  Future<Either<Failure, List<DealItem>>> getDealItems(String dealId);
  Future<Either<Failure, DealItem>> addDealItem({
    required String dealId,
    required String productId,
    required String name,
    required double quantity,
    required double price,
    required String unit,
    double discount = 0,
    String? notes,
  });
  Future<Either<Failure, void>> removeDealItem(String id);
}
