import 'package:flutter/material.dart';
import 'package:wowin_crm/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:latlong2/latlong.dart';

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

  static const Color _green = Color(0xFF0D8549);
  static const Color _navy = Color(0xFF1E3A8A);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _orange = Color(0xFFF97316);

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
              child: MultiBlocListener(
                listeners: [
                  BlocListener<TaskBloc, TaskState>(
                    listener: (context, state) {
                      if (state is TaskOperationSuccess) {
                        _fetchDashboardData();
                      }
                    },
                  ),
                  BlocListener<VisitBloc, VisitState>(
                    listener: (context, state) {
                      if (state is VisitSuccess) {
                        _fetchDashboardData();
                      }
                    },
                  ),
                  BlocListener<DealBloc, DealState>(
                    listener: (context, state) {
                      if (state is DealOperationSuccess) {
                        _fetchDashboardData();
                      }
                    },
                  ),
                ],
                child: RefreshIndicator(
                  color: _orange,
                  onRefresh: () async {
                    _fetchDashboardData();
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
    final List<_RouteStep> optimizedSteps = _getOptimizedSteps(state.routeTasks);
    
    // Find first unvisited destination in optimized sequence
    _RouteStep? nextOptimizedStop;
    try {
      nextOptimizedStop = optimizedSteps.firstWhere(
        (s) => !s.isWarehouse && s.status != TaskStatus.done
      );
    } catch (_) {
      nextOptimizedStop = null;
    }

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
                    customerId: visitState.customerId,
                    leadId: visitState.leadId,
                    taskDestinationId: visitState.taskDestinationId,
                    customerName: visitState.customerName ?? 'Pelanggan',
                    startTime: visitState.checkInTime ?? DateTime.now(),
                  ).animateEntrance(delay: const Duration(milliseconds: 100))
                else if (nextOptimizedStop != null)
                  NextVisitCard(
                    nextStop: VisitRecommendation(
                      id: nextOptimizedStop!.id,
                      name: nextOptimizedStop!.name,
                      address: nextOptimizedStop!.address,
                      latitude: nextOptimizedStop!.latitude ?? 0,
                      longitude: nextOptimizedStop!.longitude ?? 0,
                      reason: 'Optimized via Route Planner',
                      customerId: nextOptimizedStop!.customerId,
                      leadId: nextOptimizedStop!.leadId,
                      taskDestinationId: nextOptimizedStop!.id,
                      type: nextOptimizedStop!.customerId != null ? 'customer' : 'lead',
                      status: 'scheduled',
                      priority: 'medium',
                      daysSinceLast: 0,
                    ),
                    parentTask: nextOptimizedStop!.parentTask,
                  ).animateEntrance(delay: const Duration(milliseconds: 100))
                else if (d.nextStop != null)
                  Builder(
                    builder: (context) {
                      final parentTask = (state as DashboardLoaded).routeTasks.whereType<Task>().firstWhere(
                        (t) => t.destinations.any((dest) => dest.id == d.nextStop!.taskDestinationId),
                        orElse: () => null as dynamic,
                      );
                      return NextVisitCard(
                        nextStop: d.nextStop!,
                        parentTask: parentTask,
                      ).animateEntrance(delay: const Duration(milliseconds: 100));
                    },
                  ),
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
                badge: '${d.visitsToday}/${d.visitsTarget} Kunjungan',
                badgeColor: d.visitsToday >= d.visitsTarget ? const Color(0xFF10B981) : _navy,
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

        // Combined Route Sequence section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Urutan Rencana Kunjungan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: () => context.pushNamed(kRouteTasks),
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
        const SizedBox(height: 8),
        const Text(
          'Ikuti urutan kunjungan hari ini untuk rute yang optimal.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        
        _buildRouteSequence(optimizedSteps, l10n),

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
        child: Column(
          children: [
            Icon(LucideIcons.map, size: 40, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('Belum ada rute kunjungan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Rencana tugas hari ini akan muncul di sini.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
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
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: step.status == TaskStatus.done ? _green : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: step.status == TaskStatus.done ? _green : Colors.grey.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: step.status == TaskStatus.done
                            ? const Icon(LucideIcons.check, size: 16, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
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
                                    fontWeight: FontWeight.w800,
                                    color: step.isWarehouse ? Colors.blue : _green,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (step.status == TaskStatus.done)
                                  const Icon(LucideIcons.checkCircle2, color: _green, size: 14),
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
    const Color priorityColor = _navy;

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
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.calendar, size: 12, color: priorityColor),
                                SizedBox(width: 4),
                                Text(
                                  'TUGAS HARI INI',
                                  style: TextStyle(
                                    color: priorityColor,
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
                                backgroundColor: priorityColor,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hot Deals (Prioritas)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
            ),
            GestureDetector(
              onTap: () => context.pushNamed(kRouteDeals),
              child: const Text(
                'View Board',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _navy),
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
