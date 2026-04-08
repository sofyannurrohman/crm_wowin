import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
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
    return const LatLng(-6.1754, 106.8272);
  }

  List<TaskDestination> _optimizedRoute = [];
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = true;
  String? _routeError;

  @override
  void initState() {
    super.initState();
    _calculateAndFetchRoute();
  }

  Future<void> _calculateAndFetchRoute() async {
    setState(() {
      _isLoadingRoute = true;
      _routeError = null;
    });

    try {
      // 1. Simple Greedy Optimization (Nearest Neighbor)
      List<TaskDestination> unvisited = List.from(widget.task.destinations);
      LatLng currentLoc = _warehouseLocation;
      List<TaskDestination> optimized = [];
      List<LatLng> waypoints = [_warehouseLocation];

      while (unvisited.isNotEmpty) {
        double minDistance = double.infinity;
        int nearestIndex = -1;
        
        for (int i = 0; i < unvisited.length; i++) {
          final dest = unvisited[i];
          if (dest.targetLatitude != null && dest.targetLongitude != null) {
            final destLoc = LatLng(dest.targetLatitude!, dest.targetLongitude!);
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
          waypoints.add(currentLoc);
        } else {
          optimized.addAll(unvisited);
          unvisited.clear();
        }
      }

      // 2. Fetch OSRM Road-Following Geometry
      if (waypoints.length >= 2) {
        final coordsString = waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');
        final url = 'http://router.project-osrm.org/route/v1/driving/$coordsString?geometries=geojson&overview=full';
        
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            final geometry = data['routes'][0]['geometry']['coordinates'] as List;
            final List<LatLng> polyPoints = geometry.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
            
            setState(() {
              _optimizedRoute = optimized;
              _routePoints = polyPoints;
              _isLoadingRoute = false;
            });
            return;
          }
        }
      }

      // Fallback to straight lines if OSRM fails or waypoints < 2
      setState(() {
        _optimizedRoute = optimized;
        _routePoints = waypoints;
        _isLoadingRoute = false;
      });

    } catch (e) {
      debugPrint('Error fetching OSRM route: $e');
      setState(() {
        _isLoadingRoute = false;
        _routeError = 'Gagal memuat peta rute jalan. Menampilkan garis lurus.';
        // Fallback to simple points
        _routePoints = [_warehouseLocation, ...widget.task.destinations.map((d) => LatLng(d.targetLatitude ?? 0, d.targetLongitude ?? 0))];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(widget.task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: _calculateAndFetchRoute,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _warehouseLocation,
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.wowin.crm',
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 5.0,
                            color: const Color(0xFF3B82F6),
                            borderColor: Colors.white,
                            borderStrokeWidth: 1.0,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _warehouseLocation,
                          width: 45,
                          height: 45,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle),
                            child: const Icon(LucideIcons.warehouse, color: Colors.orange, size: 28),
                          ),
                        ),
                        ...List.generate(_optimizedRoute.length, (idx) {
                          final dest = _optimizedRoute[idx];
                          if (dest.targetLatitude == null || dest.targetLongitude == null) return null;
                          return Marker(
                            point: LatLng(dest.targetLatitude!, dest.targetLongitude!),
                            width: 35,
                            height: 35,
                            child: Container(
                              decoration: BoxDecoration(
                                color: dest.status == TaskStatus.done ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          );
                        }).whereType<Marker>(),
                      ],
                    ),
                  ],
                ),
                if (_isLoadingRoute)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                if (_routeError != null)
                   Positioned(
                     top: 10, left: 10, right: 10,
                     child: Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(color: Colors.amber.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                       child: Text(_routeError!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                     ),
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text('Optimized Visit Sequence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _optimizedRoute.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildListTile(
                    title: 'Start: ${widget.task.warehouse?.name ?? "Gudang Asal"}',
                    subtitle: widget.task.warehouse?.address ?? 'Titik Keberangkatan',
                    leading: const Icon(LucideIcons.warehouse, color: Colors.orange, size: 20),
                    isFirst: true,
                  );
                }
                final dest = _optimizedRoute[index - 1];
                return _buildListTile(
                  title: dest.targetName ?? 'Target Kunjungan',
                  subtitle: dest.targetAddress ?? 'Tidak ada detail alamat',
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: (dest.status == TaskStatus.done ? Colors.green : const Color(0xFF3B82F6)).withOpacity(0.1),
                    child: Text('$index', style: TextStyle(color: dest.status == TaskStatus.done ? Colors.green : const Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  dealTitle: dest.dealTitle,
                  statusIcon: dest.status == TaskStatus.done 
                      ? const Icon(LucideIcons.checkCircle, color: Colors.green, size: 20)
                      : const Icon(LucideIcons.clock, color: Colors.grey, size: 20),
                  onTap: () {
                    if (dest.status != TaskStatus.done) {
                      context.pushNamed(kRouteCheckIn, extra: {
                        'scheduleId': 'task',
                        'customerName': dest.targetName,
                        'customerAddress': dest.targetAddress,
                        'targetLat': dest.targetLatitude,
                        'targetLng': dest.targetLongitude,
                        'taskDestinationId': dest.id,
                        'dealId': dest.dealId,
                      });
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({required String title, required String subtitle, required Widget leading, Widget? statusIcon, String? dealTitle, bool isFirst = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isFirst ? const Color(0xFFF3FBF7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (dealTitle != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.briefcase, size: 10, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(dealTitle, style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (statusIcon != null) statusIcon,
          ],
        ),
      ),
    );
  }
}
