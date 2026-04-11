import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit_activity.dart';
import '../repositories/visit_repository.dart';

class GetActiveVisitUseCase {
  final VisitRepository repository;

  GetActiveVisitUseCase(this.repository);

  Future<Either<Failure, VisitActivity?>> call() async {
    return await repository.getActiveVisit();
  }
}
