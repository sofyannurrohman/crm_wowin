import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';
import '../datasources/lead_remote_data_source.dart';

class LeadRepositoryImpl implements LeadRepository {
  final LeadRemoteDataSource remoteDataSource;

  LeadRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Lead>>> getLeads({String? status}) async {
    try {
      final leads = await remoteDataSource.getLeads(status: status);
      return Right(leads);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal mengambil data leads'));
    }
  }

  @override
  Future<Either<Failure, Lead>> updateLeadStatus(
      String id, String status) async {
    try {
      final lead = await remoteDataSource.updateLeadStatus(id, status);
      return Right(lead);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal memperbarui status lead'));
    }
  }
}
