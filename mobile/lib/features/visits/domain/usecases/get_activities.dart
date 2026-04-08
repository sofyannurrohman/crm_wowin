import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit_activity.dart';
import '../repositories/visit_repository.dart';

class GetActivities {
  final VisitRepository repository;

  GetActivities(this.repository);

  Future<Either<Failure, List<VisitActivity>>> call({String? salesId, String? customerId, String? leadId}) {
    return repository.getActivities(salesId: salesId, customerId: customerId, leadId: leadId);
  }
}
