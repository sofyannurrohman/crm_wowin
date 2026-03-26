import '../../domain/entities/attendance_record.dart';

class AttendanceModel extends AttendanceRecord {
  const AttendanceModel({
    String? id,
    required String type,
    required double latitude,
    required double longitude,
    String? address,
    String? photoPath,
    required DateTime timestampAt,
    String? notes,
  }) : super(
          id: id,
          type: type,
          latitude: latitude,
          longitude: longitude,
          address: address,
          photoPath: photoPath,
          timestampAt: timestampAt,
          notes: notes,
        );

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      type: json['type'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'],
      photoPath: json['photo_path'],
      timestampAt: DateTime.parse(json['timestamp_at']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'photo_path': photoPath,
      'timestamp_at': timestampAt.toIso8601String(),
      'notes': notes,
    };
  }
}
