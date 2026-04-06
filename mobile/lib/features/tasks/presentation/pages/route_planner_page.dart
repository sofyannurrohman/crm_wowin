import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_destination.dart';

class RoutePlannerPage extends StatefulWidget {
  final Task task;

  const RoutePlannerPage({super.key, required this.task});

  @override
  State<RoutePlannerPage> createState() => _RoutePlannerPageState();
}

class _RoutePlannerPageState extends State<RoutePlannerPage> {
  LatLng get _warehouseLocation {
    if (widget.task.warehouse?.latitude != null && widget.task.warehouse?.longitude != null) {
      return LatLng(widget.task.warehouse!.latitude!, widget.task.warehouse!.longitude!);
    }
    // Fallback to PT Wowin Purnomo Putera if warehouse data is missing
    return const LatLng(-6.1754, 106.8272);
  }
  List<TaskDestination> _optimizedRoute = [];
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _calculateOptimizedRoute();
  }

  void _calculateOptimizedRoute() {
    List<TaskDestination> unvisited = List.from(widget.task.destinations);
    LatLng currentLoc = _warehouseLocation;
    
    List<TaskDestination> optimized = [];
    List<LatLng> points = [_warehouseLocation];

    while (unvisited.isNotEmpty) {
      double minDistance = double.infinity;
      int nearestIndex = -1;
      
      for (int i = 0; i < unvisited.length; i++) {
        final dest = unvisited[i];
        if (dest.targetLatitude != null && dest.targetLongitude != null) {
          final destLoc = LatLng(dest.targetLatitude!, dest.targetLongitude!);
          // Calculate distance approximation for nearest neighbor
          final distance = const Distance().as(LengthUnit.Meter, currentLoc, destLoc);
          if (distance < minDistance) {
            minDistance = distance;
            nearestIndex = i;
          }
        }
      }

      if (nearestIndex != -1) {
        final nearestDest = unvisited.removeAt(nearestIndex);
        optimized.add(nearestDest);
        currentLoc = LatLng(nearestDest.targetLatitude!, nearestDest.targetLongitude!);
        points.add(currentLoc);
      } else {
        // If coordinate is null, just append at the end
        optimized.addAll(unvisited);
        unvisited.clear();
      }
    }

    setState(() {
      _optimizedRoute = optimized;
      _routePoints = points;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Route: ${widget.task.title}')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _warehouseLocation,
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _warehouseLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(LucideIcons.warehouse, color: Colors.orange, size: 30),
                    ),
                    ..._optimizedRoute.map((dest) {
                      if (dest.targetLatitude == null || dest.targetLongitude == null) return null;
                      return Marker(
                        point: LatLng(dest.targetLatitude!, dest.targetLongitude!),
                        width: 40,
                        height: 40,
                        child: const Icon(LucideIcons.mapPin, color: Colors.red, size: 25),
                      );
                    }).whereType<Marker>(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildRouteList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteList() {
    return ListView.builder(
      itemCount: _optimizedRoute.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            leading: const Icon(LucideIcons.warehouse, color: Colors.orange),
            title: Text('START: ${widget.task.warehouse?.name ?? "Gudang"}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.task.warehouse?.address ?? 'Titik Awal'),
          );
        }
        final dest = _optimizedRoute[index - 1];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Text('$index', style: const TextStyle(color: Colors.blue)),
          ),
          title: Text(dest.targetName ?? 'Target Destination', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(dest.targetAddress ?? 'Tidak ada alamat'),
          trailing: dest.status == TaskStatus.COMPLETED 
              ? const Icon(LucideIcons.checkCircle, color: Colors.green)
              : const Icon(LucideIcons.clock, color: Colors.grey),
        );
      },
    );
  }
}
