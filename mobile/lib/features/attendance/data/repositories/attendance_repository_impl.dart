import 'package:camera/camera.dart';
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
      final xFile = XFile(photoPath);
      final bytes = await xFile.readAsBytes();
      
      final result = await remoteDataSource.clockIn(
        photoBytes: bytes,
        photoName: xFile.name.isEmpty ? 'selfie.jpg' : xFile.name,
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
      final xFile = XFile(photoPath);
      final bytes = await xFile.readAsBytes();

      final result = await remoteDataSource.clockOut(
        photoBytes: bytes,
        photoName: xFile.name.isEmpty ? 'selfie.jpg' : xFile.name,
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
