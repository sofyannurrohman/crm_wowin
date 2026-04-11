import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_state.dart';
import '../bloc/task_event.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_destination.dart';
import 'package:geolocator/geolocator.dart';

class RoutePlannerPage extends StatefulWidget {
  final Task task;

  const RoutePlannerPage({super.key, required this.task});

  @override
  State<RoutePlannerPage> createState() => _RoutePlannerPageState();
}

class _RoutePlannerPageState extends State<RoutePlannerPage> {
  late Task _currentTask;
  bool _isProcessing = false;


  LatLng get _warehouseLocation {
    if (_currentTask.warehouse?.latitude != null && _currentTask.warehouse?.longitude != null) {
      return LatLng(_currentTask.warehouse!.latitude!, _currentTask.warehouse!.longitude!);
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
    _currentTask = widget.task;
    _calculateAndFetchRoute();
  }

  Future<void> _calculateAndFetchRoute() async {
    setState(() {
      _isLoadingRoute = true;
      _routeError = null;
    });

    try {
      LatLng currentLoc = _warehouseLocation;
      try {
        final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 3));
        currentLoc = LatLng(position.latitude, position.longitude);
      } catch (e) {
        debugPrint('Geolocator error in Route Planner: $e');
      }

      // Separate completed vs unvisited
      List<TaskDestination> doneDests = _currentTask.destinations.where((d) => d.status == TaskStatus.done).toList();
      List<TaskDestination> unvisited = _currentTask.destinations.where((d) => d.status != TaskStatus.done).toList();
      
      List<TaskDestination> optimized = [];
      List<LatLng> waypoints = [_warehouseLocation];
      currentLoc = _warehouseLocation;

      // 1. Add already visited tasks (done)
      for (var dest in doneDests) {
        optimized.add(dest);
        if (dest.targetLatitude != null && dest.targetLongitude != null) {
          final loc = LatLng(dest.targetLatitude!, dest.targetLongitude!);
          waypoints.add(loc);
          currentLoc = loc; // Update currentLoc to last visited
        }
      }

      // 2. Simple Greedy Optimization for UNVISITED tasks
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
      final safeList = _currentTask.destinations.where((d) => d.targetLatitude != null && d.targetLongitude != null).toList();
      setState(() {
        _isLoadingRoute = false;
        if (_optimizedRoute.isEmpty) _optimizedRoute = safeList;
        _routeError = 'Gagal memuat peta rute jalan. Menampilkan garis lurus.';
        _routePoints = [_warehouseLocation, ..._optimizedRoute.where((d) => d.targetLatitude != null && d.targetLongitude != null).map((d) => LatLng(d.targetLatitude!, d.targetLongitude!))];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TasksLoaded) {
          // If the tasks are reloaded, find our specific task and update it
          try {
            final updatedTask = state.tasks.firstWhere((t) => t.id == _currentTask.id);
            // Deep check or just check status/destinations
            if (updatedTask.destinations.length != _currentTask.destinations.length || 
                updatedTask.destinations.any((d) => d.status != _currentTask.destinations.firstWhere((old) => old.id == d.id).status)) {
              setState(() {
                _currentTask = updatedTask;
              });
              _calculateAndFetchRoute();
            }
          } catch (e) {
            // Task might have been deleted or not in this list anymore
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text(_currentTask.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, size: 20),
              onPressed: () {
                context.read<TaskBloc>().add(const FetchTasks());
                _calculateAndFetchRoute();
              },
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
                                  color: dest.status == TaskStatus.done 
                                      ? Colors.green 
                                      : (dest.status == TaskStatus.in_progress ? Colors.orange : Colors.red),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Center(
                                  child: dest.status == TaskStatus.in_progress
                                      ? const Icon(LucideIcons.activity, color: Colors.white, size: 14)
                                      : Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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
                    title: 'Start: ${_currentTask.warehouse?.name ?? "Gudang Asal"}',
                    subtitle: _currentTask.warehouse?.address ?? 'Titik Keberangkatan',
                    leading: const Icon(LucideIcons.warehouse, color: Colors.orange, size: 20),
                    status: TaskStatus.pending,
                    isFirst: true,
                  );
                }
                final dest = _optimizedRoute[index - 1];
                final destName = (dest.targetName == null || dest.targetName!.isEmpty) ? 'Target Kunjungan' : dest.targetName!;
                final destAddress = (dest.targetAddress == null || dest.targetAddress!.isEmpty) ? 'Tidak ada detail alamat' : dest.targetAddress!;

                return _buildListTile(
                  title: destName,
                  subtitle: destAddress,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: (dest.status == TaskStatus.done ? Colors.green : const Color(0xFF3B82F6)).withOpacity(0.1),
                    child: Text('$index', style: TextStyle(color: dest.status == TaskStatus.done ? Colors.green : const Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  dealTitle: dest.dealTitle,
                  status: dest.status,
                  onTap: () async {
                    if (dest.status == TaskStatus.done || _isProcessing) return;
                    
                    setState(() => _isProcessing = true);
                    
                    if (dest.status == TaskStatus.in_progress) {
                      await context.pushNamed(kRouteOngoingVisit, extra: {
                        'scheduleId': 'task',
                        'customerName': destName,
                        'leadId': dest.leadId,
                        'customerId': dest.customerId,
                        'taskDestinationId': dest.id,
                        'checkInTime': dest.updatedAt, // Fallback to last update
                        'dealId': dest.dealId,
                      });
                      if (mounted) setState(() => _isProcessing = false);
                      return;
                    }

                    await context.pushNamed(kRouteCheckIn, extra: {
                      'scheduleId': 'task',
                      'customerName': destName,
                      'customerAddress': destAddress,
                      'targetLat': dest.targetLatitude,
                      'targetLng': dest.targetLongitude,
                      'taskDestinationId': dest.id,
                      'dealId': dest.dealId,
                    });
                    if (mounted) setState(() => _isProcessing = false);
                  },

                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title, 
    required String subtitle, 
    required Widget leading, 
    required TaskStatus status,
    String? dealTitle, 
    bool isFirst = false, 
    VoidCallback? onTap
  }) {
    Color bgColor = Colors.white;
    Widget? statusIcon;
    bool isDone = status == TaskStatus.done;
    bool isInProgress = status == TaskStatus.in_progress;

    if (isFirst) {
      bgColor = const Color(0xFFF3FBF7);
    } else if (isDone) {
      bgColor = Colors.grey.shade50;
    } else if (isInProgress) {
      bgColor = Colors.orange.withOpacity(0.05);
    }

    if (isDone) {
      statusIcon = const Icon(LucideIcons.checkCircle, color: Colors.green, size: 20);
    } else if (isInProgress) {
      statusIcon = const Icon(LucideIcons.activity, color: Colors.orange, size: 20);
    } else if (!isFirst) {
      statusIcon = const Icon(LucideIcons.clock, color: Colors.grey, size: 20);
    }

    return GestureDetector(
      onTap: isDone ? null : onTap,
      child: Opacity(
        opacity: isDone ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isFirst ? Colors.green.withOpacity(0.1) : Colors.grey.shade100),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                        if (isDone) 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('DONE', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                        if (isInProgress)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('ONGOING', style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
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
      ),
    );
  }
}
