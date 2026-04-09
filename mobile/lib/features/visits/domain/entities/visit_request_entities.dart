import 'package:camera/camera.dart';

class CheckInRequest {
  final String scheduleId;
  final double latitude;
  final double longitude;
  final XFile photoFile;
  final String checkInNotes;
  final String? dealId;
  final XFile? selfiePhotoFile;
  final String? overrideReason;
  final String? taskDestinationId;
  final String? customerId;
  final String? leadId;
  final List<Map<String, dynamic>>? dealItems;

  CheckInRequest({
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.photoFile,
    this.selfiePhotoFile,
    this.checkInNotes = '',
    this.dealId,
    this.overrideReason,
    this.taskDestinationId,
    this.customerId,
    this.leadId,
    this.dealItems,
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
  final String? taskDestinationId;
  final String? customerId;
  final String? leadId;
  final double? priceOverride;
  final String? priceOverrideNote;

  CheckOutRequest({
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.visitResult,
    required this.nextAction,
    this.nextVisitDate = '',
    this.signaturePath,
    this.inventoryData,
    this.taskDestinationId,
    this.dealId,
    this.customerId,
    this.leadId,
    this.priceOverride,
    this.priceOverrideNote,
  });

  final String? dealId;
}
