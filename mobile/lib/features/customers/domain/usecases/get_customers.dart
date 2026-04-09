import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomers {
  final CustomerRepository repository;

  GetCustomers(this.repository);

  Future<Either<Failure, List<Customer>>> call(
      {String? query, String? status, String? salesId}) async {
    return await repository.getCustomers(query: query, status: status, salesId: salesId);
  }
}
