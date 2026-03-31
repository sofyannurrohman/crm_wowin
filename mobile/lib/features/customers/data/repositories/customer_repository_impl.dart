import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Customer>>> getCustomers(
      {String? query, String? status}) async {
    try {
      final customers = await remoteDataSource.getCustomers(
        query: query,
        status: status,
      );
      return Right(customers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal mengambil data pelanggan'));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomerDetail(String id) async {
    try {
      final customer = await remoteDataSource.getCustomerDetail(id);
      return Right(customer);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal mengambil detail pelanggan'));
    }
  }

  @override
  Future<Either<Failure, Customer>> createCustomer(Customer customer) async {
    try {
      final newCustomer = await remoteDataSource.createCustomer(customer);
      return Right(newCustomer);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal membuat data pelanggan'));
    }
  }
  @override
  Future<Either<Failure, Customer>> updateCustomer(Customer customer) async {
    try {
      final updatedCustomer = await remoteDataSource.updateCustomer(customer);
      return Right(updatedCustomer);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal memperbarui data pelanggan'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String id) async {
    try {
      await remoteDataSource.deleteCustomer(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal menghapus data pelanggan'));
    }
  }
}
