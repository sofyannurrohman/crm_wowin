import 'package:equatable/equatable.dart';
import '../../../customers/domain/entities/customer.dart';
import 'package:latlong2/latlong.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class FetchMapData extends MapEvent {}

class UpdateUserLocation extends MapEvent {
  final LatLng location;
  const UpdateUserLocation(this.location);

  @override
  List<Object> get props => [location];
}
