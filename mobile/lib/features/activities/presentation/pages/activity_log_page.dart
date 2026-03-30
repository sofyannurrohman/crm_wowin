import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../../visits/presentation/bloc/visit_bloc.dart';
import '../../../visits/presentation/bloc/visit_event.dart';
import '../../../visits/presentation/bloc/visit_state.dart';
import '../../../visits/domain/entities/visit_activity.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  int _selectedTab = 0;
  final List<String> _tabs = ['Semua', 'Check-in', 'Check-out'];

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  void _fetchActivities() {
    context.read<VisitBloc>().add(const FetchActivities());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: BlocBuilder<VisitBloc, VisitState>(
        builder: (context, state) {
          if (state is VisitLoading) {
            return const Center(child: CircularProgressIndicator(color: _orange));
          } else if (state is ActivitiesLoaded) {
            final activities = state.activities;
            if (activities.isEmpty) {
              return _buildEmptyState();
            }
            return _buildActivityList(activities);
          } else if (state is VisitError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Tarik untuk memuat aktivitas'));
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.history, size: 64, color: _textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Belum ada riwayat aktivitas', style: TextStyle(color: _textSecondary)),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF4B5563)),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: const Text(
        'Log Aktivitas',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = _selectedTab == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? _orange : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isSelected ? _orange : _textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(List<VisitActivity> activities) {
    // Filter by tab
    final filtered = activities.where((a) {
      if (_selectedTab == 1) return a.type == 'checkin';
      if (_selectedTab == 2) return a.type == 'checkout';
      return true;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildActivityNode(filtered[index], isLast: index == filtered.length - 1);
      },
    );
  }

  Widget _buildActivityNode(VisitActivity item, {required bool isLast}) {
    IconData icon;
    Color iconColor;
    Color iconBgColor;

    if (item.type == 'checkin') {
      icon = LucideIcons.mapPin;
      iconColor = _orange;
      iconBgColor = const Color(0xFFFFF7ED);
    } else {
      icon = LucideIcons.checkCircle;
      iconColor = const Color(0xFF10B981);
      iconBgColor = const Color(0xFFF0FDF4);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.type == 'checkin' ? 'Check-in di Lokasi' : 'Check-out & Hasil Kunjungan',
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(item.createdAt),
                        style: TextStyle(
                          color: _textSecondary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    Text(
                      item.notes!,
                      style: const TextStyle(color: _textSecondary, fontSize: 14),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(item.createdAt),
                    style: TextStyle(color: _textSecondary.withOpacity(0.5), fontSize: 11),
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
          _buildNavItem(LucideIcons.home, 'Home', false, () => context.goNamed(kRouteDashboard)),
          _buildNavItem(LucideIcons.users, 'Leads', false, () {}),
          _buildNavItem(LucideIcons.history, 'Activities', true, () {}),
          _buildNavItem(LucideIcons.checkSquare, 'Tasks', false, () => context.goNamed(kRouteTasks)),
          _buildNavItem(Icons.more_horiz, 'More', false, () {}),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? _orange : const Color(0xFF9CA3AF), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? _orange : const Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
