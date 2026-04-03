import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sales_activity.dart';

abstract class SalesActivityRepository {
  Future<Either<Failure, List<SalesActivity>>> getActivities({
    String? salesId,
    String? leadId,
    String? customerId,
    String? dealId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, SalesActivity>> createActivity(SalesActivity activity);
  
  Future<Either<Failure, SalesActivity>> updateActivity(SalesActivity activity);
  
  Future<Either<Failure, Unit>> deleteActivity(String id);
}
