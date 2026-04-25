import 'package:flutter/material.dart';
import 'package:wowin_crm/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../visits/presentation/bloc/visit_bloc.dart';
import '../../../visits/presentation/bloc/visit_event.dart';
import '../../../visits/presentation/bloc/visit_state.dart';
import '../../domain/entities/visit_recommendation.dart';
import '../../domain/entities/kpi_dashboard.dart';
import '../../../deals/domain/entities/deal.dart';
import '../../../visits/domain/entities/visit_activity.dart';
import '../widgets/next_visit_card.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../deals/presentation/bloc/deal_bloc.dart';
import '../../../deals/presentation/bloc/deal_state.dart';
import 'package:intl/intl.dart';
import 'package:wowin_crm/features/tasks/domain/entities/task.dart';
import 'package:wowin_crm/features/tasks/domain/entities/task_destination.dart';
import '../../../../core/utils/animation_extensions.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentNavIndex = 0;

  static const Color _emerald = AppColors.primary;
  static const Color _emeraldDark = AppColors.primaryDark;
  static const Color _emeraldLight = AppColors.primaryLight;
  static const Color _slate900 = AppColors.textPrimary;
  static const Color _slate500 = AppColors.textSecondary;
  static const Color _bg = AppColors.background;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  void _fetchDashboardData() {
    final authState = context.read<AuthBloc>().state;
    String? salesId;
    if (authState is Authenticated && authState.user.role == 'sales') {
      salesId = authState.user.id;
    }
    context.read<DashboardBloc>().add(FetchDashboardKpis(salesId: salesId));
    context.read<CustomerBloc>().add(FetchCustomers(salesId: salesId));
    context.read<VisitBloc>().add(FetchActivities(salesId: salesId));
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
            _buildHeader(context, l10n),
            Expanded(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<TaskBloc, TaskState>(listener: (context, state) { if (state is TaskOperationSuccess) _fetchDashboardData(); }),
                  BlocListener<VisitBloc, VisitState>(listener: (context, state) { if (state is VisitSuccess) _fetchDashboardData(); }),
                  BlocListener<DealBloc, DealState>(listener: (context, state) { if (state is DealOperationSuccess) _fetchDashboardData(); }),
                  BlocListener<CustomerBloc, CustomerState>(listener: (context, state) { if (state is CustomerOperationSuccess) _fetchDashboardData(); }),
                ],
                child: RefreshIndicator(
                  color: _emerald,
                  onRefresh: () async => _fetchDashboardData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (context, state) {
                        if (state is DashboardLoading) {
                          return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: _emerald)));
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
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName = authState is Authenticated ? authState.user.name : 'Sales';
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.menu, color: _slate900, size: 22),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.welcomeBackGeneral.toUpperCase(), style: const TextStyle(color: _slate500, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    Text(userName, style: const TextStyle(color: _slate900, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.pushNamed(kRouteNotifications),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.bell, color: _slate900, size: 22),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(DashboardLoaded state, AppLocalizations l10n) {
    final d = state.dashboard;
    final List<_RouteStep> optimizedSteps = _getOptimizedSteps(state.routeTasks);
    
    _RouteStep? nextStop;
    try { nextStop = optimizedSteps.firstWhere((s) => !s.isWarehouse && s.status != TaskStatus.done); } catch (_) { nextStop = null; }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Target & Stats Row (Compact)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildTargetMinimal(d, l10n),
        ).animateEntrance(delay: const Duration(milliseconds: 50)),
        
        const SizedBox(height: 24),
        
        // 2. Main Action KPIs (Horizontal)
        _buildStatRow(d, l10n).animateEntrance(delay: const Duration(milliseconds: 100)),
        
        const SizedBox(height: 32),

        // 3. Highlight / Next Visit
        if (nextStop != null) 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: NextVisitCard(
              nextStop: VisitRecommendation(
                id: nextStop.id, name: nextStop.name, address: nextStop.address,
                latitude: nextStop.latitude ?? 0, longitude: nextStop.longitude ?? 0,
                reason: 'Prioritas Berikutnya', customerId: nextStop.customerId,
                leadId: nextStop.leadId, taskDestinationId: nextStop.id,
                type: nextStop.customerId != null ? 'customer' : 'lead',
                status: 'scheduled', priority: 'high', daysSinceLast: 0,
              ),
              parentTask: nextStop.parentTask,
            ),
          ).animateEntrance(delay: const Duration(milliseconds: 150)),

        const SizedBox(height: 32),

        // 4. Quick Access - Daftar Toko (Horizontal)
        _buildQuickStoreAccess(l10n).animateEntrance(delay: const Duration(milliseconds: 200)),

        const SizedBox(height: 32),
        
        // --- HYBRID WORKFLOW: Evening Task Banner ---
        _buildEveningTaskBanner().animateEntrance(delay: const Duration(milliseconds: 220)),
        
        const SizedBox(height: 32),

        // 5. Kunjungan Hari Ini (Planned & Pending)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kunjungan Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _slate900)),
                  TextButton(onPressed: () => context.pushNamed(kRouteTasks), child: const Text('Lihat Semua', style: TextStyle(color: _emerald, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 12),
              _buildPendingVisitsSection(),
              const SizedBox(height: 16),
              _buildRouteSequence(optimizedSteps, l10n),
            ],
          ),
        ).animateEntrance(delay: const Duration(milliseconds: 250)),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTargetMinimal(KpiDashboard d, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_emeraldDark, _emerald], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _emerald.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OMZET BULAN INI', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(_formatCurrency(d.monthlyRevenue, l10n.currencySymbol), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(100)),
                child: Text('${d.targetMetPercentage.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (d.targetMetPercentage / 100).clamp(0, 1),
              backgroundColor: Colors.white.withOpacity(0.1),
              color: Colors.white,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(LucideIcons.calendar, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text('${d.daysLeft} hari lagi mencapai target ${l10n.currencySymbol}${NumberFormat.compact().format(d.monthlyTarget)}', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(KpiDashboard d, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCircle('Booking', d.todayBooking, LucideIcons.shoppingBag, Colors.indigo, l10n),
          _buildStatCircle('Setoran', d.todayCollection, LucideIcons.wallet, Colors.amber.shade700, l10n),
          _buildStatCircle('Visits', d.visitsToday.toDouble(), LucideIcons.mapPin, _emerald, l10n, isCount: true, target: d.visitsTarget.toDouble()),
          _buildStatCircle('Leads', d.newLeads.toDouble(), LucideIcons.userPlus, Colors.pink, l10n, isCount: true),
        ],
      ),
    );
  }

  Widget _buildStatCircle(String label, double value, IconData icon, Color color, AppLocalizations l10n, {bool isCount = false, double? target}) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(label.toUpperCase(), style: const TextStyle(color: _slate500, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(
            isCount ? (target != null ? '${value.toInt()}/${target.toInt()}' : value.toInt().toString()) : _formatCurrency(value, l10n.currencySymbol),
            style: TextStyle(color: _slate900, fontSize: isCount ? 18 : 15, fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStoreAccess(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daftar Toko', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _slate900)),
              GestureDetector(
                onTap: () => context.pushNamed(kRouteAddCustomer),
                child: const Row(
                  children: [
                    Icon(LucideIcons.plusCircle, color: _emerald, size: 18),
                    SizedBox(width: 4),
                    Text('Tambah', style: TextStyle(color: _emerald, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCustomerListSection(),
      ],
    );
  }


  Widget _buildHeroCard({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(value, l10n.currencySymbol),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _emeraldLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: _emerald),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _emeraldDark.withOpacity(0.6),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: _emeraldDark,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _emerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _emerald,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _emerald.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                'Monthly Target Revenue (Invoice)'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                revenueStr,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _emeraldDark,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ $targetStr',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_emerald, _emerald],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 12, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                '$daysLeft ${l10n.daysLeft}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
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
  // ---------------------------------------------------------------------------
  // Route sequence timeline
  // ---------------------------------------------------------------------------
  List<_RouteStep> _getOptimizedSteps(List<Task> tasks) {
    if (tasks.isEmpty) return [];

    final List<_RouteStep> steps = [];
    
    // For simplicity, we optimize each task's destinations using the same greedy logic
    // but starting from each task's warehouse
    for (final task in tasks) {
      if (task.status == TaskStatus.done) continue;
      
      if (task.warehouse != null) {
        steps.add(_RouteStep(
          id: 'wh-${task.warehouseId}',
          name: task.warehouse!.name,
          address: task.warehouse!.address ?? 'Gudang Utama',
          isWarehouse: true,
          status: task.status,
          parentTask: task,
          latitude: task.warehouse?.latitude,
          longitude: task.warehouse?.longitude,
        ));
      }

      final List<TaskDestination> unvisited = task.destinations.where((d) => d.status != TaskStatus.done).toList();
      final List<TaskDestination> done = task.destinations.where((d) => d.status == TaskStatus.done).toList();
      
      // 1. Add Done tasks first (historical)
      for (final dest in done) {
        steps.add(_RouteStep(
          id: dest.id,
          name: dest.targetName ?? 'Selesai',
          address: dest.targetAddress ?? '-',
          isWarehouse: false,
          status: dest.status,
          customerId: dest.customerId,
          leadId: dest.leadId,
          scheduleId: task.id,
          parentTask: task,
          latitude: dest.targetLatitude,
          longitude: dest.targetLongitude,
        ));
      }

      // 2. Greedy Optimization for the rest
      LatLng currentLoc = LatLng(
        task.warehouse?.latitude ?? -6.1754, 
        task.warehouse?.longitude ?? 106.8272
      );
      
      // Update currentLoc to last done task if exists
      if (done.isNotEmpty) {
        final lastDone = done.last;
        if (lastDone.targetLatitude != null && lastDone.targetLongitude != null) {
          currentLoc = LatLng(lastDone.targetLatitude!, lastDone.targetLongitude!);
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
          steps.add(_RouteStep(
            id: nearestDest.id,
            name: nearestDest.targetName ?? 'Tujuan',
            address: nearestDest.targetAddress ?? '-',
            isWarehouse: false,
            status: nearestDest.status,
            customerId: nearestDest.customerId,
            leadId: nearestDest.leadId,
            scheduleId: task.id,
            parentTask: task,
            latitude: nearestDest.targetLatitude,
            longitude: nearestDest.targetLongitude,
          ));
          currentLoc = LatLng(nearestDest.targetLatitude!, nearestDest.targetLongitude!);
        } else {
          // Add remaining if no location
          for (final d in unvisited) {
             steps.add(_RouteStep(
              id: d.id,
              name: d.targetName ?? 'Tujuan',
              address: d.targetAddress ?? '-',
              isWarehouse: false,
              status: d.status,
              customerId: d.customerId,
              leadId: d.leadId,
              scheduleId: task.id,
              parentTask: task,
            ));
          }
          unvisited.clear();
        }
      }
    }
    return steps;
  }

  Widget _buildRouteSequence(List<_RouteStep> steps, AppLocalizations l10n) {
    if (steps.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == steps.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline line & circle
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: step.status == TaskStatus.done ? _emerald : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (step.status != TaskStatus.done)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                        border: Border.all(
                          color: step.status == TaskStatus.done ? _emerald : Colors.grey.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: step.status == TaskStatus.done
                            ? const Icon(LucideIcons.check, size: 18, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: _emeraldDark,
                                ),
                              ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Card contents
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                    child: GestureDetector(
                      onTap: step.isWarehouse || step.status == TaskStatus.done
                          ? null
                          : () => context.pushNamed(
                                kRouteRoutePlanner,
                                extra: step.parentTask,
                              ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
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
                                  Text(
                                    step.isWarehouse ? 'TITIK MULAI' : 'TUJUAN ${index + 1}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: step.isWarehouse ? Colors.blue : _emerald,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  if (step.status == TaskStatus.done)
                                    Icon(LucideIcons.checkCircle2, color: _emerald, size: 16),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(LucideIcons.mapPin, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    step.address,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskItem(Task task, AppLocalizations l10n) {
    final Color priorityColor = _emerald;

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
                           Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _emerald.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.calendar, size: 12, color: priorityColor),
                                const SizedBox(width: 4),
                                const Text(
                                  'TUGAS HARI INI',
                                  style: TextStyle(
                                    color: _emerald,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(LucideIcons.clipboardList, size: 14, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${task.destinations.length} Lokasi Kunjungan',
                        style: TextStyle(
                          fontSize: 13,
                          color: priorityColor.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (task.warehouse?.address != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(LucideIcons.warehouse, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                task.warehouse!.address!,
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
                                context.pushNamed(kRouteTasks, extra: {'id': task.id});
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
                                  kRouteRoutePlanner,
                                  extra: task,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _emerald,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Mulai Rute', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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

  Widget _buildRecommendationItem(VisitRecommendation item, AppLocalizations l10n) {
    final bool isHigh = item.priority == 'high';
    final Color priorityColor = isHigh ? Colors.red : (item.priority == 'medium' ? _emerald : _emeraldDark);

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
                          Row(
                            children: [
                              if (item.type == 'lead')
                                const Icon(LucideIcons.userPlus, size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                            ],
                          ),
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
                                final authState = context.read<AuthBloc>().state;
                                final userId = (authState is Authenticated) ? authState.user.id : null;
                                final userName = (authState is Authenticated) ? authState.user.name : null;
                                
                                context.pushNamed(
                                  kRouteCheckIn,
                                  extra: {
                                    'customerId': item.id,
                                    'customerName': item.name,
                                    'customerAddress': item.address,
                                    'targetLat': item.latitude,
                                    'targetLng': item.longitude,
                                    'targetRadiusMeters': 200.0,
                                    'salesId': userId,
                                    'salesmanName': userName,
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
        color = _emeraldDark;
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hot Deals (Prioritas)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
            ),
            GestureDetector(
              onTap: () => context.pushNamed(kRouteDeals),
              child: Text(
                'Lihat Semua',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _emerald),
              ),
            ),
          ],
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
    return GestureDetector(
      onTap: () => context.pushNamed(kRouteDealDetail, pathParameters: {'id': deal.id}),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_emeraldDark, _emerald],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _emeraldDark.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
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
              _formatCurrency(deal.amount ?? 0, AppLocalizations.of(context)!.currencySymbol),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
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
        decoration: BoxDecoration(color: _emeraldLight, shape: BoxShape.circle),
        child: Icon(activity.type == 'check_in' ? LucideIcons.mapPin : LucideIcons.checkSquare, size: 16, color: _emerald),
      ),
      title: Text(activity.type == 'check_in' ? 'Check-in di Lapangan' : 'Check-out Selesai', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      subtitle: Text(activity.notes ?? '-', style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(DateFormat('HH:mm').format(activity.createdAt), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
    );
  }


  Widget _buildCheckInFab(AppLocalizations l10n) {
    return const SizedBox(); // Removed FAB to focus on list-based workflow
  }

  Widget _buildCustomerListSection() {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) {
          return const Center(child: CircularProgressIndicator(color: _emerald));
        } else if (state is CustomersLoaded) {
          if (state.customers.isEmpty) {
            return const SizedBox();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Toko Anda',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                  ),
                  GestureDetector(
                    onTap: () => context.pushNamed(kRouteCustomers),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _emerald),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih toko di bawah ini untuk langsung melakukan kunjungan.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.customers.length > 5 ? 5 : state.customers.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final c = state.customers[index];
                    return GestureDetector(
                      onTap: () {
                        context.pushNamed(
                          kRouteCheckIn,
                          extra: {
                            'customerId': c.id,
                            'customerName': c.name,
                            'customerAddress': c.address,
                            'targetLat': c.latitude,
                            'targetLng': c.longitude,
                            'targetRadiusMeters': 200.0,
                            'salesId': c.salesId,
                            'salesmanName': c.salesmanName,
                          },
                        );
                      },
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: _emeraldLight, shape: BoxShape.circle),
                              child: Icon(LucideIcons.store, color: _emerald),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              c.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(LucideIcons.arrowRight, size: 14, color: _emerald),
                                const SizedBox(width: 4),
                                Text('Mulai Visit', style: TextStyle(color: _emerald, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
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

  Widget _buildPendingVisitsSection() {
    return BlocBuilder<VisitBloc, VisitState>(
      builder: (context, state) {
        if (state is VisitLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Center(child: CircularProgressIndicator(color: _emerald, strokeWidth: 2)),
          );
        }
        if (state is VisitError) {
          return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red, fontSize: 10)));
        }
        if (state is ActivitiesLoaded) {

          final pendingVisits = state.activities.where((a) {
            // Show all DRAFT_PHOTO status visits that need finalization
            final status = a.status?.toUpperCase() ?? '';
            return status == 'DRAFT_PHOTO';
          }).toList();

          if (pendingVisits.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Icon(LucideIcons.checkCircle, color: Colors.grey.withOpacity(0.3), size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Tidak ada kunjungan yang perlu diinput',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: pendingVisits.length,
                  itemBuilder: (context, index) {
                    final visit = pendingVisits[index];
                    return GestureDetector(
                      onTap: () => context.pushNamed(
                        kRouteFinalizeVisit,
                        extra: visit,
                      ),
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(LucideIcons.clipboardSignature, color: Colors.orange, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    visit.customerName ?? visit.leadName ?? 'Unknown',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pukul ${DateFormat('HH:mm').format(visit.createdAt)}',
                                    style: const TextStyle(fontSize: 12, color: _slate500),
                                  ),
                                  const SizedBox(height: 4),
                                  const Row(
                                    children: [
                                      Text(
                                        'Input Nota',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(LucideIcons.arrowRight, size: 10, color: Colors.orange),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEveningTaskBanner() {
    return BlocBuilder<VisitBloc, VisitState>(
      builder: (context, state) {
        if (state is ActivitiesLoaded) {
          final draftCount = state.activities.where((a) => a.status == 'DRAFT_PHOTO').length;
          if (draftCount == 0) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.packageCheck, color: Colors.orange, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$draftCount KUNJUNGAN BELUM INPUT',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Selesaikan input detail di gudang.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.pushNamed(kRouteEveningTasks),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('INPUT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _RouteStep {
  final String id;
  final String name;
  final String address;
  final bool isWarehouse;
  final TaskStatus status;
  final String? customerId;
  final String? leadId;
  final String? scheduleId;
  final Task? parentTask;
  final double? latitude;
  final double? longitude;

  _RouteStep({
    required this.id,
    required this.name,
    required this.address,
    required this.isWarehouse,
    required this.status,
    this.customerId,
    this.leadId,
    this.scheduleId,
    this.parentTask,
    this.latitude,
    this.longitude,
  });
}
