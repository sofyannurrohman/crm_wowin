import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_state.dart';

class RouteHistoryPage extends StatefulWidget {
  const RouteHistoryPage({super.key});

  @override
  State<RouteHistoryPage> createState() => _RouteHistoryPageState();
}

class _RouteHistoryPageState extends State<RouteHistoryPage> {
  static const Color _orange = Color(0xFFEA580C);
  static const Color _lightOrange = Color(0xFFFFF7ED);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  DateTime _selectedDate = DateTime(2023, 10, 5); // October 5, 2023 as default
  
  // Mock Data mimicking backend payload
  final List<Map<String, dynamic>> _mockTimeline = [
    {
      'name': 'Supermercado El Sol',
      'address': 'Calle Central, Av. 4, San José',
      'status': 'DELIVERED',
      'stay': '15 MIN STAY',
      'time': '09:15 AM',
      'type': 'store',
      'icon': LucideIcons.store,
    },
    {
      'name': 'Soda Tapia Sabana',
      'address': 'Frente al Estadio Nacional, San José',
      'status': 'DELIVERED',
      'stay': '12 MIN STAY',
      'time': '10:45 AM',
      'type': 'restaurant',
      'icon': Icons.restaurant,
    },
    {
      'name': 'Pulpería La Amistad',
      'address': '100m Este de la Iglesia, Guadalupe',
      'status': 'SKIPPED',
      'stay': null,
      'time': '11:30 AM',
      'type': 'skipped',
      'icon': LucideIcons.xCircle,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchRouteHistory();
  }

  void _fetchRouteHistory() {
    // Expected backend linkage: 
    // context.read<VisitBloc>().add(FetchRouteHistory(date: _selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: BlocBuilder<VisitBloc, VisitState>(
        builder: (context, state) {
          // Wrap in state loading logic once implemented back end side
          // if (state is VisitLoading) return const Center(child: CircularProgressIndicator(color: _orange));

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendarCard(),
                const SizedBox(height: 20),
                _buildMapPreview(),
                const SizedBox(height: 16),
                _buildMetricsRow(),
                const SizedBox(height: 24),
                const Text(
                  'VISITS TIMELINE',
                  style: TextStyle(
                    color: _orange,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTimelineList(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: _orange),
        onPressed: () => context.pop(),
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

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(LucideIcons.chevronLeft, color: _orange, size: 20),
              Text(
                'October 2023',
                style: TextStyle(
                  color: _orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Icon(LucideIcons.chevronRight, color: _orange, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          // Mocking the week layout for UI perfection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
               SizedBox(
                 width: 32,
                 child: Text(
                   day, 
                   textAlign: TextAlign.center,
                   style: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold, fontSize: 13),
                 ),
               )
            ).toList(),
          ),
          const SizedBox(height: 12),
          // Week 1 mocking visually
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDayCircle('', false),
              _buildDayCircle('', false),
              _buildDayCircle('', false),
              _buildDayCircle('1', false),
              _buildDayCircle('2', false),
              _buildDayCircle('3', false),
              _buildDayCircle('4', false),
            ],
          ),
          const SizedBox(height: 8),
          // Week 2 highlighting the 5th
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDayCircle('5', true), // October 5, Selected
              _buildDayCircle('6', false),
              _buildDayCircle('7', false),
              _buildDayCircle('8', false),
              _buildDayCircle('9', false),
              _buildDayCircle('10', false),
              _buildDayCircle('11', false),
            ],
          ),
          const SizedBox(height: 8),
          // Week 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDayCircle('12', false),
              _buildDayCircle('13', false),
              _buildDayCircle('14', false),
              _buildDayCircle('', false),
              _buildDayCircle('', false),
              _buildDayCircle('', false),
              _buildDayCircle('', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCircle(String day, bool isSelected) {
    if (day.isEmpty) return const SizedBox(width: 36);
    return GestureDetector(
      onTap: () {
        // Update date state logic here.
      },
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _orange : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected ? [
            BoxShadow(color: _orange.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Text(
          day,
          style: TextStyle(
            color: isSelected ? Colors.white : _textPrimary,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    const double lat = 9.9281; // San Jose
    const double lng = -84.0907;

    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: const GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 12),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              liteModeEnabled: true, // Optimizes performance for static-like maps
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            child: const Text(
              'Route Preview',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(LucideIcons.map, 'DISTANCE', '42.5 km'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(LucideIcons.clock, 'TIME ON ROAD', '3h 15m'),
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
              Icon(icon, size: 14, color: _orange.withOpacity(0.8)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: _orange.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList() {
    return Column(
      children: List.generate(_mockTimeline.length, (index) {
        final item = _mockTimeline[index];
        final isLast = index == _mockTimeline.length - 1;
        return _buildTimelineNode(item, isLast);
      }),
    );
  }

  Widget _buildTimelineNode(Map<String, dynamic> item, bool isLast) {
    bool isSkipped = item['type'] == 'skipped';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left track column
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSkipped ? const Color(0xFFD1D5DB) : _orange,
                  shape: BoxShape.circle,
                ),
                child: Icon(item['icon'], color: Colors.white, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: isSkipped ? const Color(0xFFE5E7EB) : const Color(0xFFFED7AA),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content column
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
                          item['name'],
                          style: TextStyle(
                            color: isSkipped ? _textSecondary : _textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        item['time'],
                        style: TextStyle(
                          color: _textSecondary.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['address'],
                    style: TextStyle(
                      color: _textSecondary.withOpacity(0.9),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSkipped ? const Color(0xFFF3F4F6) : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['status'],
                          style: TextStyle(
                            color: isSkipped ? const Color(0xFF4B5563) : const Color(0xFF16A34A),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Stay Duration Badge (if any)
                      if (item['stay'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['stay'],
                            style: const TextStyle(
                              color: _orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(LucideIcons.home, 'HOME', false),
          _buildNavItem(LucideIcons.history, 'HISTORY', true), // History active
          _buildNavItem(LucideIcons.barChart2, 'REPORTS', false),
          _buildNavItem(LucideIcons.settings, 'SETTINGS', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? _orange : const Color(0xFF9CA3AF), size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? _orange : const Color(0xFF9CA3AF),
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 1.0, 
          ),
        ),
      ],
    );
  }
}
