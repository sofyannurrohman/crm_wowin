import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/lead.dart';
import '../repositories/lead_repository.dart';

class UpdateLeadStatus {
  final LeadRepository repository;

  UpdateLeadStatus(this.repository);

  Future<Either<Failure, Lead>> call(String id, String status) async {
    return await repository.updateLeadStatus(id, status);
  }
}
