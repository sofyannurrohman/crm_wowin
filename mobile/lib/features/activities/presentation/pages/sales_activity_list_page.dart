import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../bloc/sales_activity_bloc.dart';
import '../bloc/sales_activity_event.dart';
import '../bloc/sales_activity_state.dart';
import '../../domain/entities/sales_activity.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/router/route_constants.dart';

class SalesActivityListPage extends StatefulWidget {
  const SalesActivityListPage({super.key});

  @override
  State<SalesActivityListPage> createState() => _SalesActivityListPageState();
}

class _SalesActivityListPageState extends State<SalesActivityListPage> {
  // Brand color palette
  static const Color _primary = Color(0xFFE8622A);
  static const Color _bg = Color(0xFFF8F9FA);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  void _fetchActivities() {
    context.read<SalesActivityBloc>().add(const FetchSalesActivities());
  }

  // ── Icon & color helpers ──────────────────────────────────────────────────

  IconData _iconForType(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'visit':
        return LucideIcons.mapPin;
      case 'negotiation':
        return LucideIcons.messageSquare;
      case 'deal':
        return LucideIcons.users;
      case 'follow_up':
        return LucideIcons.phoneCall;
      default:
        return LucideIcons.activity;
    }
  }

  Color _colorForType(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'visit':
        return Colors.blue;
      case 'negotiation':
        return Colors.orange;
      case 'deal':
        return Colors.green;
      case 'follow_up':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _labelForType(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'visit':
        return 'KUNJUNGAN';
      case 'negotiation':
        return 'NEGOSIASI';
      case 'deal':
        return 'DEAL / CLOSING';
      case 'follow_up':
        return 'FOLLOW UP';
      default:
        return (type ?? 'LAINNYA').toUpperCase();
    }
  }

  // ── CRUD actions ──────────────────────────────────────────────────────────

  Future<void> _onAdd() async {
    final result = await context.pushNamed(kRouteAddSalesActivity);
    if (result == true && mounted) {
      _fetchActivities();
    }
  }

  Future<void> _onEdit(SalesActivity activity) async {
    final result = await context.pushNamed(
      kRouteAddSalesActivity,
      extra: activity,
    );
    if (result == true && mounted) {
      _fetchActivities();
    }
  }

  Future<void> _onDelete(SalesActivity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Aktivitas?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Aktivitas "${activity.title}" akan dihapus secara permanen.',
          style: TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context
          .read<SalesActivityBloc>()
          .add(DeleteSalesActivitySubmitted(activity.id));
    }
  }

  void _onCheckOut(SalesActivity activity) {
    if (activity.checkInTime == null) return;
    
    final updatedActivity = activity.copyWith(
      checkOutTime: DateTime.now(),
    );
    context.read<SalesActivityBloc>().add(UpdateSalesActivitySubmitted(updatedActivity));
  }

  // ── Widget tree ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppSidebar(),
      appBar: _buildAppBar(context),
      body: BlocConsumer<SalesActivityBloc, SalesActivityState>(
        listener: (context, state) {
          if (state is SalesActivityOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
            _fetchActivities();
          } else if (state is SalesActivityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SalesActivityLoading) {
            return const Center(
                child: CircularProgressIndicator(color: _primary));
          }

          if (state is SalesActivityError) {
            return _buildErrorState(state.message);
          }

          if (state is SalesActivityLoaded) {
            if (state.activities.isEmpty) {
              return const EmptyStateWidget(
                icon: LucideIcons.calendarX,
                title: 'Belum Ada Aktivitas',
                message:
                    'Catat aktivitas harianmu untuk melacak perkembangan hubungan dengan klien.',
              );
            }

            return RefreshIndicator(
              color: _primary,
              onRefresh: () async => _fetchActivities(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: state.activities.length,
                itemBuilder: (context, index) {
                  return _buildActivityCard(state.activities[index]);
                },
              ),
            );
          }

          // Initial state – show pull-to-refresh hint
          return RefreshIndicator(
            color: _primary,
            onRefresh: () async => _fetchActivities(),
            child: ListView(
              children: const [
                SizedBox(height: 200),
                Center(
                    child: Text('Tarik ke bawah untuk memuat aktivitas')),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAdd,
        backgroundColor: _primary,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text(
          'Catat Aktivitas',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
        'Aktivitas Sales',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.refreshCw,
              color: Color(0xFF4B5563), size: 20),
          onPressed: _fetchActivities,
          tooltip: 'Muat ulang',
        ),
      ],
    );
  }

  // ── Cards ────────────────────────────────────────────────────────────────

  Widget _buildActivityCard(SalesActivity activity) {
    final activityType = activity.activityType;
    final icon = _iconForType(activityType);
    final iconColor = _colorForType(activityType);
    final typeLabel = _labelForType(activityType);

    // Display activityAt (required, never null); fall back only on createdAt
    final displayDate = DateFormat('dd MMM yyyy, HH:mm').format(
      activity.activityAt,
    );

    // Null-safe notes
    final notes = (activity.notes.isNotEmpty) ? activity.notes : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // ── Header row ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon badge
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                // Title + type + notes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title.isNotEmpty
                            ? activity.title
                            : 'Tanpa Judul',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: iconColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      if (notes != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          notes,
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // CRUD action menu
                _buildActionMenu(activity),
              ],
            ),
          ),

          // ── VISIT SESSION DETAILS ──
          if (activityType == 'visit' && activity.checkInTime != null)
            _buildVisitSession(activity),
          
          if (activityType == 'visit' && activity.checkOutTime == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _onCheckOut(activity),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(LucideIcons.logOut, size: 16),
                  label: const Text('Check-Out Kunjungan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          if (activityType == 'visit' && activity.checkOutTime == null)
            const SizedBox(height: 12),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── Footer row: date + linked entity tag ──
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(LucideIcons.calendar,
                    size: 14, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    displayDate,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Linked entity tag (null-safe)
                if (activity.lead?.name != null)
                  _buildTag(LucideIcons.user,
                      activity.lead!.name, Colors.blueGrey)
                else if (activity.customer?.name != null)
                  _buildTag(LucideIcons.building,
                      activity.customer!.name, Colors.teal)
                else if (activity.deal?.title != null)
                  _buildTag(LucideIcons.briefcase,
                      activity.deal!.title, Colors.indigo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Three-dot popup menu for Edit / Delete
  Widget _buildActionMenu(SalesActivity activity) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical,
          size: 20, color: Color(0xFF9CA3AF)),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') _onEdit(activity);
        if (value == 'delete') _onDelete(activity);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(LucideIcons.edit2, size: 16, color: _primary),
              const SizedBox(width: 10),
              const Text('Edit Aktivitas'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(LucideIcons.trash2, size: 16, color: Colors.red),
              SizedBox(width: 10),
              Text('Hapus', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(IconData icon, String? text, Color color) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
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
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitSession(SalesActivity activity) {
    const String imageBaseUrl = 'http://localhost:8082'; // Base URL for static photos
    final duration = _formatDuration(activity.checkInTime, activity.checkOutTime);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildSessionPoint(
                  LucideIcons.logIn,
                  'Check-In',
                  activity.checkInTime!,
                  Colors.green,
                ),
                if (activity.checkOutTime != null) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 7),
                    child: SizedBox(
                      height: 12,
                      child: VerticalDivider(width: 1, thickness: 1),
                    ),
                  ),
                  _buildSessionPoint(
                    LucideIcons.logOut,
                    'Check-Out',
                    activity.checkOutTime!,
                    Colors.red,
                  ),
                ],
              ],
            ),
          ),
          
          if (duration.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Row(
                children: [
                  const Icon(LucideIcons.timer, size: 14, color: _primary),
                  const SizedBox(width: 6),
                  Text(
                    'Durasi Kunjungan: $duration',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),

          // Photo Gallery
          if (activity.selfiePhotoPath != null || activity.placePhotoPath != null) ...[
            const SizedBox(height: 12),
            const Text(
              'BUKTI KUNJUNGAN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: _textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (activity.selfiePhotoPath != null)
                  _buildPhotoItem('Selfie', '$imageBaseUrl${activity.selfiePhotoPath}'),
                if (activity.placePhotoPath != null) ...[
                  const SizedBox(width: 12),
                  _buildPhotoItem('Lokasi', '$imageBaseUrl${activity.placePhotoPath}'),
                ],
              ],
            ),
          ],
          
          if (activity.outcome != null && activity.outcome!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'HASIL KUNJUNGAN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: _textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              activity.outcome!,
              style: const TextStyle(
                fontSize: 14,
                color: _textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionPoint(IconData icon, String label, DateTime time, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          DateFormat('HH:mm').format(time),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoItem(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: const Icon(LucideIcons.imageOff, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: _textSecondary)),
      ],
    );
  }

  String _formatDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '';
    final diff = end.difference(start);
    if (diff.inHours > 0) {
      return '${diff.inHours} jam ${diff.inMinutes % 60} menit';
    }
    return '${diff.inMinutes} menit';
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.alertCircle,
                size: 56, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchActivities,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
