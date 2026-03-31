import 'package:equatable/equatable.dart';

class VisitRecommendation extends Equatable {
  final String id;
  final String name;
  final String type; // "lead" or "customer"
  final String status; // "new", "stale", "scheduled"
  final String priority; // "high", "medium", "low"
  final String reason;
  final String? lastVisitAt;
  final int daysSinceLast;
  final String address;
  final double latitude;
  final double longitude;

  const VisitRecommendation({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.priority,
    required this.reason,
    this.lastVisitAt,
    required this.daysSinceLast,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory VisitRecommendation.fromJson(Map<String, dynamic> json) {
    return VisitRecommendation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
      reason: json['reason'] ?? '',
      lastVisitAt: json['last_visit_at'],
      daysSinceLast: (json['days_since_last'] as num?)?.toInt() ?? 0,
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        status,
        priority,
        reason,
        lastVisitAt,
        daysSinceLast,
        address,
        latitude,
        longitude
      ];
}
