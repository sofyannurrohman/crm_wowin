import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    String? category,
    String? query,
  }) async {
    try {
      final products = await remoteDataSource.getProducts(
        category: category,
        query: query,
      );
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductDetail(String id) async {
    try {
      final product = await remoteDataSource.getProductDetail(id);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
