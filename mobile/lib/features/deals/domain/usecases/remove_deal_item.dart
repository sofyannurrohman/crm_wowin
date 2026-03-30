import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/deal_repository.dart';

class RemoveDealItem {
  final DealRepository repository;

  RemoveDealItem(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.removeDealItem(id);
  }
}
