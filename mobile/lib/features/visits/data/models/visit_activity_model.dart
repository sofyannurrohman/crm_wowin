import '../../domain/entities/visit_activity.dart';

class VisitActivityModel extends VisitActivity {
  const VisitActivityModel({
    required super.id,
    super.scheduleId,
    required super.salesId,
    required super.customerId,
    super.leadId,
    required super.type,
    required super.latitude,
    required super.longitude,
    super.photoPath,
    super.selfiePhotoPath,
    super.placePhotoPath,
    super.distance,
    required super.isOffline,
    super.notes,
    super.dealId,
    super.dealTitle,
    super.taskCompleted = false,
    required super.createdAt,
  });

  factory VisitActivityModel.fromJson(Map<String, dynamic> json) {
    return VisitActivityModel(
      id: json['id'] ?? '',
      scheduleId: json['schedule_id'],
      salesId: json['sales_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      leadId: json['lead_id'],
      type: json['type'] ?? 'unknown',
      latitude: (json['latitude'] ?? json['lat'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? json['lon'] ?? 0.0).toDouble(),
      photoPath: json['photo_path'],
      selfiePhotoPath: json['selfie_photo_path'],
      placePhotoPath: json['place_photo_path'],
      distance: (json['distance'] != null) ? (json['distance'] as num).toDouble() : null,
      isOffline: json['is_offline'] ?? false,
      notes: json['notes'],
      dealId: json['deal_id'],
      dealTitle: json['deal_title'],
      taskCompleted: json['task_completed'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']).toLocal() 
          : DateTime.now(),
    );
  }
}
