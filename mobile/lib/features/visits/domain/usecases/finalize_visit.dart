import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/visit_repository.dart';

class FinalizeVisit {
  final VisitRepository repository;

  FinalizeVisit(this.repository);

  Future<Either<Failure, void>> call({
    required String activityId,
    required List<Map<String, dynamic>> items,
    required String outcome,
    double? priceOverride,
    String? notes,
  }) async {
    return await repository.finalizeVisit(
      activityId: activityId,
      items: items,
      outcome: outcome,
      priceOverride: priceOverride,
      notes: notes,
    );
  }
}
