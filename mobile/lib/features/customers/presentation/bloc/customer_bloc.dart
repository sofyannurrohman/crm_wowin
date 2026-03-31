import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_customers.dart';
import '../../domain/usecases/get_customer_detail.dart';
import '../../domain/usecases/create_customer.dart';
import '../../domain/usecases/update_customer.dart';
import '../../domain/usecases/delete_customer.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomers getCustomers;
  final GetCustomerDetail getCustomerDetail;
  final CreateCustomer createCustomer;
  final UpdateCustomer updateCustomer;
  final DeleteCustomer deleteCustomer;

  CustomerBloc({
    required this.getCustomers,
    required this.getCustomerDetail,
    required this.createCustomer,
    required this.updateCustomer,
    required this.deleteCustomer,
  }) : super(CustomerInitial()) {
    on<FetchCustomers>(_onFetchCustomers);
    on<FetchCustomerDetail>(_onFetchCustomerDetail);
    on<CreateCustomerSubmitted>(_onCreateCustomerSubmitted);
    on<UpdateCustomerSubmitted>(_onUpdateCustomerSubmitted);
    on<DeleteCustomerSubmitted>(_onDeleteCustomerSubmitted);
  }

  Future<void> _onFetchCustomers(
    FetchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await getCustomers(query: event.query, status: event.status);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customers) => emit(CustomersLoaded(customers)),
    );
  }

  Future<void> _onFetchCustomerDetail(
    FetchCustomerDetail event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await getCustomerDetail(event.id);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customer) => emit(CustomerDetailLoaded(customer)),
    );
  }

  Future<void> _onCreateCustomerSubmitted(
    CreateCustomerSubmitted event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await createCustomer(event.customer);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customer) => emit(
          const CustomerOperationSuccess('Berhasil membuat pelanggan baru')),
    );
  }

  Future<void> _onUpdateCustomerSubmitted(
    UpdateCustomerSubmitted event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await updateCustomer(event.customer);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customer) => emit(
          const CustomerOperationSuccess('Berhasil memperbarui data pelanggan')),
    );
  }

  Future<void> _onDeleteCustomerSubmitted(
    DeleteCustomerSubmitted event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await deleteCustomer(event.id);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) => emit(
          const CustomerOperationSuccess('Berhasil menghapus data pelanggan')),
    );
  }
}
