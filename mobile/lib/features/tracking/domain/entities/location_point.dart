class LocationPoint {
  final int? id; // SQLite ID
  final double latitude;
  final double longitude;
  final double speed;
  final double accuracy;
  final DateTime capturedAt;

  LocationPoint({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.accuracy,
    required this.capturedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'accuracy': accuracy,
      'captured_at': capturedAt.toIso8601String(),
    };
  }

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      id: map['id'] as int?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      speed: map['speed'] as double,
      accuracy: map['accuracy'] as double,
      capturedAt: DateTime.parse(map['captured_at'] as String),
    );
  }

  // Formatting for Backend specific sync array format
  Map<String, dynamic> toJsonApi() {
    return {
      'lat': latitude,
      'lng': longitude,
      'speed': speed,
      'accuracy': accuracy,
      'captured_at': capturedAt.toIso8601String(),
    };
  }
}
