import '../../domain/entities/visit_activity.dart';

class VisitActivityModel extends VisitActivity {
  const VisitActivityModel({
    required super.id,
    super.scheduleId,
    required super.salesId,
    required super.customerId,
    required super.type,
    required super.latitude,
    required super.longitude,
    super.photoPath,
    super.selfiePhotoPath,
    super.placePhotoPath,
    super.distance,
    required super.isOffline,
    super.notes,
    required super.createdAt,
  });

  factory VisitActivityModel.fromJson(Map<String, dynamic> json) {
    return VisitActivityModel(
      id: json['id'],
      scheduleId: json['schedule_id'],
      salesId: json['sales_id'],
      customerId: json['customer_id'],
      type: json['type'], // 'checkin' or 'checkout'
      latitude: (json['lat'] ?? 0.0).toDouble(),
      longitude: (json['lon'] ?? 0.0).toDouble(),
      photoPath: json['photo_path'],
      selfiePhotoPath: json['selfie_photo_path'],
      placePhotoPath: json['place_photo_path'],
      distance: (json['distance'] != null) ? (json['distance'] as num).toDouble() : null,
      isOffline: json['is_offline'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
