import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/lead.dart';
import '../repositories/lead_repository.dart';

class GetLeads {
  final LeadRepository repository;

  GetLeads(this.repository);

  Future<Either<Failure, List<Lead>>> call({String? status}) async {
    return await repository.getLeads(status: status);
  }
}
