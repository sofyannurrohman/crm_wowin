import 'package:dio/dio.dart';
import 'package:wowin_crm/features/customers/domain/entities/invoice.dart';

abstract class InvoiceRemoteDataSource {
  Future<List<Invoice>> getCustomerInvoices(String customerId);
  Future<Invoice> getInvoiceById(String id);
  Future<void> updateSignature(String invoiceId, String signaturePath);
}

class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  final Dio dio;

  InvoiceRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Invoice>> getCustomerInvoices(String customerId) async {
    try {
      final response = await dio.get('/invoices/customer/$customerId');
      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => Invoice.fromJson(json)).toList();
      }
      throw Exception('Failed to load invoices');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Invoice> getInvoiceById(String id) async {
    try {
      final response = await dio.get('/invoices/$id');
      if (response.statusCode == 200) {
        return Invoice.fromJson(response.data['data']);
      }
      throw Exception('Failed to load invoice detail');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateSignature(String invoiceId, String signaturePath) async {
    await dio.post('/invoices/$invoiceId/signature', data: {
      'signature_path': signaturePath,
    });
  }
}
