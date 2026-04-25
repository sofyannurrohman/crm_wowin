import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../bloc/sales_activity_bloc.dart';
import '../bloc/sales_activity_event.dart';
import '../bloc/sales_activity_state.dart';
import '../../domain/entities/sales_activity.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';

class SalesActivityListPage extends StatefulWidget {
  const SalesActivityListPage({super.key});

  @override
  State<SalesActivityListPage> createState() => _SalesActivityListPageState();
}

class _SalesActivityListPageState extends State<SalesActivityListPage> {
  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  void _fetchActivities() {
    context.read<SalesActivityBloc>().add(const FetchSalesActivities());
  }

  IconData _iconForType(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'visit': return LucideIcons.mapPin;
      case 'negotiation': return LucideIcons.messageSquare;
      case 'deal': return LucideIcons.users;
      case 'follow_up': return LucideIcons.phoneCall;
      default: return LucideIcons.activity;
    }
  }

  Color _colorForType(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'visit': return const Color(0xFF3B82F6);
      case 'negotiation': return const Color(0xFFF59E0B);
      case 'deal': return const Color(0xFF10B981);
      case 'follow_up': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF64748B);
    }
  }

  String _labelForType(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'visit': return 'KUNJUNGAN';
      case 'negotiation': return 'NEGOSIASI';
      case 'deal': return 'DEAL / CLOSING';
      case 'follow_up': return 'FOLLOW UP';
      default: return (type ?? 'LAINNYA').toUpperCase();
    }
  }

  Future<void> _onAdd() async {
    final result = await context.pushNamed(kRouteAddSalesActivity);
    if (result == true && mounted) _fetchActivities();
  }

  Future<void> _onEdit(SalesActivity activity) async {
    final result = await context.pushNamed(kRouteAddSalesActivity, extra: activity);
    if (result == true && mounted) _fetchActivities();
  }

  Future<void> _onDelete(SalesActivity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Delete Activity?', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        content: Text('Activity "${activity.title}" will be permanently removed.', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL', style: TextStyle(color: AppColors.textPlaceholder, fontWeight: FontWeight.w900, fontSize: 12))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('DELETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<SalesActivityBloc>().add(DeleteSalesActivitySubmitted(activity.id));
    }
  }

  void _onCheckOut(SalesActivity activity) {
    if (activity.checkInTime == null) return;
    final updatedActivity = activity.copyWith(checkOutTime: DateTime.now());
    context.read<SalesActivityBloc>().add(UpdateSalesActivitySubmitted(updatedActivity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSidebar(),
      body: BlocConsumer<SalesActivityBloc, SalesActivityState>(
        listener: (context, state) {
          if (state is SalesActivityOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating),
            );
            _fetchActivities();
          } else if (state is SalesActivityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildPremiumHeader(),
              Expanded(
                child: _buildMainContent(state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAdd,
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('LOG ACTIVITY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(LucideIcons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const Text('Sales Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                  IconButton(
                    icon: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 20),
                    onPressed: _fetchActivities,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Activity Timeline', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('Keep track of your interactions', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(SalesActivityState state) {
    if (state is SalesActivityLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (state is SalesActivityError) return _buildErrorState(state.message);
    if (state is SalesActivityLoaded) {
      if (state.activities.isEmpty) {
        return const EmptyStateWidget(icon: LucideIcons.calendarX, title: 'No Activities Found', message: 'Log your daily interactions to track progress.');
      }
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => _fetchActivities(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          itemCount: state.activities.length,
          itemBuilder: (context, index) => _buildActivityCard(state.activities[index]).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideY(begin: 0.1),
        ),
      );
    }
    return const Center(child: Text('Pull to refresh activities'));
  }

  Widget _buildActivityCard(SalesActivity activity) {
    final activityType = activity.activityType;
    final icon = _iconForType(activityType);
    final iconColor = _colorForType(activityType);
    final typeLabel = _labelForType(activityType);
    final displayDate = DateFormat('dd MMM yyyy, HH:mm').format(activity.activityAt);
    final notes = (activity.notes.isNotEmpty) ? activity.notes : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.title.isNotEmpty ? activity.title : 'Untitled Activity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: iconColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                        child: Text(typeLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: iconColor, letterSpacing: 0.8)),
                      ),
                      if (notes != null) ...[
                        const SizedBox(height: 12),
                        Text(notes, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500), maxLines: 3, overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
                _buildActionMenu(activity),
              ],
            ),
          ),

          if (activityType == 'visit' && activity.checkInTime != null) _buildVisitSession(activity),
          
          if (activityType == 'visit' && activity.checkOutTime == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton.icon(
                onPressed: () => _onCheckOut(activity),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFEF2F2), foregroundColor: const Color(0xFFEF4444), elevation: 0, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                icon: const Icon(LucideIcons.logOut, size: 16),
                label: const Text('CHECK-OUT SESSION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(LucideIcons.calendar, size: 14, color: AppColors.textPlaceholder),
                const SizedBox(width: 8),
                Expanded(child: Text(displayDate, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                if (activity.lead?.name != null)
                  _buildTag(LucideIcons.user, activity.lead!.name, const Color(0xFF3B82F6))
                else if (activity.customer?.name != null)
                  _buildTag(LucideIcons.building, activity.customer!.name, const Color(0xFF0D9488))
                else if (activity.deal?.title != null)
                  _buildTag(LucideIcons.briefcase, activity.deal!.title, const Color(0xFF4F46E5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(SalesActivity activity) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, size: 20, color: AppColors.textPlaceholder),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (value) {
        if (value == 'edit') _onEdit(activity);
        if (value == 'delete') _onDelete(activity);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Row(children: const [Icon(LucideIcons.edit2, size: 16, color: AppColors.primary), SizedBox(width: 12), Text('Edit Activity', style: TextStyle(fontWeight: FontWeight.w600))])),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'delete', child: Row(children: const [Icon(LucideIcons.trash2, size: 16, color: Color(0xFFEF4444)), SizedBox(width: 12), Text('Delete', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600))])),
      ],
    );
  }

  Widget _buildTag(IconData icon, String? text, Color color) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 100), child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildVisitSession(SalesActivity activity) {
    const String imageBaseUrl = 'http://localhost:8082'; 
    final duration = _formatDuration(activity.checkInTime, activity.checkOutTime);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Column(
              children: [
                _buildSessionPoint(LucideIcons.logIn, 'Check-In', activity.checkInTime!, const Color(0xFF10B981)),
                if (activity.checkOutTime != null) ...[
                  const Padding(padding: EdgeInsets.only(left: 7), child: SizedBox(height: 12, child: VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)))),
                  _buildSessionPoint(LucideIcons.logOut, 'Check-Out', activity.checkOutTime!, const Color(0xFFEF4444)),
                ],
              ],
            ),
          ),
          
          if (duration.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 4),
              child: Row(
                children: [
                  const Icon(LucideIcons.timer, size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Duration: $duration', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ],
              ),
            ),

          if (activity.selfiePhotoPath != null || activity.placePhotoPath != null) ...[
            const SizedBox(height: 20),
            const Text('VISIT DOCUMENTATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPlaceholder, letterSpacing: 1.0)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (activity.selfiePhotoPath != null) _buildPhotoItem('Selfie', '$imageBaseUrl${activity.selfiePhotoPath}'),
                  if (activity.placePhotoPath != null) ...[
                    const SizedBox(width: 16),
                    _buildPhotoItem('Location', '$imageBaseUrl${activity.placePhotoPath}'),
                  ],
                ],
              ),
            ),
          ],
          
          if (activity.outcome != null && activity.outcome!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('OUTCOME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPlaceholder, letterSpacing: 1.0)),
            const SizedBox(height: 6),
            Text(activity.outcome!, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionPoint(IconData icon, String label, DateTime time, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Spacer(),
        Text(DateFormat('HH:mm').format(time), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildPhotoItem(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            url, width: 80, height: 80, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: const Color(0xFFF1F5F9), child: const Icon(LucideIcons.imageOff, color: AppColors.textPlaceholder, size: 20)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textPlaceholder, fontWeight: FontWeight.w900)),
      ],
    );
  }

  String _formatDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '';
    final diff = end.difference(start);
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inMinutes}m';
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.alertCircle, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 24),
            const Text('Data load failed', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _fetchActivities,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('TRY AGAIN', style: TextStyle(fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, minimumSize: const Size(160, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ],
        ),
      ),
    );
  }
}
