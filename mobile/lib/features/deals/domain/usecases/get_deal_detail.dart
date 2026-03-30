import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/deal.dart';
import '../repositories/deal_repository.dart';

class GetDealDetail {
  final DealRepository repository;

  GetDealDetail(this.repository);

  // Note: We'll update repository interface to support this if needed
  // For now we'll just filter from the list or use a new method
  Future<Either<Failure, Deal>> call(String id) async {
    // Let's assume the repository implementation will eventually have a specific GET /deals/:id
    // But for now we might be using the list or we add the method.
    // I prefer adding the method to repository.
    return await repository.getDealDetail(id);
  }
}
