import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, List<AttendanceRecord>>> getHistory(int month, int year);

  Future<Either<Failure, AttendanceRecord>> clockIn({
    required double lat,
    required double lng,
    required String photoPath,
    String? address,
    String? notes,
  });

  Future<Either<Failure, AttendanceRecord>> clockOut({
    required double lat,
    required double lng,
    required String photoPath,
    String? address,
    String? notes,
  });
}
