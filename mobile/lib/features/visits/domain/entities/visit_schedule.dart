import 'package:equatable/equatable.dart';

class VisitSchedule extends Equatable {
  final String id;
  final String salesId;
  final String customerId;
  final String? dealId;
  final DateTime date;
  final String title;
  final String? objective;
  final String status;
  final String? notes;

  const VisitSchedule({
    required this.id,
    required this.salesId,
    required this.customerId,
    this.dealId,
    required this.date,
    required this.title,
    this.objective,
    required this.status,
    this.notes,
  });

  factory VisitSchedule.fromJson(Map<String, dynamic> json) {
    return VisitSchedule(
      id: json['id'],
      salesId: json['sales_id'],
      customerId: json['customer_id'],
      dealId: json['deal_id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      objective: json['objective'],
      status: json['status'],
      notes: json['notes'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        salesId,
        customerId,
        dealId,
        date,
        title,
        objective,
        status,
        notes,
      ];
}
