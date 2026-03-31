import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/lead_repository.dart';

class DeleteLead {
  final LeadRepository repository;

  DeleteLead(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteLead(id);
  }
}
