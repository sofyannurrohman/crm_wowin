import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class VisitEvent extends Equatable {
  const VisitEvent();

  @override
  List<Object?> get props => [];
}

class CheckInSubmitted extends VisitEvent {
  final String scheduleId;
  final double latitude;
  final double longitude;
  final File photoFile;
  final File? selfiePhotoFile;
  final String notes;
  final String? dealId;
  final String? overrideReason;
  final String? customerName;

  const CheckInSubmitted({
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.photoFile,
    this.selfiePhotoFile,
    required this.notes,
    this.dealId,
    this.overrideReason,
    this.customerName,
  });

  @override
  List<Object?> get props => [scheduleId, latitude, longitude, photoFile, selfiePhotoFile, notes, dealId, overrideReason, customerName];
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

  const CheckOutSubmitted({
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.visitResult,
    required this.nextAction,
    this.nextVisitDate = '',
    this.signaturePath,
    this.inventoryData,
  });

  @override
  List<Object?> get props =>
      [scheduleId, latitude, longitude, visitResult, nextAction, nextVisitDate, signaturePath, inventoryData];
}

class FetchActivities extends VisitEvent {
  final String? salesId;
  final String? customerId;

  const FetchActivities({this.salesId, this.customerId});

  @override
  List<Object?> get props => [salesId, customerId];
}
