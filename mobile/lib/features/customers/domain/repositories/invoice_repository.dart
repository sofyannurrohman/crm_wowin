import '../entities/invoice.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getCustomerInvoices(String customerId);
  Future<Invoice> getInvoiceById(String id);
  Future<void> updateSignature(String invoiceId, String signaturePath);
}
