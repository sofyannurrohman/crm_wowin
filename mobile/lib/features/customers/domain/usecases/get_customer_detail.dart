import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';
import '../entities/customer_detail_response.dart';
import '../repositories/customer_repository.dart';

class GetCustomerDetail {
  final CustomerRepository repository;

  GetCustomerDetail(this.repository);

  Future<Either<Failure, CustomerDetailResponse>> call(String id) async {
    return await repository.getCustomerDetail(id);
  }
}
