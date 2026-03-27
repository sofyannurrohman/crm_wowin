import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit_request_entities.dart';
import '../repositories/visit_repository.dart';

class CheckInUseCase {
  final VisitRepository repository;

  CheckInUseCase(this.repository);

  Future<Either<Failure, void>> call(CheckInRequest request) async {
    // Validasi file foto harus selalu ada karena Checkin wajib photo
    if (!request.photoFile.existsSync()) {
      return const Left(
          ValidationFailure('File foto tidak ditemukan atau rusak.'));
    }

    return await repository.checkIn(request);
  }
}
