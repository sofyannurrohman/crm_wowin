import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';
import '../entities/customer_detail_response.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomers({String? query, String? status});
  Future<Either<Failure, CustomerDetailResponse>> getCustomerDetail(String id);
  Future<Either<Failure, Customer>> createCustomer(Customer customer);
  Future<Either<Failure, Customer>> updateCustomer(Customer customer);
  Future<Either<Failure, void>> deleteCustomer(String id);
}
