import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/visit_repository.dart';

class AnalyzeReceiptUseCase {
  final VisitRepository repository;

  AnalyzeReceiptUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(String activityId) {
    return repository.analyzeReceipt(activityId);
  }
}
