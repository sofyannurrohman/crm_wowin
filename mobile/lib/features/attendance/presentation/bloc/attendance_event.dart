import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class FetchAttendanceHistory extends AttendanceEvent {
  final int month;
  final int year;

  const FetchAttendanceHistory({required this.month, required this.year});

  @override
  List<Object> get props => [month, year];
}

class ClockInSubmitted extends AttendanceEvent {
  final double lat;
  final double lng;
  final String photoPath;
  final String? address;
  final String? notes;

  const ClockInSubmitted({
    required this.lat,
    required this.lng,
    required this.photoPath,
    this.address,
    this.notes,
  });

  @override
  List<Object> get props => [lat, lng, photoPath, address ?? '', notes ?? ''];
}

class ClockOutSubmitted extends AttendanceEvent {
  final double lat;
  final double lng;
  final String photoPath;
  final String? address;
  final String? notes;

  const ClockOutSubmitted({
    required this.lat,
    required this.lng,
    required this.photoPath,
    this.address,
    this.notes,
  });

  @override
  List<Object> get props => [lat, lng, photoPath, address ?? '', notes ?? ''];
}
