import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  final Map<String, dynamic> data;

  const UserSettings({required this.data});

  @override
  List<Object?> get props => [data];

  // Helper getters for common settings
  bool get notificationsEnabled => data['mobile.notifications_enabled'] ?? true;
  bool get darkModeEnabled => data['mobile.dark_mode_enabled'] ?? false;
  String get language => data['mobile.language'] ?? 'English';
  int get gpsIntervalSeconds => data['tracking.interval_seconds'] ?? 300;
}
