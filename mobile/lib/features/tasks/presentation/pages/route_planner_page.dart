import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_state.dart';
import '../bloc/task_event.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
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
        debugPrint('Geolocator error: $e');
      }

      List<TaskDestination> doneDests = _currentTask.destinations.where((d) => d.status == TaskStatus.done).toList();
      List<TaskDestination> unvisited = _currentTask.destinations.where((d) => d.status != TaskStatus.done).toList();
      
      List<TaskDestination> optimized = [];
      List<LatLng> waypoints = [_warehouseLocation];
      currentLoc = _warehouseLocation;

      for (var dest in doneDests) {
        optimized.add(dest);
        if (dest.targetLatitude != null && dest.targetLongitude != null) {
          final loc = LatLng(dest.targetLatitude!, dest.targetLongitude!);
          waypoints.add(loc);
          currentLoc = loc;
        }
      }

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
        _routeError = 'Traffic-aware route failed. Using direct connections.';
        _routePoints = [_warehouseLocation, ..._optimizedRoute.where((d) => d.targetLatitude != null && d.targetLongitude != null).map((d) => LatLng(d.targetLatitude!, d.targetLongitude!))];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TasksLoaded) {
          try {
            final updatedTask = state.tasks.firstWhere((t) => t.id == _currentTask.id);
            if (updatedTask.status == TaskStatus.done) {
              if (mounted) context.pop();
              return;
            }
            if (updatedTask.destinations.length != _currentTask.destinations.length || 
                updatedTask.destinations.any((d) => d.status != _currentTask.destinations.firstWhere((old) => old.id == d.id).status)) {
              setState(() => _currentTask = updatedTask);
              _calculateAndFetchRoute();
            }
          } catch (_) {}
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_currentTask.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(onPressed: () => context.pop(), icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary)),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, size: 20, color: AppColors.primary),
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
                      initialZoom: 12.5,
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
                              strokeWidth: 6.0,
                              color: AppColors.primary,
                              borderColor: Colors.white,
                              borderStrokeWidth: 2.0,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _warehouseLocation,
                            width: 50,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                              child: const Icon(LucideIcons.home, color: Color(0xFFF59E0B), size: 24),
                            ),
                          ),
                          ...List.generate(_optimizedRoute.length, (idx) {
                            final dest = _optimizedRoute[idx];
                            if (dest.targetLatitude == null || dest.targetLongitude == null) return null;
                            final isDone = dest.status == TaskStatus.done;
                            final isInProgress = dest.status == TaskStatus.in_progress;
                            return Marker(
                              point: LatLng(dest.targetLatitude!, dest.targetLongitude!),
                              width: 38,
                              height: 38,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDone ? const Color(0xFF22C55E) : (isInProgress ? const Color(0xFF3B82F6) : AppColors.primary),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
                                ),
                                child: Center(
                                  child: isDone 
                                      ? const Icon(LucideIcons.check, color: Colors.white, size: 16)
                                      : Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
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
                      color: Colors.white.withOpacity(0.6),
                      child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    ),
                  if (_routeError != null)
                     Positioned(
                       top: 16, left: 16, right: 16,
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                         decoration: BoxDecoration(color: const Color(0xFFFEF3C7).withOpacity(0.95), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFDE68A))),
                         child: Row(
                           children: [
                             const Icon(LucideIcons.alertTriangle, color: Color(0xFFD97706), size: 18),
                             const SizedBox(width: 12),
                             Expanded(child: Text(_routeError!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF92400E)))),
                           ],
                         ),
                       ),
                     ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildRouteSheet(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Text('Visit Sequence', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _optimizedRoute.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildListTile(
                    title: 'Departure: ${_currentTask.warehouse?.name ?? "Warehouse"}',
                    subtitle: _currentTask.warehouse?.address ?? 'Starting Point',
                    icon: LucideIcons.home,
                    iconColor: const Color(0xFFF59E0B),
                    status: TaskStatus.pending,
                    isFirst: true,
                  );
                }
                final dest = _optimizedRoute[index - 1];
                final destName = (dest.targetName == null || dest.targetName!.isEmpty) ? 'Target Location' : dest.targetName!;
                final destAddress = (dest.targetAddress == null || dest.targetAddress!.isEmpty) ? 'Address not specified' : dest.targetAddress!;

                return _buildListTile(
                  index: index,
                  title: destName,
                  subtitle: destAddress,
                  dealTitle: dest.dealTitle,
                  status: dest.status,
                  onTap: () {
                    if (dest.status == TaskStatus.done || _isProcessing) return;
                    setState(() => _isProcessing = true);
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) setState(() => _isProcessing = false);
                    });
                    
                    if (dest.status == TaskStatus.in_progress) {
                      context.pushNamed(kRouteOngoingVisit, extra: {
                        'scheduleId': 'task',
                        'customerName': destName,
                        'leadId': dest.leadId,
                        'customerId': dest.customerId,
                        'taskDestinationId': dest.id,
                        'checkInTime': dest.updatedAt ?? DateTime.now(),
                        'dealId': dest.dealId,
                      });
                      return;
                    }

                    context.pushNamed(kRouteCheckIn, extra: {
                      'scheduleId': 'task',
                      'customerName': destName,
                      'customerAddress': destAddress,
                      'targetLat': dest.targetLatitude,
                      'targetLng': dest.targetLongitude,
                      'taskDestinationId': dest.id,
                      'dealId': dest.dealId,
                      'customerId': dest.customerId,
                      'leadId': dest.leadId,
                    });
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
    int? index,
    required String title, 
    required String subtitle, 
    IconData? icon,
    Color? iconColor,
    required TaskStatus status,
    String? dealTitle, 
    bool isFirst = false, 
    VoidCallback? onTap
  }) {
    final bool isDone = status == TaskStatus.done;
    final bool isInProgress = status == TaskStatus.in_progress;
    
    return Opacity(
      opacity: isDone ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: isDone ? null : onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isInProgress ? AppColors.primary.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isInProgress ? AppColors.primary.withOpacity(0.2) : const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              if (isFirst)
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconColor?.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 18))
              else
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: isDone ? const Color(0xFFDCFCE7) : (isInProgress ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isDone 
                      ? const Icon(LucideIcons.check, color: Color(0xFF16A34A), size: 16)
                      : Text('$index', style: TextStyle(color: isInProgress ? const Color(0xFF2563EB) : AppColors.textSecondary, fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (dealTitle != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.briefcase, size: 10, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(dealTitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isInProgress)
                const Icon(LucideIcons.playCircle, color: Color(0xFF2563EB), size: 20).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 800.ms, curve: Curves.easeInOut)
              else if (!isFirst && !isDone)
                const Icon(LucideIcons.chevronRight, color: Color(0xFFCBD5E1), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
