import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';

abstract class VisitEvent extends Equatable {
  const VisitEvent();

  @override
  List<Object?> get props => [];
}

class CheckInSubmitted extends VisitEvent {
  final String scheduleId;
  final double latitude;
  final double longitude;
  final XFile photoFile;
  final XFile? selfiePhotoFile;
  final String notes;
  final String? dealId;
  final String? overrideReason;
  final String? customerId;
  final String? leadId;
  final String? customerName;
  final String? taskDestinationId;
  final List<Map<String, dynamic>>? dealItems;

  const CheckInSubmitted({
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.photoFile,
    this.selfiePhotoFile,
    required this.notes,
    this.dealId,
    this.overrideReason,
    this.customerId,
    this.leadId,
    this.customerName,
    this.taskDestinationId,
    this.dealItems,
  });

  @override
  List<Object?> get props => [
        scheduleId,
        latitude,
        longitude,
        photoFile,
        selfiePhotoFile,
        notes,
        dealId,
        overrideReason,
        customerId,
        leadId,
        customerName,
        taskDestinationId,
        dealItems,
      ];
}


class CheckOutSubmitted extends VisitEvent {
  final String scheduleId;
  final double latitude;
  final double longitude;
  final String visitResult;
  final String nextAction;
  final String nextVisitDate;
  final String? signaturePath;
  final String? inventoryData;
  final String? taskDestinationId;
  final String? customerId;
  final String? leadId;
  final double? priceOverride;
  final String? priceOverrideNote;
  final String? dealId;
  final List<Map<String, dynamic>>? dealItems;
  final String? outcome;
  final String? paymentMethod;
  final String? paymentRef;
  final dynamic signatureBytes; // Uint8List? or similar

  const CheckOutSubmitted({
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.visitResult,
    required this.nextAction,
    this.nextVisitDate = '',
    this.signaturePath,
    this.inventoryData,
    this.taskDestinationId,
    this.customerId,
    this.leadId,
    this.priceOverride,
    this.priceOverrideNote,
    this.dealId,
    this.dealItems,
    this.outcome,
    this.paymentMethod,
    this.paymentRef,
    this.signatureBytes,
  });

  @override
  List<Object?> get props => [
        scheduleId,
        latitude,
        longitude,
        visitResult,
        nextAction,
        nextVisitDate,
        signaturePath,
        inventoryData,
        taskDestinationId,
        customerId,
        leadId,
        priceOverride,
        priceOverrideNote,
        dealId,
        dealItems,
        outcome,
        paymentMethod,
        paymentRef,
        signatureBytes,
      ];
}

class FetchActivities extends VisitEvent {
  final String? salesId;
  final String? customerId;
  final String? leadId;

  const FetchActivities({this.salesId, this.customerId, this.leadId});

  @override
  List<Object?> get props => [salesId, customerId, leadId];
}

class LinkDealToVisit extends VisitEvent {
  final String dealId;
  const LinkDealToVisit(this.dealId);

  @override
  List<Object?> get props => [dealId];
}

class RestoreActiveVisit extends VisitEvent {
  const RestoreActiveVisit();
}
