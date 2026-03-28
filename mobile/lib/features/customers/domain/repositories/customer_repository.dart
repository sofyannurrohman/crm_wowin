import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomers({String? query, String? status});
  Future<Either<Failure, Customer>> getCustomerDetail(String id);
  Future<Either<Failure, Customer>> createCustomer(Customer customer);
}
