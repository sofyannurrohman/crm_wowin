import 'package:equatable/equatable.dart';

enum VisitActivityType { checkin, checkout }

class VisitActivity extends Equatable {
  final String id;
  final String? scheduleId;
  final String salesId;
  final String customerId;
  final String? leadId;
  final String type;
  final double latitude;
  final double longitude;
  final String? photoPath;
  final String? selfiePhotoPath;
  final String? placePhotoPath;
  final double? distance;
  final bool isOffline;
  final String? notes;
  final String? outcome;
  final String? dealId;
  final String? dealTitle;
  final bool taskCompleted;
  final DateTime createdAt;

  const VisitActivity({
    required this.id,
    this.scheduleId,
    required this.salesId,
    required this.customerId,
    this.leadId,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.photoPath,
    this.selfiePhotoPath,
    this.placePhotoPath,
    this.distance,
    required this.isOffline,
    this.notes,
    this.outcome,
    this.dealId,
    this.dealTitle,
    this.taskCompleted = false,
    required this.createdAt,
  });

  factory VisitActivity.fromJson(Map<String, dynamic> json) {
    return VisitActivity(
      id: json['id'],
      scheduleId: json['schedule_id'],
      salesId: json['sales_id'],
      customerId: json['customer_id'],
      type: json['type'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      photoPath: json['photo_path'],
      selfiePhotoPath: json['selfie_photo_path'],
      placePhotoPath: json['place_photo_path'],
      distance: (json['distance'] as num?)?.toDouble(),
      isOffline: json['is_offline'] ?? false,
      notes: json['notes'],
      outcome: json['outcome'],
      dealId: json['deal_id'],
      dealTitle: json['deal_title'],
      taskCompleted: json['task_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        scheduleId,
        salesId,
        customerId,
        type,
        latitude,
        longitude,
        photoPath,
        selfiePhotoPath,
        placePhotoPath,
        distance,
        isOffline,
        notes,
        outcome,
        dealId,
        dealTitle,
        taskCompleted,
        createdAt,
      ];
}
