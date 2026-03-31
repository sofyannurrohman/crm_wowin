import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../../../../core/theme/app_colors.dart';

class CustomerMapPage extends StatefulWidget {
  const CustomerMapPage({super.key});

  @override
  State<CustomerMapPage> createState() => _CustomerMapPageState();
}

class _CustomerMapPageState extends State<CustomerMapPage> {
  final MapController _mapController = MapController();
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
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 20),
            onPressed: () => context.read<MapBloc>().add(FetchMapData()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MapDataLoaded) {
            return FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _initialPosition,
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.wowin.crm',
                ),
                PolylineLayer(
                  polylines: state.polylines.toList(),
                ),
                MarkerLayer(
                  markers: state.markers.toList(),
                ),
              ],
            );
          } else if (state is MapError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<MapBloc>().add(FetchMapData()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.person, size: 20),
      ),
    );
  }
}
