import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/check_out_sheet.dart';
import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart' as sidebar;
import '../../domain/entities/visit_activity.dart';

class VisitHistoryPage extends StatefulWidget {
  const VisitHistoryPage({super.key});

  @override
  State<VisitHistoryPage> createState() => _VisitHistoryPageState();
}

class _VisitHistoryPageState extends State<VisitHistoryPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  void _fetchActivities() {
    final authState = context.read<AuthBloc>().state;
    String? salesId;
    if (authState is Authenticated && authState.user.role == 'sales') {
      salesId = authState.user.id;
    }
    context.read<VisitBloc>().add(FetchActivities(salesId: salesId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const sidebar.AppSidebar(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchActivities,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 22),
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
                  const Text('Visit History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Past Interactions', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('Review your field activities', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(VisitState state) {
    if (state is VisitLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (state is ActivitiesLoaded) {
      if (state.activities.isEmpty) return _buildEmptyState();
      return Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => _fetchActivities(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                itemCount: state.activities.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return _buildVisitItem(state.activities[index]).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX();
                },
              ),
            ),
          ),
        ],
      );
    }
    return _buildErrorState('Failed to load visit history');
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Search visit records...',
            hintStyle: TextStyle(color: AppColors.textPlaceholder, fontSize: 14, fontWeight: FontWeight.w500),
            prefixIcon: Icon(LucideIcons.search, color: AppColors.primary, size: 18),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildVisitItem(VisitActivity item) {
    final bool isCheckIn = item.type.toLowerCase().contains('check-in') || item.type.toLowerCase() == 'checkin';
    final bool isCompleted = item.status == 'completed' || item.status == 'finalized';
    final bool isDraft = item.status == 'DRAFT_PHOTO';
    
    return GestureDetector(
      onTap: () => context.pushNamed(kRouteVisitDetail, pathParameters: {'id': item.id}),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF1F5F9), width: isCompleted ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: isCheckIn ? AppColors.primary.withOpacity(0.08) : const Color(0xFFF0F9FF), 
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: Icon(
                    isCheckIn ? LucideIcons.mapPin : (isCompleted ? LucideIcons.checkCircle2 : LucideIcons.clock), 
                    color: isCheckIn ? AppColors.primary : (isCompleted ? AppColors.emerald : const Color(0xFF0EA5E9)), 
                    size: 22
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isCheckIn ? 'Check-in Record' : 'Check-out Record', 
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.3)
                            )
                          ),
                          _buildStatusBadge(item.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(DateFormat('HH:mm').format(item.createdAt), style: const TextStyle(color: AppColors.textPlaceholder, fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.textPlaceholder, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(DateFormat('EEEE, MMM d').format(item.createdAt), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      Text(item.customerName ?? 'Unknown Target', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      
                      if (isCompleted && !isCheckIn) ...[
                         Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withOpacity(0.05), 
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.emerald.withOpacity(0.1))
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(LucideIcons.shoppingBag, size: 14, color: AppColors.emerald),
                                  const SizedBox(width: 8),
                                  const Text('FINALISASI LAPORAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.emerald, letterSpacing: 1)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (item.dealAmount != null && item.dealAmount! > 0)
                                Text('Rp ${NumberFormat('#,###', 'id_ID').format(item.dealAmount)}', 
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.emerald)),
                              if (item.outcome != null)
                                Text('Hasil: ${item.outcome == 'deal_won' ? "Deal Berhasil" : "Negosiasi"}', 
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                              if (item.notes != null && item.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(item.notes!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
                                ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
                          child: Text(item.notes ?? 'No visit notes recorded.', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (isCheckIn && !isCompleted && !isDraft) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CheckOutSheet(scheduleId: item.scheduleId ?? 'adhoc', customerName: item.customerName ?? 'Customer Visit'),
                  );
                },
                icon: const Icon(LucideIcons.clipboardCheck, size: 16, color: Colors.white),
                label: const Text('COMPLETE VISIT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              ),
            ],
            if (isDraft && !isCheckIn) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.pushNamed(kRouteFinalizeVisit, extra: item),
                icon: const Icon(LucideIcons.edit3, size: 16, color: Colors.white),
                label: const Text('FINALISASI LAPORAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, elevation: 0, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color = AppColors.textPlaceholder;
    String label = 'UNSET';
    
    if (status == 'completed' || status == 'finalized') {
      color = AppColors.emerald;
      label = 'COMPLETED';
    } else if (status == 'DRAFT_PHOTO') {
      color = Colors.orange;
      label = 'FINALIZATION REQ';
    } else if (status == 'draft') {
      color = AppColors.primary;
      label = 'IN PROGRESS';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(LucideIcons.history, size: 64, color: AppColors.primary)),
          const SizedBox(height: 24),
          const Text('No History Found', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Your recorded visits will appear here.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _fetchActivities,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            label: const Text('REFRESH', style: TextStyle(fontWeight: FontWeight.w900)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary, width: 2), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 64, color: Color(0xFFEF4444)),
          const SizedBox(height: 24),
          Text(message, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _fetchActivities,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(160, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
