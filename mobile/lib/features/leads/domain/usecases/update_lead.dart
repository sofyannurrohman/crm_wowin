import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/lead.dart';
import '../repositories/lead_repository.dart';

class UpdateLead {
  final LeadRepository repository;

  UpdateLead(this.repository);

  Future<Either<Failure, Lead>> call(Lead lead) async {
    return await repository.updateLead(lead);
  }
}
