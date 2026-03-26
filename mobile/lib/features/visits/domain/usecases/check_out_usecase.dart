import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit_request_entities.dart';
import '../repositories/visit_repository.dart';

class CheckOutUseCase {
  final VisitRepository repository;

  CheckOutUseCase(this.repository);

  Future<Either<Failure, void>> call(CheckOutRequest request) async {
    if (request.visitResult.isEmpty) {
      return const Left(ValidationFailure('Hasil kunjungan harus diisi.'));
    }

    return await repository.checkOut(request);
  }
}
