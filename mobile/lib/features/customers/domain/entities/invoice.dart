import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

enum InvoiceStatus {
  @JsonValue('unpaid')
  unpaid,
  @JsonValue('partial')
  partial,
  @JsonValue('paid')
  paid,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
abstract class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'deal_id') String? dealId,
    @JsonKey(name: 'invoice_no') required String invoiceNo,
    required double amount,
    @JsonKey(name: 'paid_amount') required double paidAmount,
    required InvoiceStatus status,
    @JsonKey(name: 'due_at') DateTime? dueAt,
    @JsonKey(name: 'signature_path') String? signaturePath,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @Default([]) List<InvoiceItem> items,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);
}

@freezed
abstract class InvoiceItem with _$InvoiceItem {
  const factory InvoiceItem({
    required String id,
    @JsonKey(name: 'invoice_id') required String invoiceId,
    @JsonKey(name: 'product_id') required String productId,
    required String name,
    required double quantity,
    required String unit,
    @JsonKey(name: 'unit_price') required double unitPrice,
    required double subtotal,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);
}
