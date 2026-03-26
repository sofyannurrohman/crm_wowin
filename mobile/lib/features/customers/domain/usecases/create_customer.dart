import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CreateCustomer {
  final CustomerRepository repository;

  CreateCustomer(this.repository);

  Future<Either<Failure, Customer>> call(Customer customer) async {
    if (customer.name.isEmpty) {
      return const Left(ValidationFailure('Nama pelanggan tidak boleh kosong'));
    }
    return await repository.createCustomer(customer);
  }
}
