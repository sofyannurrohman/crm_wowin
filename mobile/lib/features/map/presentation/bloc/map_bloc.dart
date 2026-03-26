import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../customers/domain/usecases/get_customers.dart';
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
                  markerId: MarkerId(c.id),
                  position: LatLng(c.latitude!, c.longitude!),
                  infoWindow: InfoWindow(
                    title: c.name,
                    snippet: c.companyName ?? c.address,
                  ),
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
