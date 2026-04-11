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
  final String? outcome;
  final double? priceOverride;
  final String? priceOverrideNote;
  final String? dealId;

  final List<Map<String, dynamic>>? dealItems;
  final String? paymentMethod;
  final String? paymentRef;
  final dynamic signatureBytes;

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
    this.outcome,
    this.priceOverride,
    this.priceOverrideNote,
    this.dealItems,
    this.paymentMethod,
    this.paymentRef,
    this.signatureBytes,
  });
}
