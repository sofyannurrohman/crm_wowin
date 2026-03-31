import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/customer_repository.dart';

class DeleteCustomer {
  final CustomerRepository repository;

  DeleteCustomer(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteCustomer(id);
  }
}
