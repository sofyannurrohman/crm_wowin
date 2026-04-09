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
  Future<Either<Failure, List<Lead>>> getLeads(
      {String? query, String? status, String? salesId}) async {
    try {
      final leads = await remoteDataSource.getLeads(
        query: query,
        status: status,
        salesId: salesId,
      );
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

  @override
  Future<Either<Failure, Lead>> createLead(Lead lead) async {
    try {
      final result = await remoteDataSource.createLead(lead);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal membuat lead baru'));
    }
  }

  @override
  Future<Either<Failure, Lead>> updateLead(Lead lead) async {
    try {
      final result = await remoteDataSource.updateLead(lead);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal memperbarui lead'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLead(String id) async {
    try {
      await remoteDataSource.deleteLead(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal menghapus lead'));
    }
  }

  @override
  Future<Either<Failure, Unit>> convertLead(String id) async {
    try {
      await remoteDataSource.convertLead(id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal melakukan konversi lead'));
    }
  }
}
