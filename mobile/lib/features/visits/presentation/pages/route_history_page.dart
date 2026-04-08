import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../domain/entities/visit_activity.dart';
import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';

class RouteHistoryPage extends StatefulWidget {
  const RouteHistoryPage({super.key});

  @override
  State<RouteHistoryPage> createState() => _RouteHistoryPageState();
}

class _RouteHistoryPageState extends State<RouteHistoryPage> {
  static const Color _green = Color(0xFF0D8549);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  DateTime _selectedDate = DateTime.now();
  List<LatLng> _polylinePoints = [];

  @override
  void initState() {
    super.initState();
    _fetchRouteHistory();
  }

  void _fetchRouteHistory() {
    context.read<VisitBloc>().add(const FetchActivities());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      drawer: const AppSidebar(),
      body: BlocConsumer<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is ActivitiesLoaded) {
            _calculatePolyline(state.activities);
          }
        },
        builder: (context, state) {
          if (state is VisitLoading) {
            return const Center(child: CircularProgressIndicator(color: _green));
          }

          List<VisitActivity> activities = [];
          if (state is ActivitiesLoaded) {
            activities = state.activities;
          }

          return RefreshIndicator(
            onRefresh: () async => _fetchRouteHistory(),
            color: _green,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalendarCard(),
                  const SizedBox(height: 20),
                  _buildMapPreview(activities),
                  const SizedBox(height: 16),
                  _buildMetricsRow(activities),
                  const SizedBox(height: 24),
                  const Text(
                    'VISITS TIMELINE',
                    style: TextStyle(
                      color: _green,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  activities.isEmpty 
                      ? _buildEmptyState()
                      : _buildTimelineList(activities),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _calculatePolyline(List<VisitActivity> activities) {
    // Filter activities with coordinates and sort by time
    final points = activities
        .where((a) => a.latitude != 0 && a.longitude != 0)
        .map((a) => LatLng(a.latitude, a.longitude))
        .toList();
    
    setState(() {
      _polylinePoints = points;
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(LucideIcons.menu, color: _green),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      centerTitle: true,
      title: const Text(
        'Route History',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.mapPin, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tidak ada aktivitas kunjungan',
            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Silakan lakukan check-in terlebih dahulu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(LucideIcons.calendar, color: _green, size: 20),
          Text(
            DateFormat('MMMM dd, yyyy').format(_selectedDate),
            style: const TextStyle(color: _green, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronDown, color: _green, size: 18),
            onPressed: () {}, // Date picker could go here
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview(List<VisitActivity> activities) {
    LatLng center = const LatLng(-6.1754, 106.8272); // Default Jakarta
    if (_polylinePoints.isNotEmpty) {
      center = _polylinePoints.first;
    }

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.wowin.crm',
            ),
            if (_polylinePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _polylinePoints,
                    strokeWidth: 4.0,
                    color: _green.withOpacity(0.7),
                  ),
                ],
              ),
            MarkerLayer(
              markers: activities.map((a) {
                if (a.latitude == 0 || a.longitude == 0) return null;
                return Marker(
                  point: LatLng(a.latitude, a.longitude),
                  width: 30,
                  height: 30,
                  child: Icon(
                    a.type == 'check-in' ? LucideIcons.mapPin : LucideIcons.circle,
                    color: a.type == 'check-in' ? Colors.red : Colors.blue,
                    size: 20,
                  ),
                );
              }).whereType<Marker>().toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRow(List<VisitActivity> activities) {
    int totalVisits = activities.where((a) => a.type == 'check-in').length;
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(LucideIcons.target, 'TOTAL VISITS', '$totalVisits Points'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(LucideIcons.calendarCheck, 'DATE', DateFormat('dd/MM').format(_selectedDate)),
        ),
      ],
    );
  }

  Widget _buildMetricCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: _green.withOpacity(0.8)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: _green.withOpacity(0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(List<VisitActivity> activities) {
    return Column(
      children: List.generate(activities.length, (index) {
        final item = activities[index];
        final isLast = index == activities.length - 1;
        return _buildTimelineNode(item, isLast);
      }),
    );
  }

  Widget _buildTimelineNode(VisitActivity item, bool isLast) {
    bool isCheckIn = item.type == 'check-in';
    String timeStr = DateFormat('hh:mm a').format(item.createdAt);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCheckIn ? _green : Colors.blue.shade600,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: (isCheckIn ? _green : Colors.blue).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Icon(isCheckIn ? LucideIcons.logIn : LucideIcons.logOut, color: Colors.white, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isCheckIn ? 'Check-In' : 'Check-Out',
                          style: const TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(color: _textSecondary.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    Text(
                      item.notes!,
                      style: TextStyle(color: _textSecondary.withOpacity(0.9), fontSize: 13),
                    ),
                  if (!isCheckIn && item.notes != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          item.notes!,
                          style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
