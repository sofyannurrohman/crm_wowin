import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/deal_repository.dart';

class DeleteDeal {
  final DealRepository repository;

  DeleteDeal(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteDeal(id);
  }
}
