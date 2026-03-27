import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, List<AttendanceRecord>>> getHistory(
      int month, int year);

  // Future<Either<Failure, AttendanceRecord>> clockIn(...);
  // Future<Either<Failure, AttendanceRecord>> clockOut(...);
}
