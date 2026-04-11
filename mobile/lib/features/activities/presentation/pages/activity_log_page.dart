import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../visits/domain/entities/visit_activity.dart';
import '../../../visits/presentation/widgets/check_out_sheet.dart';
import '../../../../core/api/api_endpoints.dart';
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
      child: InkWell(
        onTap: () => _showActivityDetails(item),
        borderRadius: BorderRadius.circular(12),
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
                    if (item.dealTitle != null || item.dealId != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.briefcase, size: 14, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Text(
                              item.dealTitle ?? 'Linked Deal',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
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
      ),
    );
  }

  void _showActivityDetails(VisitActivity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivityDetailSheet(activity: activity),
    );
  }
}

class _ActivityDetailSheet extends StatelessWidget {
  final VisitActivity activity;

  const _ActivityDetailSheet({required this.activity});

  // Re-define these or make them public in ActivityLogPage if needed. 
  // For now local constants for clarity.
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final type = activity.type.toLowerCase().replaceAll('-', '').replaceAll('_', '');
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              activity.type.toUpperCase(),
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getDisplayTitle(activity),
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, d MMMM yyyy - HH:mm').format(activity.createdAt),
              style: const TextStyle(color: _textSecondary, fontSize: 13),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),

            if (activity.notes != null && activity.notes!.isNotEmpty) ...[
              const Text(
                'Catatan / Hasil Kunjungan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                activity.notes!,
                style: const TextStyle(color: _textSecondary, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 24),
            ],

            if (activity.outcome != null && activity.outcome!.isNotEmpty) ...[
              const Text(
                'Hasil Terstruktur',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Text(
                  activity.outcome!,
                  style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Location Info
            const Text(
              'Detail Lokasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(LucideIcons.mapPin, 'Koordinat', '${activity.latitude}, ${activity.longitude}'),
            if (activity.distance != null)
              _buildInfoRow(LucideIcons.navigation, 'Jarak dari Target', '${activity.distance!.toStringAsFixed(1)} meter'),
            
            const SizedBox(height: 24),

            // Photos
            if (activity.selfiePhotoPath != null || activity.placePhotoPath != null) ...[
              const Text(
                'Foto Validasi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (activity.selfiePhotoPath != null)
                      _buildPhotoCard('Foto Selfie', activity.selfiePhotoPath!),
                    if (activity.placePhotoPath != null)
                      _buildPhotoCard('Foto Lokasi', activity.placePhotoPath!),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8622A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getDisplayTitle(VisitActivity item) {
    final type = item.type.toLowerCase();
    if (type.contains('check-in') || type == 'checkin') return 'Check-in di Lokasi';
    if (type.contains('check-out') || type == 'checkout') return 'Check-out & Hasil Kunjungan';
    if (type.contains('clock_in') || type == 'clockin') return 'Absen Masuk';
    if (type.contains('clock_out') || type == 'clockout') return 'Absen Pulang';
    return 'Aktivitas: ${item.type}';
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: _textSecondary, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String label, String path) {
    // Determine full URL
    final fullUrl = path.startsWith('http') ? path : 'https://crm-wowin.wowinpurnomoputra.my.id/uploads/$path';

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              fullUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade100,
                child: const Icon(LucideIcons.imageOff, color: Colors.grey),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.grey.shade50,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
