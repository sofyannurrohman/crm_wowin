import 'package:flutter/material.dart';
import 'package:wowin_crm/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
import '../../../visits/presentation/bloc/visit_bloc.dart';
import '../../../visits/presentation/bloc/visit_event.dart';
import '../../../visits/presentation/bloc/visit_state.dart';
import '../../domain/entities/kpi_dashboard.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../deals/presentation/bloc/deal_bloc.dart';
import '../../../deals/presentation/bloc/deal_state.dart';
import 'package:wowin_crm/features/tasks/domain/entities/task.dart';
import 'package:wowin_crm/features/tasks/domain/entities/task_destination.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  static const Color _emerald = AppColors.primary;
  static const Color _emeraldDark = AppColors.primaryDark;
  static const Color _bg = AppColors.background;
  static const Color _slate900 = AppColors.textPrimary;
  static const Color _slate500 = AppColors.textSecondary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchDashboardData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchDashboardData();
    }
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
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<TaskBloc, TaskState>(listener: (context, state) { if (state is TaskOperationSuccess) _fetchDashboardData(); }),
                      BlocListener<VisitBloc, VisitState>(listener: (context, state) {
                        // Re-fetch activities whenever checkout succeeds so evening section updates
                        if (state is VisitSuccess) {
                          WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDashboardData());
                        }
                      }),
                      BlocListener<DealBloc, DealState>(listener: (context, state) { if (state is DealOperationSuccess) _fetchDashboardData(); }),
                      BlocListener<CustomerBloc, CustomerState>(listener: (context, state) { if (state is CustomerOperationSuccess) _fetchDashboardData(); }),
                    ],
                    child: RefreshIndicator(
                      color: _emerald,
                      onRefresh: () async => _fetchDashboardData(),
                      child: _buildScrollableContent(state, l10n),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildElderHeader(AppLocalizations l10n, {String? role}) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName = authState is Authenticated ? authState.user.name : 'User';
        final displayRole = role == 'delivery' ? 'Pengirim / Driver' : 'Sales';
        final now = DateTime.now();
        final greeting = now.hour < 12 ? 'Selamat Pagi' : (now.hour < 15 ? 'Selamat Siang' : (now.hour < 18 ? 'Selamat Sore' : 'Selamat Malam'));
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                    ),
                    child: const Icon(LucideIcons.menu, color: _slate900, size: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$greeting, $displayRole', style: const TextStyle(color: _slate500, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(userName, style: const TextStyle(color: _slate900, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => context.pushNamed(kRouteNotifications),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                  ),
                  child: const Icon(LucideIcons.bell, color: _slate900, size: 28),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollableContent(DashboardState state, AppLocalizations l10n) {
    if (state is DashboardLoading) {
      return const Center(child: CircularProgressIndicator(color: _emerald));
    } else if (state is DashboardLoaded) {
      return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isDelivery = authState is Authenticated && authState.user.role == 'delivery';

          if (isDelivery) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                _buildElderHeader(l10n, role: 'delivery').animate().fadeIn().slideY(begin: -0.2),
                const SizedBox(height: 24),
                _buildDeliveryActionCard(context).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                const SizedBox(height: 32),
                _buildSectionHeader('TUGAS PENGIRIMAN', 'Lihat Semua', () {}),
                const SizedBox(height: 16),
                _buildDeliveryTaskSection(state, l10n).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 100),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              _buildElderHeader(l10n).animate().fadeIn().slideY(begin: -0.2),
              const SizedBox(height: 24),
              _buildMainTargetCard(state.dashboard, l10n).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 32),
              _buildElderActionGrid(context).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95)),
              const SizedBox(height: 40),
              _buildSectionHeader('TUGAS HARI INI', 'Lihat Rute', () => context.pushNamed(kRouteTasks)),
              const SizedBox(height: 16),
              _buildElderTaskSection(state, l10n).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 32),
              _buildEveningTaskBannerElder().animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 100),
            ],
          );
        },
      );
    } else if (state is DashboardError) {
      return _buildError(state.message, l10n);
    }
    return const SizedBox();
  }

  Widget _buildDeliveryActionCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {}, // Future: Open Map for optimized route
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: const Icon(LucideIcons.truck, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 24),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SIAP KIRIM', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    SizedBox(height: 4),
                    Text('Lihat rute pengiriman hari ini', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: Colors.white70, size: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryTaskSection(DashboardLoaded state, AppLocalizations l10n) {
    if (state.pendingInvoices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Icon(LucideIcons.packageCheck, color: _emerald.withOpacity(0.2), size: 64),
              const SizedBox(height: 20),
              const Text('Kosong!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _slate900)),
              const Text('Tidak ada kiriman yang tertunda.', style: TextStyle(fontSize: 16, color: _slate500)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: state.pendingInvoices.length,
      itemBuilder: (context, index) {
        final invoice = state.pendingInvoices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: const Icon(LucideIcons.package, color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoice.invoiceNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.blue, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    const Text('TOKO CUSTOMER A', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _slate900)), // TODO: Get customer name
                    const SizedBox(height: 4),
                    Text(_formatCurrency(invoice.amount, l10n.currencySymbol), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.orange)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _emerald,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('KIRIM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainTargetCard(KpiDashboard d, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: AppColors.premiumGradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: _emerald.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 12))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('OMZET BULAN INI', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(_formatCurrency(d.monthlyRevenue, l10n.currencySymbol), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Target: ${d.targetMetPercentage.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                Text('${d.daysLeft} hari lagi', style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (d.targetMetPercentage / 100).clamp(0, 1),
                backgroundColor: Colors.white.withOpacity(0.15),
                color: Colors.white,
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElderActionGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MENU UTAMA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _slate500, letterSpacing: 1.2)),
          const SizedBox(height: 20),
          // Big primary "MULAI VISIT" → launches full check-in wizard without pre-select
          GestureDetector(
            onTap: () => context.pushNamed(
              kRouteCheckIn,
              extra: {'scheduleId': 'adhoc'},
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: _emerald.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(18)),
                    child: const Icon(LucideIcons.mapPin, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MULAI KUNJUNGAN', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        SizedBox(height: 4),
                        Text('Pilih toko terdekat & mulai kunjungan', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: Colors.white70, size: 28),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _buildElderMenuButton(LucideIcons.store, 'Tambah\nToko', Colors.blue, () => context.pushNamed(kRouteAddCustomer)),
              _buildElderMenuButton(LucideIcons.shoppingCart, 'Buat\nPesanan', Colors.purple, () => context.pushNamed(kRouteAddDeal)),
              _buildElderMenuButton(LucideIcons.history, 'Riwayat\nAktivitas', Colors.teal, () => context.pushNamed(kRouteActivityLog)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElderMenuButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: _slate900)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionLabel, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _slate500, letterSpacing: 1.2)),
          TextButton(onPressed: onAction, child: Text(actionLabel, style: const TextStyle(color: _emerald, fontWeight: FontWeight.w900, fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildElderTaskSection(DashboardLoaded state, AppLocalizations l10n) {
    final optimizedSteps = _getOptimizedSteps(state.routeTasks);
    _RouteStep? nextStop;
    try { nextStop = optimizedSteps.firstWhere((s) => !s.isWarehouse && s.status != TaskStatus.done); } catch (_) { nextStop = null; }

    if (nextStop == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.black.withOpacity(0.05))),
          child: Column(
            children: [
              Icon(LucideIcons.checkCircle2, color: _emerald.withOpacity(0.3), size: 48),
              const SizedBox(height: 16),
              const Text('Semua Tugas Selesai!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _slate900)),
              const Text('Tidak ada kunjungan terjadwal.', style: TextStyle(fontSize: 14, color: _slate500)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: _emerald.withOpacity(0.2), width: 2),
          boxShadow: [BoxShadow(color: _emerald.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: _emerald.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.navigation, color: _emerald, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(child: Text('TUJUAN BERIKUTNYA', style: TextStyle(color: _emerald, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1))),
              ],
            ),
            const SizedBox(height: 20),
            Text(nextStop.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _slate900, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.mapPin, size: 16, color: _slate500),
                const SizedBox(width: 8),
                Expanded(child: Text(nextStop.address, style: const TextStyle(fontSize: 16, color: _slate500), maxLines: 2, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                 final authState = context.read<AuthBloc>().state;
                 final userId = (authState is Authenticated) ? authState.user.id : null;
                 final userName = (authState is Authenticated) ? authState.user.name : null;
                 
                 context.pushNamed(
                   kRouteCheckIn,
                   extra: {
                     'customerId': nextStop?.customerId,
                     'customerName': nextStop?.name,
                     'customerAddress': nextStop?.address,
                     'targetLat': nextStop?.latitude,
                     'targetLng': nextStop?.longitude,
                     'targetRadiusMeters': 200.0,
                     'salesId': userId,
                     'salesmanName': userName,
                     'taskDestinationId': nextStop?.id,
                     'scheduleId': nextStop?.scheduleId ?? 'adhoc',
                   },
                 );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _emerald,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: const Text('MULAI KUNJUNGAN SEKARANG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEveningTaskBannerElder() {
    return BlocBuilder<VisitBloc, VisitState>(
      builder: (context, state) {
        if (state is! ActivitiesLoaded) return const SizedBox.shrink();

        // Only show checkout records with DRAFT_PHOTO status (avoid check-in duplicates)
        final seenIds = <String>{};
        final draftVisits = state.activities
            .where((a) => a.status == 'DRAFT_PHOTO' && a.type == 'check-out')
            .where((a) => seenIds.add(a.id.toString()))
            .toList();
        if (draftVisits.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('LAPORAN SORE HARI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _slate500, letterSpacing: 1.2)),
                      Text('${draftVisits.length} toko belum diinput', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w700, fontSize: 14)),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.pushNamed(kRouteEveningTasks),
                    child: const Text('Lihat Semua', style: TextStyle(color: _emerald, fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...draftVisits.take(3).map((visit) => GestureDetector(
                onTap: () => context.pushNamed(kRouteFinalizeVisit, extra: visit),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
                    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(LucideIcons.clipboardSignature, color: Colors.orange, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visit.customerName ?? visit.leadName ?? 'Unknown',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _slate900),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(LucideIcons.clock, size: 16, color: _slate500),
                                const SizedBox(width: 6),
                                Text(
                                  'Check-in pukul ${visit.createdAt.hour.toString().padLeft(2, "0")}:${visit.createdAt.minute.toString().padLeft(2, "0")}',
                                  style: const TextStyle(fontSize: 14, color: _slate500, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Text('INPUT NOTA', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideX(begin: 0.1)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError(String message, AppLocalizations l10n) {
    return EmptyStateWidget(
      title: 'Gagal Memuat Data',
      message: message,
      icon: LucideIcons.alertCircle,
      onRetry: () => _fetchDashboardData(),
      retryLabel: 'Coba Lagi',
    );
  }

  String _formatCurrency(double value, String symbol) {
    return NumberFormat.currency(locale: 'id_ID', symbol: '$symbol ', decimalDigits: 0).format(value);
  }

  List<_RouteStep> _getOptimizedSteps(List<Task> tasks) {
    if (tasks.isEmpty) return [];
    final List<_RouteStep> steps = [];
    for (final task in tasks) {
      if (task.status == TaskStatus.done) continue;
      if (task.warehouse != null) {
        steps.add(_RouteStep(id: 'wh-${task.warehouseId}', name: task.warehouse!.name, address: task.warehouse!.address ?? 'Gudang Utama', isWarehouse: true, status: task.status, parentTask: task, latitude: task.warehouse?.latitude, longitude: task.warehouse?.longitude));
      }
      final List<TaskDestination> unvisited = task.destinations.where((d) => d.status != TaskStatus.done).toList();
      final List<TaskDestination> done = task.destinations.where((d) => d.status == TaskStatus.done).toList();
      for (final dest in done) {
        steps.add(_RouteStep(id: dest.id, name: dest.targetName ?? 'Selesai', address: dest.targetAddress ?? '-', isWarehouse: false, status: dest.status, customerId: dest.customerId, leadId: dest.leadId, scheduleId: task.id, parentTask: task, latitude: dest.targetLatitude, longitude: dest.targetLongitude));
      }
      LatLng currentLoc = LatLng(task.warehouse?.latitude ?? -6.1754, task.warehouse?.longitude ?? 106.8272);
      if (done.isNotEmpty) {
        final lastDone = done.last;
        if (lastDone.targetLatitude != null && lastDone.targetLongitude != null) currentLoc = LatLng(lastDone.targetLatitude!, lastDone.targetLongitude!);
      }
      while (unvisited.isNotEmpty) {
        double minDistance = double.infinity;
        int nearestIndex = -1;
        for (int i = 0; i < unvisited.length; i++) {
          final dest = unvisited[i];
          if (dest.targetLatitude != null && dest.targetLongitude != null) {
            final destLoc = LatLng(dest.targetLatitude!, dest.targetLongitude!);
            final distance = const Distance().as(LengthUnit.Meter, currentLoc, destLoc);
            if (distance < minDistance) { minDistance = distance; nearestIndex = i; }
          }
        }
        if (nearestIndex != -1) {
          final nearestDest = unvisited.removeAt(nearestIndex);
          steps.add(_RouteStep(id: nearestDest.id, name: nearestDest.targetName ?? 'Tujuan', address: nearestDest.targetAddress ?? '-', isWarehouse: false, status: nearestDest.status, customerId: nearestDest.customerId, leadId: nearestDest.leadId, scheduleId: task.id, parentTask: task, latitude: nearestDest.targetLatitude, longitude: nearestDest.targetLongitude));
          currentLoc = LatLng(nearestDest.targetLatitude!, nearestDest.targetLongitude!);
        } else {
          for (final d in unvisited) { steps.add(_RouteStep(id: d.id, name: d.targetName ?? 'Tujuan', address: d.targetAddress ?? '-', isWarehouse: false, status: d.status, customerId: d.customerId, leadId: d.leadId, scheduleId: task.id, parentTask: task)); }
          unvisited.clear();
        }
      }
    }
    return steps;
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

  _RouteStep({required this.id, required this.name, required this.address, required this.isWarehouse, required this.status, this.customerId, this.leadId, this.scheduleId, this.parentTask, this.latitude, this.longitude});
}
