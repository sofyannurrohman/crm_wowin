import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductDetail {
  final ProductRepository repository;

  GetProductDetail(this.repository);

  Future<Either<Failure, Product>> call(String id) async {
    return await repository.getProductDetail(id);
  }
}
