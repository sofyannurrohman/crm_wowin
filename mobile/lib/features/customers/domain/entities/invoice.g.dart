// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Invoice _$InvoiceFromJson(Map<String, dynamic> json) => _Invoice(
  id: json['id'] as String,
  customerId: json['customer_id'] as String,
  dealId: json['deal_id'] as String?,
  invoiceNo: json['invoice_no'] as String,
  amount: (json['amount'] as num).toDouble(),
  paidAmount: (json['paid_amount'] as num).toDouble(),
  status: $enumDecode(_$InvoiceStatusEnumMap, json['status']),
  dueAt: json['due_at'] == null
      ? null
      : DateTime.parse(json['due_at'] as String),
  signaturePath: json['signature_path'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$InvoiceToJson(_Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'customer_id': instance.customerId,
  'deal_id': instance.dealId,
  'invoice_no': instance.invoiceNo,
  'amount': instance.amount,
  'paid_amount': instance.paidAmount,
  'status': _$InvoiceStatusEnumMap[instance.status]!,
  'due_at': instance.dueAt?.toIso8601String(),
  'signature_path': instance.signaturePath,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'items': instance.items,
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.unpaid: 'unpaid',
  InvoiceStatus.partial: 'partial',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.cancelled: 'cancelled',
};

_InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => _InvoiceItem(
  id: json['id'] as String,
  invoiceId: json['invoice_id'] as String,
  productId: json['product_id'] as String,
  name: json['name'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  unit: json['unit'] as String,
  unitPrice: (json['unit_price'] as num).toDouble(),
  subtotal: (json['subtotal'] as num).toDouble(),
);

Map<String, dynamic> _$InvoiceItemToJson(_InvoiceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoice_id': instance.invoiceId,
      'product_id': instance.productId,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'unit_price': instance.unitPrice,
      'subtotal': instance.subtotal,
    };
