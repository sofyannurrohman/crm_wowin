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
import '../../domain/entities/kpi_dashboard.dart';
import '../../../deals/domain/entities/deal.dart';
import '../../../visits/domain/entities/visit_activity.dart';
import '../widgets/active_visit_card.dart';
import '../widgets/next_visit_card.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../../core/utils/animation_extensions.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentNavIndex = 0;

  // changed orange -> new green #0D8549
  static const Color _orange = Color(0xFF0D8549);
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
            // header now uses _orange (green)
            _buildHeader(context, l10n),
            // Scrollable body
            Expanded(
              child: BlocListener<TaskBloc, TaskState>(
                listener: (context, state) {
                  if (state is TaskOperationSuccess) {
                    context.read<DashboardBloc>().add(FetchDashboardKpis());
                  }
                },
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
            final hasActiveVisit = visitState is VisitSuccess && visitState.scheduleId != null;
            
            return Column(
              children: [
                if (hasActiveVisit)
                  ActiveVisitCard(
                    scheduleId: visitState.scheduleId!,
                    customerId: visitState.customerId ?? '',
                    customerName: visitState.customerName ?? 'Pelanggan',
                    startTime: visitState.checkInTime ?? DateTime.now(),
                  ).animateEntrance(delay: const Duration(milliseconds: 100))
                else if (d.nextStop != null)
                  NextVisitCard(nextStop: d.nextStop!).animateEntrance(delay: const Duration(milliseconds: 100)),
              ],
            );
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
              ).animateEntrance(delay: const Duration(milliseconds: 200)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                label: l10n.newLeads,
                icon: LucideIcons.userPlus,
                value: '${d.newLeads}',
                badge: '+5 growth',
                badgeColor: const Color(0xFF10B981),
              ).animateEntrance(delay: const Duration(milliseconds: 300)),
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
        ).animateEntrance(delay: const Duration(milliseconds: 400)),
        const SizedBox(height: 24),
        _buildHotDeals(d.hotDeals).animateEntrance(delay: const Duration(milliseconds: 500)),
        const SizedBox(height: 24),
        _buildRecentActivitySection(d.recentActivities).animateEntrance(delay: const Duration(milliseconds: 600)),
        const SizedBox(height: 24),

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
      return const EmptyStateWidget(
        title: 'Semua Terkendali!',
        message: 'Tidak ada rekomendasi kunjungan mendesak saat ini.',
        icon: LucideIcons.sparkles,
      );
    }

    return Column(
      children: recommendations.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _buildRecommendationItem(item, l10n).animateEntrance(
          delay: Duration(milliseconds: 700 + (index * 100)),
        );
      }).toList(),
    );
  }



  Widget _buildRecommendationItem(VisitRecommendation item, AppLocalizations l10n) {
    final bool isHigh = item.priority == 'high';
    // replace Colors.orange with the new green
    final Color priorityColor = isHigh ? Colors.red : (item.priority == 'medium' ? const Color(0xFF0D8549) : _navy);

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
        // replace Colors.orange with new green
        color = const Color(0xFF0D8549);
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

  Widget _buildHotDeals(List<Deal> deals) {
    if (deals.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hot Deals (Prioritas)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: deals.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _buildHotDealCard(deals[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildHotDealCard(Deal deal) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _navy.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                child: Text('${deal.probability}%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const Icon(LucideIcons.trendingUp, color: Colors.greenAccent, size: 16),
            ],
          ),
          const Spacer(),
          Text(deal.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: '${AppLocalizations.of(context)!.currencySymbol} ',
              decimalDigits: 0,
            ).format(deal.amount),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(List<VisitActivity> activities) {
    if (activities.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Terbaru',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: activities.take(5).map((a) => _buildRecentActivityItem(a)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityItem(VisitActivity activity) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
        child: Icon(activity.type == 'check_in' ? LucideIcons.mapPin : LucideIcons.checkSquare, size: 16, color: _navy),
      ),
      title: Text(activity.type == 'check_in' ? 'Check-in di Lapangan' : 'Check-out Selesai', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      subtitle: Text(activity.notes ?? '-', style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(DateFormat('HH:mm').format(activity.createdAt), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
    );
  }


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

  Widget _buildError(String message, AppLocalizations l10n) {
    return EmptyStateWidget(
      title: 'Gagal Memuat Dashboard',
      message: message,
      icon: LucideIcons.alertCircle,
      onRetry: () => context.read<DashboardBloc>().add(FetchDashboardKpis()),
      retryLabel: l10n.retry,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _formatCurrency(double value, String symbol) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '$symbol ',
      decimalDigits: 0,
    ).format(value);
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
