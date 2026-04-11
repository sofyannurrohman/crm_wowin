import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit_request_entities.dart';
import '../entities/visit_activity.dart';

abstract class VisitRepository {
  Future<Either<Failure, void>> checkIn(CheckInRequest request);
  Future<Either<Failure, Map<String, dynamic>>> checkOut(CheckOutRequest request);
  Future<Either<Failure, List<VisitActivity>>> getActivities({String? salesId, String? customerId, String? leadId});
  Future<Either<Failure, VisitActivity?>> getActiveVisit();
}
