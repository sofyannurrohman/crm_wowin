import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/lead_repository.dart';

class ConvertLead {
  final LeadRepository repository;

  ConvertLead(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.convertLead(id);
  }
}
