import 'dart:io';

class CheckInRequest {
  final String scheduleId;
  final double latitude;
  final double longitude;
  final File photoFile;
  final String checkInNotes;

  CheckInRequest({
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.photoFile,
    this.checkInNotes = '',
  });
}

class CheckOutRequest {
  final String scheduleId;
  final double latitude;
  final double longitude;
  final String visitResult;
  final String nextAction;
  final String nextVisitDate; // ISO 8601 string or format expected by API

  CheckOutRequest({
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.visitResult,
    required this.nextAction,
    this.nextVisitDate = '',
  });
}
