import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/deal.dart';
import '../repositories/deal_repository.dart';

class UpdateDealStage {
  final DealRepository repository;

  UpdateDealStage(this.repository);

  Future<Either<Failure, Deal>> call(String id, String stage) async {
    return await repository.updateDealStage(id, stage);
  }
}
