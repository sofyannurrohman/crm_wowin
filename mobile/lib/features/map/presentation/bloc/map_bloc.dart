import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' hide MapEvent;
import 'package:latlong2/latlong.dart';
import '../../../customers/domain/usecases/get_customers.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetCustomers getCustomers;

  MapBloc({
    required this.getCustomers,
  }) : super(MapInitial()) {
    on<FetchMapData>(_onFetchMapData);
    on<UpdateUserLocation>(_onUpdateUserLocation);
  }

  Future<void> _onFetchMapData(
    FetchMapData event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());
    final result = await getCustomers();
    result.fold(
      (failure) => emit(MapError(failure.message)),
      (customers) {
        final markers = customers
            .where((c) => c.latitude != null && c.longitude != null)
            .map((c) => Marker(
                  point: LatLng(c.latitude!, c.longitude!),
                  child: const Icon(Icons.location_on, color: Colors.blue, size: 30),
                ))
            .toSet();
        emit(MapDataLoaded(customers: customers, markers: markers));
      },
    );
  }

  void _onUpdateUserLocation(
    UpdateUserLocation event,
    Emitter<MapState> emit,
  ) {
    if (state is MapDataLoaded) {
      final currentState = state as MapDataLoaded;
      emit(MapDataLoaded(
        customers: currentState.customers,
        markers: currentState.markers,
        polylines: currentState.polylines,
        userLocation: event.location,
      ));
    }
  }
}
