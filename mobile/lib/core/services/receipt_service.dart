import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ReceiptService {
  Future<void> generateAndShareReceipt({
    required String customerName,
    required String invoiceNo,
    required List<Map<String, dynamic>> items,
    required double total,
    required String paymentMethod,
    String? paymentRef,
    Uint8List? signatureBytes,
    bool isCollection = false,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('WOWIN CRM', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                      pw.Text('Solusi Distribusi & Sales Pintar', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    child: pw.Text(isCollection ? 'STRUK TAGIHAN' : 'STRUK PEMBELIAN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 0.5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('No. Invoice:', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(invoiceNo, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Customer:', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(customerName, style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tanggal:', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()), style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 5),
                
                if (!isCollection && items.isNotEmpty) ...[
                  pw.Text('RINCIAN PESANAN', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                  pw.SizedBox(height: 4),
                  ...items.map((it) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 2),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(child: pw.Text(it['name'], style: const pw.TextStyle(fontSize: 8))),
                          pw.Text('${it['quantity'].toInt()} x Rp${NumberFormat('#,###').format(it['unit_price'])}', style: const pw.TextStyle(fontSize: 8)),
                          pw.SizedBox(width: 10),
                          pw.Text('Rp${NumberFormat('#,###', 'id_ID').format(it['subtotal'])}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    );
                  }),
                  pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dotted),
                ],

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL BAYAR', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Rp ${NumberFormat('#,###', 'id_ID').format(total)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text('Metode: ${paymentMethod.toUpperCase()}', style: const pw.TextStyle(fontSize: 8)),
                if (paymentRef != null && paymentRef.isNotEmpty)
                  pw.Text('Ref: $paymentRef', style: const pw.TextStyle(fontSize: 8)),
                
                pw.SizedBox(height: 15),
                if (signatureBytes != null) ...[
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text('Tanda Tangan Digital:', style: const pw.TextStyle(fontSize: 7)),
                        pw.SizedBox(height: 4),
                        pw.Image(pw.MemoryImage(signatureBytes), width: 100, height: 40),
                        pw.SizedBox(height: 2),
                        pw.Text(customerName, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ],

                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text('*** Terima Kasih ***', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                ),
                pw.Center(
                  child: pw.Text('Barang yang sudah dibeli tidak dapat ditukar/dikembalikan', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'struk-$invoiceNo.pdf');
  }
}
