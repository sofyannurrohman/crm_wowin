import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/deal_item.dart';
import '../repositories/deal_repository.dart';

class AddDealItem {
  final DealRepository repository;

  AddDealItem(this.repository);

  Future<Either<Failure, DealItem>> call({
    required String dealId,
    required String productId,
    required String name,
    required double quantity,
    required double price,
    required String unit,
    double discount = 0,
    String? notes,
  }) async {
    return await repository.addDealItem(
      dealId: dealId,
      productId: productId,
      name: name,
      quantity: quantity,
      price: price,
      unit: unit,
      discount: discount,
      notes: notes,
    );
  }
}
