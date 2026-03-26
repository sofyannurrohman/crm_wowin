import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  final String? id;
  final String type;
  final double latitude;
  final double longitude;
  final String? address;
  final String? photoPath;
  final DateTime timestampAt;
  final String? notes;

  const AttendanceRecord({
    this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.address,
    this.photoPath,
    required this.timestampAt,
    this.notes,
  });

  @override
  List<Object?> get props => [id, type, latitude, longitude, address, photoPath, timestampAt, notes];
}
