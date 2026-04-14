import 'dart:convert';

void main() {
  String jsonString = '''{
    "id":"e7720dc9-5672-4f3c-8764-3e3739e28fbd",
    "title":"Deal dari Kunjungan: Sofyan",
    "lead_id":"76c49502-1901-4150-9477-97ffc6d81571",
    "sales_id":"a6ce9b0c-21fd-4169-9773-feb37d720465",
    "stage":"closed_won",
    "status":"won",
    "amount":3500000,
    "probability":100,
    "closed_at":"2026-04-13T02:14:55Z",
    "created_by":"a6ce9b0c-21fd-4169-9773-feb37d720465",
    "created_at":"2026-04-13T02:14:55Z",
    "updated_at":null
  }''';
  var data = jsonDecode(jsonString);
  var deal = Deal.fromJson(data);
  print(deal.id);
}

class Deal {
  final String id;
  final String title;
  final String? customerId;
  final String? leadId;
  final String? contactId;
  final String stage;
  final String status;
  final double? amount;
  final int? probability;
  final DateTime? expectedClose;
  final String? description;
  final String? salesId;
  final String? salesmanName;

  Deal({
    required this.id,
    required this.title,
    this.customerId,
    this.leadId,
    this.contactId,
    required this.stage,
    required this.status,
    this.amount,
    this.probability,
    this.expectedClose,
    this.description,
    this.salesId,
    this.salesmanName,
  });

  factory Deal.fromJson(Map<String, dynamic> json) => Deal(
      id: json['id'] as String,
      title: json['title'] as String,
      customerId: json['customer_id'] as String?,
      leadId: json['lead_id'] as String?,
      contactId: json['contact_id'] as String?,
      stage: json['stage'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      probability: (json['probability'] as num?)?.toInt(),
      expectedClose: json['expected_close'] == null
          ? null
          : DateTime.parse(json['expected_close'] as String),
      description: json['description'] as String?,
      salesId: json['sales_id'] as String?,
      salesmanName: json['salesman_name'] as String?,
    );
}
