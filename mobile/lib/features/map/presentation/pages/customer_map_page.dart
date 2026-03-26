import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';

class CustomerMapPage extends StatefulWidget {
  const CustomerMapPage({super.key});

  @override
  State<CustomerMapPage> createState() => _CustomerMapPageState();
}

class _CustomerMapPageState extends State<CustomerMapPage> {
  GoogleMapController? _controller;
  static const LatLng _initialPosition = LatLng(-6.200000, 106.816666); // Jakarta

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(FetchMapData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Pelanggan'),
      ),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MapDataLoaded) {
            return GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _initialPosition,
                zoom: 12,
              ),
              onMapCreated: (controller) => _controller = controller,
              markers: state.markers,
              polylines: state.polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            );
          } else if (state is MapError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<MapBloc>().add(FetchMapData()),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
