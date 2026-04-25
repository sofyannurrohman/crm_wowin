import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../visits/domain/entities/visit_activity.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../visits/presentation/bloc/visit_bloc.dart';
import '../../../visits/presentation/bloc/visit_event.dart';
import '../../../visits/presentation/bloc/visit_state.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Check-in', 'Check-out'];

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
      backgroundColor: AppColors.background,
      drawer: const AppSidebar(),
      body: BlocBuilder<VisitBloc, VisitState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildPremiumHeader(),
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(LucideIcons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const Text('Activity Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                  IconButton(
                    icon: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 20),
                    onPressed: _fetchActivities,
                  ),
                ],
              ),
            ),
            const Text('Visit Records', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              height: 48,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _tabs[index],
                            style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, fontSize: 13, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 4, width: isSelected ? 40 : 0,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(VisitState state) {
    if (state is VisitLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (state is VisitError) return _buildErrorState(state.message);
    if (state is ActivitiesLoaded) {
      if (state.activities.isEmpty) return _buildEmptyState();
      
      final filtered = state.activities.where((a) {
        final normalizedType = a.type.toLowerCase().replaceAll('-', '').replaceAll('_', ''); 
        if (_selectedTab == 1) return normalizedType == 'checkin' || normalizedType == 'clockin';
        if (_selectedTab == 2) return normalizedType == 'checkout' || normalizedType == 'clockout';
        return true;
      }).toList();

      if (filtered.isEmpty) return _buildEmptyState();

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => _fetchActivities(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _buildActivityNode(filtered[index], isLast: index == filtered.length - 1).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(),
        ),
      );
    }
    return const Center(child: Text('Tarik untuk memuat aktivitas'));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle), child: Icon(LucideIcons.history, size: 48, color: AppColors.textPlaceholder)),
          const SizedBox(height: 24),
          const Text('No records found', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Your activity history will appear here.', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActivityNode(VisitActivity item, {required bool isLast}) {
    IconData icon;
    Color iconColor;
    Color iconBgColor;

    final type = item.type.toLowerCase().replaceAll('-', '').replaceAll('_', '');
    if (type == 'checkin' || type == 'clockin') {
      icon = type == 'clockin' ? LucideIcons.logIn : LucideIcons.mapPin;
      iconColor = const Color(0xFF3B82F6);
      iconBgColor = const Color(0xFFEFF6FF);
    } else if (type == 'checkout' || type == 'clockout') {
      icon = type == 'clockout' ? LucideIcons.logOut : LucideIcons.checkCircle;
      iconColor = const Color(0xFF10B981);
      iconBgColor = const Color(0xFFF0FDF4);
    } else {
      icon = LucideIcons.activity;
      iconColor = const Color(0xFF64748B);
      iconBgColor = const Color(0xFFF8FAFC);
    }

    return IntrinsicHeight(
      child: InkWell(
        onTap: () => _showActivityDetails(item),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle, border: Border.all(color: iconColor.withOpacity(0.1), width: 2)),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: const Color(0xFFF1F5F9))),
              ],
            ),
            const SizedBox(width: 20),
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
                            _getPrettyTypeLabel(item.type),
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(DateFormat('HH:mm').format(item.createdAt), style: const TextStyle(color: AppColors.textPlaceholder, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (item.notes != null && item.notes!.isNotEmpty)
                      Text(item.notes!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4)),
                    const SizedBox(height: 12),
                    if (item.dealTitle != null || item.dealId != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE0E7FF))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.briefcase, size: 12, color: Color(0xFF4F46E5)),
                            const SizedBox(width: 8),
                            Text(item.dealTitle ?? 'Linked Deal', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5), letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(DateFormat('MMM d, yyyy').format(item.createdAt), style: const TextStyle(color: AppColors.textPlaceholder, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPrettyTypeLabel(String type) {
    final t = type.toLowerCase();
    if (t.contains('checkin') || t.contains('check-in')) return 'Visit Check-in';
    if (t.contains('checkout') || t.contains('check-out')) return 'Visit Checkout';
    if (t.contains('clockin') || t.contains('clock_in')) return 'Clock-in';
    if (t.contains('clockout') || t.contains('clock_out')) return 'Clock-out';
    return type;
  }

  void _showActivityDetails(VisitActivity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActivityDetailSheet(activity: activity),
    );
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
          ],
        ),
      ),
    );
  }
}

class _ActivityDetailSheet extends StatelessWidget {
  final VisitActivity activity;

  const _ActivityDetailSheet({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
          Text(activity.type.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(_getPrettyTitle(activity), style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(DateFormat('EEEE, d MMMM yyyy - HH:mm').format(activity.createdAt), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Color(0xFFF1F5F9))),
          
          if (activity.notes != null && activity.notes!.isNotEmpty) ...[
            const Text('ACTIVITY NOTES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.textPlaceholder, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(activity.notes!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
          ],

          if (activity.outcome != null && activity.outcome!.isNotEmpty) ...[
            const Text('STRUCTURED OUTCOME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.textPlaceholder, letterSpacing: 1)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBBF7D0))),
              child: Text(activity.outcome!, style: const TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w800, fontSize: 14)),
            ),
            const SizedBox(height: 24),
          ],

          const Text('LOCATION DETAILS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.textPlaceholder, letterSpacing: 1)),
          const SizedBox(height: 12),
          _buildInfoRow(LucideIcons.mapPin, 'Coordinates', '${activity.latitude}, ${activity.longitude}'),
          if (activity.distance != null)
            _buildInfoRow(LucideIcons.navigation, 'Accuracy', '${activity.distance!.toStringAsFixed(1)}m from target'),
          const SizedBox(height: 24),

          if (activity.selfiePhotoPath != null || activity.placePhotoPath != null) ...[
            const Text('VALIDATION PHOTOS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.textPlaceholder, letterSpacing: 1)),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (activity.selfiePhotoPath != null) _buildPhotoCard('Selfie', activity.selfiePhotoPath!),
                  if (activity.placePhotoPath != null) ...[
                    const SizedBox(width: 16),
                    _buildPhotoCard('Location', activity.placePhotoPath!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
          
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
            child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  String _getPrettyTitle(VisitActivity item) {
    final t = item.type.toLowerCase();
    if (t.contains('checkin')) return 'Location Check-in';
    if (t.contains('checkout')) return 'Visit Summary';
    if (t.contains('clockin')) return 'Shift Started';
    if (t.contains('clockout')) return 'Shift Ended';
    return item.type;
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textPlaceholder),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String label, String path) {
    final displayPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = path.startsWith('http') ? path : '${ApiEndpoints.uploadsBaseUrl}$displayPath';

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9)), color: Colors.white),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: Image.network(fullUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF1F5F9), child: const Icon(LucideIcons.imageOff, color: AppColors.textPlaceholder, size: 24)))),
          Container(padding: const EdgeInsets.symmetric(vertical: 6), color: const Color(0xFFF8FAFC), child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.textPlaceholder))),
        ],
      ),
    );
  }
}
