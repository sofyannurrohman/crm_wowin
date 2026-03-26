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
  final String notes;

  const CheckInSubmitted({
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.photoFile,
    required this.notes,
  });

  @override
  List<Object> get props => [scheduleId, latitude, longitude, photoFile, notes];
}

class CheckOutSubmitted extends VisitEvent {
  final String scheduleId;
  final double latitude;
  final double longitude;
  final String visitResult;
  final String nextAction;
  final String nextVisitDate;

  const CheckOutSubmitted({
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    required this.visitResult,
    required this.nextAction,
    this.nextVisitDate = '',
  });

  @override
  List<Object> get props => [scheduleId, latitude, longitude, visitResult, nextAction, nextVisitDate];
}
