import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../visits/domain/entities/visit_activity.dart';
import '../../../visits/presentation/widgets/check_out_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../visits/presentation/bloc/visit_bloc.dart';
import '../../../visits/presentation/bloc/visit_event.dart';
import '../../../visits/presentation/bloc/visit_state.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  // changed orange -> new green #0D8549
  static const Color _orange = Color(0xFF0D8549);
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
      drawer: const AppSidebar(),
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
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(LucideIcons.menu, color: Color(0xFF4B5563)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
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
      final normalizedType = a.type.toLowerCase().replaceAll('-', '').replaceAll('_', ''); 
      if (_selectedTab == 1) return normalizedType == 'checkin' || normalizedType == 'clockin';
      if (_selectedTab == 2) return normalizedType == 'checkout' || normalizedType == 'clockout';
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

    final type = item.type.toLowerCase().replaceAll('-', '').replaceAll('_', '');
    if (type == 'checkin' || type == 'clockin') {
      icon = type == 'clockin' ? LucideIcons.logIn : LucideIcons.mapPin;
      iconColor = type == 'clockin' ? Colors.blue : _orange;
      iconBgColor = type == 'clockin' ? const Color(0xFFEFF6FF) : const Color(0xFFEFFBF5);
    } else if (type == 'checkout' || type == 'clockout') {
      icon = type == 'clockout' ? LucideIcons.logOut : LucideIcons.checkCircle;
      iconColor = type == 'clockout' ? Colors.red : const Color(0xFF10B981);
      iconBgColor = type == 'clockout' ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
    } else {
      icon = LucideIcons.activity;
      iconColor = Colors.blue;
      iconBgColor = const Color(0xFFEFF6FF);
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
                          item.type.toLowerCase().contains('check-in') || item.type.toLowerCase() == 'checkin'
                              ? 'Check-in di Lokasi' 
                              : item.type.toLowerCase().contains('check-out') || item.type.toLowerCase() == 'checkout'
                                  ? 'Check-out & Hasil Kunjungan'
                                  : item.type.toLowerCase().contains('clock_in') || item.type.toLowerCase() == 'clockin'
                                      ? 'Absen Masuk (Attendance)'
                                      : item.type.toLowerCase().contains('clock_out') || item.type.toLowerCase() == 'clockout'
                                          ? 'Absen Pulang (Attendance)'
                                          : 'Aktivitas: ${item.type}',
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
                  if (type == 'checkin') ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CheckOutSheet(
                            scheduleId: item.scheduleId ?? 'adhoc',
                            customerName: 'Customer Visit', // In real app, fetch from ID
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.clipboardCheck, size: 14),
                      label: const Text('Complete Outcome', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _orange,
                        side: const BorderSide(color: _orange, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
