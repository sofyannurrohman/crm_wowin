import 'package:equatable/equatable.dart';

enum VisitActivityType { checkin, checkout }

class VisitActivity extends Equatable {
  final String id;
  final String? scheduleId;
  final String salesId;
  final String customerId;
  final String type;
  final double latitude;
  final double longitude;
  final String? photoPath;
  final String? selfiePhotoPath;
  final String? placePhotoPath;
  final double? distance;
  final bool isOffline;
  final String? notes;
  final DateTime createdAt;

  const VisitActivity({
    required this.id,
    this.scheduleId,
    required this.salesId,
    required this.customerId,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.photoPath,
    this.selfiePhotoPath,
    this.placePhotoPath,
    this.distance,
    required this.isOffline,
    this.notes,
    required this.createdAt,
  });

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
        createdAt,
      ];
}
