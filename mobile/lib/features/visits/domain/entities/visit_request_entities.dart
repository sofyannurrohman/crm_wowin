import 'dart:io';

class CheckInRequest {
  final String scheduleId;
  final double latitude;
  final double longitude;
  final File photoFile;
  final String checkInNotes;
  final String? dealId;
  final File? selfiePhotoFile;
  final String? overrideReason;

  CheckInRequest({
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.photoFile,
    this.selfiePhotoFile,
    this.checkInNotes = '',
    this.dealId,
    this.overrideReason,
  });
}

class CheckOutRequest {
  final String scheduleId;
  final double latitude;
  final double longitude;
  final String visitResult;
  final String nextAction;
  final String nextVisitDate; // ISO 8601 string or format expected by API

  final String? signaturePath;
  final String? inventoryData; // JSON formatted string for stock check

  CheckOutRequest({
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.visitResult,
    required this.nextAction,
    this.nextVisitDate = '',
    this.signaturePath,
    this.inventoryData,
  });
}
