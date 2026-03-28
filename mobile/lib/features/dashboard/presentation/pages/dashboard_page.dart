import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/route_constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentNavIndex = 0;

  static const Color _orange = Color(0xFFE8622A);
  static const Color _navy = Color(0xFF1A237E);
  static const Color _bg = Color(0xFFF2F4F8);

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchDashboardKpis());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            // Orange header
            _buildHeader(context),
            // Scrollable body
            Expanded(
              child: RefreshIndicator(
                color: _orange,
                onRefresh: () async {
                  context.read<DashboardBloc>().add(FetchDashboardKpis());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: BlocBuilder<DashboardBloc, DashboardState>(
                    builder: (context, state) {
                      if (state is DashboardLoading) {
                        return const SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(color: _orange),
                          ),
                        );
                      } else if (state is DashboardLoaded) {
                        return _buildBody(state);
                      } else if (state is DashboardError) {
                        return _buildError(state.message);
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Check-in Button
      floatingActionButton: _buildCheckInFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom nav
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------------------------------------------------------------------------
  // Orange header with avatar, name, notification bell
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName = authState is Authenticated
            ? '${authState.user.firstName} ${authState.user.lastName}'.trim()
            : 'Sales';
        return Container(
          color: _orange,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Hamburger Menu
              IconButton(
                icon: const Icon(LucideIcons.menu, color: Colors.white, size: 28),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              const SizedBox(width: 8),
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white24,
                ),
                child: const ClipOval(
                  child: Icon(
                    LucideIcons.user,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      userName.isEmpty ? 'Sales' : userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification bell
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.bell,
                        color: Colors.white, size: 22),
                    onPressed: () =>
                        context.pushNamed(kRouteNotifications),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A237E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Main body: KPI cards + target + schedule
  // ---------------------------------------------------------------------------
  Widget _buildBody(DashboardLoaded state) {
    final d = state.dashboard;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI row: visits + leads
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                label: "TODAY'S VISITS",
                icon: LucideIcons.calendarCheck,
                value: '${d.visitsToday}',
                badge: '+2 today',
                badgeColor: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                label: 'NEW LEADS',
                icon: LucideIcons.userPlus,
                value: '${d.newLeads}',
                badge: '+5 growth',
                badgeColor: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Monthly target progress
        _buildMonthlyTargetCard(d.monthlyRevenue, d.monthlyTarget,
            d.targetMetPercentage, d.daysLeft),

        const SizedBox(height: 20),

        // Today's Schedule section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'View Calendar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Schedule list
        _buildScheduleList(state.schedules),

        const SizedBox(height: 100), // padding for FAB
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // KPI mini card
  // ---------------------------------------------------------------------------
  Widget _buildKpiCard({
    required String label,
    required IconData icon,
    required String value,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _navy),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8E8E93),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Monthly target progress card
  // ---------------------------------------------------------------------------
  Widget _buildMonthlyTargetCard(
      double revenue, double target, double percentage, int daysLeft) {
    final pct = (percentage / 100).clamp(0.0, 1.0);
    final revenueStr = _formatCurrency(revenue);
    final targetStr = _formatCurrency(target);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Target Progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(
                      text: revenueStr,
                      style: const TextStyle(color: _navy),
                    ),
                    const TextSpan(
                      text: ' / ',
                      style: TextStyle(color: Color(0xFF8E8E93)),
                    ),
                    TextSpan(
                      text: targetStr,
                      style: const TextStyle(color: _navy),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(_navy),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}% of revenue goal achieved',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E8E93),
                ),
              ),
              Text(
                '$daysLeft days left',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Today's schedule list
  // ---------------------------------------------------------------------------
  Widget _buildScheduleList(List<Map<String, dynamic>> schedules) {
    if (schedules.isEmpty) {
      return _buildEmptySchedule();
    }

    // Show up to 3 items for today
    final todaySchedules = schedules.take(3).toList();

    return Column(
      children: todaySchedules.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final isNextUp = idx == 1; // second item is "NEXT UP"
        return _buildScheduleItem(item, isNextUp: isNextUp);
      }).toList(),
    );
  }

  Widget _buildEmptySchedule() {
    // Fallback with sample data when backend is empty
    final samples = [
      {
        'time': '09:30',
        'customer_name': 'TechNova Solutions',
        'location': 'Financial District, North Wing',
        'type': 'QUARTERLY REVIEW',
        'type_color': const Color(0xFFDBEAFE),
        'type_text_color': const Color(0xFF1D4ED8),
      },
      {
        'time': '11:00',
        'customer_name': 'GreenLeaf Organics',
        'location': 'Eastside Industrial Park',
        'type': 'CONTRACT RENEWAL',
        'type_color': const Color(0xFFFEF3C7),
        'type_text_color': const Color(0xFFD97706),
        'next_up': true,
      },
      {
        'time': '14:15',
        'customer_name': 'Summit Retail Group',
        'location': 'Downtown Plaza, Suite 402',
        'type': 'PRODUCT DEMO',
        'type_color': const Color(0xFFD1FAE5),
        'type_text_color': const Color(0xFF065F46),
      },
    ];

    return Column(
      children: samples.asMap().entries.map((e) {
        return _buildScheduleItemFromMap(e.value, isNextUp: e.value['next_up'] == true);
      }).toList(),
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> item,
      {bool isNextUp = false}) {
    final time = _extractTime(item['scheduled_at'] as String? ?? '');
    final customerName = item['customer_name'] as String? ??
        item['title'] as String? ??
        'Visit';
    final location = item['location'] as String? ?? '';
    final type = (item['type'] as String? ?? 'VISIT').toUpperCase();

    return _buildScheduleItemFromMap({
      'time': time,
      'customer_name': customerName,
      'location': location,
      'type': type,
      'type_color': const Color(0xFFDBEAFE),
      'type_text_color': const Color(0xFF1D4ED8),
    }, isNextUp: isNextUp);
  }

  Widget _buildScheduleItemFromMap(Map<String, dynamic> item,
      {bool isNextUp = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 48,
            child: Text(
              item['time'] as String? ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Left accent bar
          Container(
            width: 3,
            height: 90,
            decoration: BoxDecoration(
              color: isNextUp ? _orange : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          // Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isNextUp ? const Color(0xFFFFF8F5) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isNextUp
                      ? _orange.withOpacity(0.3)
                      : const Color(0xFFE5E7EB),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['customer_name'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      if (isNextUp)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _navy,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'NEXT UP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if ((item['location'] as String? ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin,
                            size: 12, color: Color(0xFF8E8E93)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['location'] as String? ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item['type_color'] as Color? ??
                          const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item['type'] as String? ?? '',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: item['type_text_color'] as Color? ??
                            const Color(0xFF1D4ED8),
                        letterSpacing: 0.4,
                      ),
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

  // ---------------------------------------------------------------------------
  // Check-in FAB
  // ---------------------------------------------------------------------------
  Widget _buildCheckInFab() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: FloatingActionButton.extended(
            onPressed: () {
              if (state is DashboardLoaded && state.schedules.isNotEmpty) {
                final nextVisit = state.schedules.first;
                context.pushNamed(
                  kRouteCheckIn,
                  extra: {
                    'scheduleId': nextVisit['id'] ?? '',
                    'customerName': nextVisit['customer_name'] ?? 'Visit',
                    'customerAddress': nextVisit['location'] ?? '',
                    'targetLat': (nextVisit['latitude'] as num?)?.toDouble() ?? 0.0,
                    'targetLng': (nextVisit['longitude'] as num?)?.toDouble() ?? 0.0,
                    'targetRadiusMeters': 100.0, // Multi-phase default
                  },
                );
              }
            },
            backgroundColor: _navy,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            icon: const Icon(LucideIcons.userCheck, color: Colors.white, size: 20),
            label: const Text(
              'Check-in Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Drawer
  // ---------------------------------------------------------------------------
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 24, right: 24),
            decoration: const BoxDecoration(
              color: _orange,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.command, color: Colors.white, size: 40),
                const SizedBox(height: 16),
                const Text(
                  'Wowin CR Mobile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Central Routing Menu',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(context, LucideIcons.layoutDashboard, 'Dashboard', () {
            context.pop();
          }),
          _buildDrawerItem(context, Icons.fingerprint, 'Attendance', () {
            context.pop();
            context.pushNamed(kRouteAttendanceHome);
          }),
          _buildDrawerItem(context, LucideIcons.checkSquare, 'Tasks', () {
            context.pop();
            context.pushNamed(kRouteTasks);
          }),
          _buildDrawerItem(context, LucideIcons.users, 'Leads & Customers', () {
            context.pop();
            context.pushNamed(kRouteCustomers); // Or kRouteLeads
          }),
          _buildDrawerItem(context, LucideIcons.briefcase, 'Deals Pipeline', () {
            context.pop();
            context.pushNamed(kRouteDeals);
          }),
          // Navigation Divider
          const Divider(height: 32, color: Color(0xFFF3F4F6)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'HISTORY & LOGS',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _buildDrawerItem(context, LucideIcons.map, 'Route History', () {
            context.pop();
            context.pushNamed(kRouteRouteHistory);
          }),
          _buildDrawerItem(context, LucideIcons.list, 'Activity Log', () {
            context.pop();
            context.pushNamed(kRouteActivityLog);
          }),
          // Preferences Divider
          const Divider(height: 32, color: Color(0xFFF3F4F6)),
          _buildDrawerItem(context, LucideIcons.user, 'Profile', () {
            context.pop();
            context.pushNamed(kRouteProfile);
          }),
          _buildDrawerItem(context, LucideIcons.settings, 'Settings', () {
            context.pop();
            context.pushNamed(kRouteSettings);
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4B5563), size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Nav Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomNav() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, LucideIcons.home, 'Home'),
            _buildNavItem(1, LucideIcons.users, 'Customers', route: kRouteCustomers),
            const SizedBox(width: 56), // FAB gap
            _buildNavItem(2, LucideIcons.checkSquare, 'Tasks', route: kRouteTasks),
            _buildNavItem(3, LucideIcons.user, 'Profile', route: kRouteProfile),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label,
      {String? route}) {
    final isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentNavIndex = index);
        if (route != null) {
          context.pushNamed(route);
        } else if (index == 0) {
          // Stay on home/dashboard
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 22,
              color: isActive ? _orange : const Color(0xFF8E8E93)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isActive ? _orange : const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error state
  // ---------------------------------------------------------------------------
  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const Icon(LucideIcons.alertCircle,
              size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<DashboardBloc>().add(FetchDashboardKpis()),
            style: ElevatedButton.styleFrom(backgroundColor: _orange),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  String _extractTime(String dateStr) {
    if (dateStr.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '--:--';
    }
  }
}
