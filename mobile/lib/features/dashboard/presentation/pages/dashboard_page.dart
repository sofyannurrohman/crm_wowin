import 'package:flutter/material.dart';
import 'package:wowin_crm/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../visits/presentation/bloc/visit_bloc.dart';
import '../../../visits/presentation/bloc/visit_state.dart';
import '../../domain/entities/visit_recommendation.dart';
import '../widgets/active_visit_card.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            // Orange header
            _buildHeader(context, l10n),
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
                        return _buildBody(state, l10n);
                      } else if (state is DashboardError) {
                        return _buildError(state.message, l10n);
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
      floatingActionButton: _buildCheckInFab(l10n),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ---------------------------------------------------------------------------
  // Orange header with avatar, name, notification bell
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName = authState is Authenticated
            ? authState.user.name
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
                    Text(
                      l10n.welcomeBackGeneral,
                      style: const TextStyle(
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
  Widget _buildBody(DashboardLoaded state, AppLocalizations l10n) {
    final d = state.dashboard;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active Visit Card Integration
        BlocBuilder<VisitBloc, VisitState>(
          builder: (context, visitState) {
            if (visitState is VisitSuccess && visitState.scheduleId != null) {
              return ActiveVisitCard(
                scheduleId: visitState.scheduleId!,
                customerName: visitState.customerName ?? 'Pelanggan',
                startTime: visitState.checkInTime ?? DateTime.now(),
              );
            }
            return const SizedBox();
          },
        ),

        // KPI row: visits + leads
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                label: l10n.todaysVisits,
                icon: LucideIcons.calendarCheck,
                value: '${d.visitsToday}',
                badge: '+2 today',
                badgeColor: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                label: l10n.newLeads,
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
        _buildMonthlyTargetCard(
          d.monthlyRevenue,
          d.monthlyTarget,
          d.targetMetPercentage,
          d.daysLeft,
          l10n,
        ),

        const SizedBox(height: 20),

        // Today's Schedule section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prioritas Kunjungan Hari Ini',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                l10n.viewCalendar,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Recommendations list
        _buildRecommendationList(state.recommendations, l10n),

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
  Widget _buildMonthlyTargetCard(double revenue, double target,
      double percentage, int daysLeft, AppLocalizations l10n) {
    final pct = (percentage / 100).clamp(0.0, 1.0);
    final revenueStr = _formatCurrency(revenue, l10n.currencySymbol);
    final targetStr = _formatCurrency(target, l10n.currencySymbol);

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
              Text(
                l10n.monthlyTargetProgress,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              RichText(
                text: TextSpan(
                  style:
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
                '${percentage.toStringAsFixed(0)}% ${l10n.revenueGoalAchieved}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E8E93),
                ),
              ),
              Text(
                '$daysLeft ${l10n.daysLeft}',
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
  // Priority recommendations list
  // ---------------------------------------------------------------------------
  Widget _buildRecommendationList(
      List<VisitRecommendation> recommendations, AppLocalizations l10n) {
    if (recommendations.isEmpty) {
      return _buildEmptyRecommendations(l10n);
    }

    return Column(
      children: recommendations.map((item) {
        return _buildRecommendationItem(item, l10n);
      }).toList(),
    );
  }

  Widget _buildEmptyRecommendations(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.sparkles, size: 48, color: _orange.withOpacity(0.2)),
          const SizedBox(height: 12),
          const Text(
            'Semua Terkendali!',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tidak ada rekomendasi kunjungan mendesak saat ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(VisitRecommendation item, AppLocalizations l10n) {
    final bool isHigh = item.priority == 'high';
    final Color priorityColor = isHigh ? Colors.red : (item.priority == 'medium' ? Colors.orange : _navy);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                color: priorityColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPriorityBadge(item),
                          if (item.type == 'lead')
                            const Icon(LucideIcons.userPlus, size: 14, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.reason,
                        style: TextStyle(
                          fontSize: 13,
                          color: priorityColor.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.address.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Navigate to customer/lead detail
                                if (item.type == 'customer') {
                                  context.pushNamed(kRouteCustomers, extra: {'id': item.id});
                                } else {
                                  context.pushNamed(kRouteLeads, extra: {'id': item.id});
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE5E7EB)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Detail', style: TextStyle(color: Color(0xFF1A1A1A))),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                context.pushNamed(
                                  kRouteCheckIn,
                                  extra: {
                                    'customerId': item.id,
                                    'customerName': item.name,
                                    'customerAddress': item.address,
                                    'targetLat': item.latitude,
                                    'targetLng': item.longitude,
                                    'targetRadiusMeters': 200.0,
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: priorityColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Mulai Kunjungan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(VisitRecommendation item) {
    String label = '';
    Color color = Colors.grey;
    IconData icon = LucideIcons.info;

    switch (item.status) {
      case 'new':
        label = item.type == 'lead' ? 'Leads Baru' : 'Pelanggan Baru';
        color = Colors.red;
        icon = LucideIcons.flame;
        break;
      case 'stale':
        label = 'Butuh Perhatian';
        color = Colors.orange;
        icon = LucideIcons.alertTriangle;
        break;
      case 'scheduled':
        label = 'Terjadwal';
        color = _navy;
        icon = LucideIcons.calendar;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Check-in FAB
  // ---------------------------------------------------------------------------
  Widget _buildCheckInFab(AppLocalizations l10n) {
    return FloatingActionButton.extended(
      onPressed: () {
        context.pushNamed(kRouteCheckIn);
      },
      backgroundColor: _navy,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      icon: const Icon(LucideIcons.userCheck, color: Colors.white, size: 20),
      label: Text(
        l10n.checkInNow,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // Error state
  // ---------------------------------------------------------------------------
  Widget _buildError(String message, AppLocalizations l10n) {
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
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _formatCurrency(double value, String symbol) {
    if (value >= 1000) {
      return '$symbol${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${value.toStringAsFixed(0)}';
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
