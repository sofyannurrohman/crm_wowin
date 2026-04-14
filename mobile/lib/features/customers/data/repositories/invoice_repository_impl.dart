import '../../domain/repositories/invoice_repository.dart';
import '../../domain/entities/invoice.dart';
import '../datasources/invoice_remote_data_source.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource remoteDataSource;

  InvoiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Invoice>> getCustomerInvoices(String customerId) {
    return remoteDataSource.getCustomerInvoices(customerId);
  }

  @override
  Future<Invoice> getInvoiceById(String id) {
    return remoteDataSource.getInvoiceById(id);
  }

  @override
  Future<void> updateSignature(String invoiceId, String signaturePath) {
    return remoteDataSource.updateSignature(invoiceId, signaturePath);
  }
}
