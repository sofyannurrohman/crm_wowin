import 'package:equatable/equatable.dart';
import '../../customers/domain/entities/customer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapDataLoaded extends MapState {
  final List<Customer> customers;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final LatLng? userLocation;

  const MapDataLoaded({
    required this.customers,
    required this.markers,
    this.polylines = const {},
    this.userLocation,
  });

  @override
  List<Object?> get props => [customers, markers, polylines, userLocation];
}

class MapError extends MapState {
  final String message;
  const MapError(this.message);

  @override
  List<Object> get props => [message];
}
