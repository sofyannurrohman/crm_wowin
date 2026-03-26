import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wowin CRM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(FetchDashboardKpis());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardBloc>().add(FetchDashboardKpis());
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(context),
              const SizedBox(height: 24),
              _buildKpiSection(context),
              const SizedBox(height: 24),
              Text(
                'Menu Utama',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    title: 'Pelanggan',
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => context.pushNamed(kRouteCustomers),
                  ),
                  _buildMenuCard(
                  context,
                  title: 'Kunjungan',
                  icon: Icons.location_on,
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to visits history/check-in context
                    // For now, let's say it goes to check-in if not checked in, 
                    // or history? 
                    // Let's just use history for now if available, or just a placeholder.
                    // The user mentioned "Check-in foto, check-out"
                    context.pushNamed(kRouteCheckIn);
                  },
                ),
                  _buildMenuCard(
                    context,
                    title: 'Leads',
                    icon: Icons.leaderboard,
                    color: Colors.green,
                    onTap: () => context.pushNamed(kRouteLeads),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Deals',
                    icon: Icons.handshake,
                    color: Colors.purple,
                    onTap: () => context.pushNamed(kRouteDeals),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Absensi',
                    icon: Icons.access_time,
                    color: Colors.teal,
                    onTap: () => context.pushNamed(kRouteAttendanceHistory),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Peta',
                    icon: Icons.map,
                    color: Colors.red,
                    onTap: () => context.pushNamed(kRouteMap),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang,',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  'Sales Wowin',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSection(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DashboardLoaded) {
          final summary = state.summary;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Performa',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      context,
                      label: 'Total Penjualan',
                      value: 'Rp ${summary.totalSales}',
                      icon: Icons.monetization_on,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKpiCard(
                      context,
                      label: 'Leads Baru',
                      value: '${summary.newLeads}',
                      icon: Icons.person_add,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      context,
                      label: 'Deals Aktif',
                      value: '${summary.activeDeals}',
                      icon: Icons.trending_up,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKpiCard(
                      context,
                      label: 'Kunjungan Hari Ini',
                      value: '${summary.visitsToday}',
                      icon: Icons.calendar_today,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else if (state is DashboardError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
