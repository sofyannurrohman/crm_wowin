import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/lead.dart';

abstract class LeadRepository {
  Future<Either<Failure, List<Lead>>> getLeads({String? status});
  Future<Either<Failure, Lead>> updateLeadStatus(String id, String status);
}
