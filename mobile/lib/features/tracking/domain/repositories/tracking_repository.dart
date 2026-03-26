import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/location_point.dart';

abstract class TrackingRepository {
  Future<Either<Failure, void>> saveLocationLocal(LocationPoint point);
  Future<Either<Failure, int>> syncBufferedLocations();
}
