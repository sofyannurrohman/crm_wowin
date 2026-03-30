import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AttendanceRecord>>> getHistory(
      int month, int year) async {
    try {
      final result = await remoteDataSource.getHistory(month, year);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceRecord>> clockIn({
    required double lat,
    required double lng,
    required String photoPath,
    String? address,
    String? notes,
  }) async {
    try {
      final result = await remoteDataSource.clockIn(
        photo: File(photoPath),
        latitude: lat,
        longitude: lng,
        address: address,
        notes: notes,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceRecord>> clockOut({
    required double lat,
    required double lng,
    required String photoPath,
    String? address,
    String? notes,
  }) async {
    try {
      final result = await remoteDataSource.clockOut(
        photo: File(photoPath),
        latitude: lat,
        longitude: lng,
        address: address,
        notes: notes,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
