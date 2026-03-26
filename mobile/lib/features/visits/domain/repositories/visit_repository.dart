import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit_request_entities.dart';

abstract class VisitRepository {
  Future<Either<Failure, void>> checkIn(CheckInRequest request);
  Future<Either<Failure, void>> checkOut(CheckOutRequest request);
}
