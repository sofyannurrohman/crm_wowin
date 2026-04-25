import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:wowin_crm/l10n/app_localizations.dart';

import '../../domain/entities/deal.dart';
import '../../domain/entities/deal_item.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../visits/presentation/bloc/visit_bloc.dart';
import '../../../visits/presentation/bloc/visit_event.dart';
import '../../../visits/presentation/bloc/visit_state.dart';
import '../../../visits/domain/entities/visit_activity.dart';
import '../../../products/domain/entities/product.dart';
import '../bloc/deal_bloc.dart';
import '../bloc/deal_event.dart';
import '../bloc/deal_state.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';

class DealDetailPage extends StatefulWidget {
  final String dealId;

  const DealDetailPage({super.key, required this.dealId});

  @override
  State<DealDetailPage> createState() => _DealDetailPageState();
}

class _DealDetailPageState extends State<DealDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<DealBloc>().add(FetchDealDetail(widget.dealId));
    context.read<VisitBloc>().add(const FetchActivities());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DealBloc, DealState>(
      listener: (context, state) {
        if (state is DealOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          if (state.message.contains('menghapus')) {
            context.pop();
          }
        } else if (state is DealError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<DealBloc, DealState>(
          builder: (context, state) {
            if (state is DealLoading && state is! DealDetailLoaded) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is DealDetailLoaded) {
              return _buildDealDetails(context, state.deal);
            } else if (state is DealError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.alertTriangle, size: 64, color: Color(0xFFFCA5A5)),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<DealBloc>().add(FetchDealDetail(widget.dealId)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Retry Connection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Deal details unavailable'));
          },
        ),
      ),
    );
  }

  Widget _buildDealDetails(BuildContext context, Deal deal) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumHeader(deal),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                _buildMetricsGrid(deal),
                const SizedBox(height: 20),
                _buildDealItemsSection(context, deal),
                const SizedBox(height: 20),
                _buildCurrentStageCard(deal),
                const SizedBox(height: 20),
                _buildVisitSection(context, deal),
                const SizedBox(height: 20),
                _buildDealConfidenceCard(deal),
                const SizedBox(height: 32),
                _buildActivityTimeline(deal),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(Deal deal) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  ),
                  const Text(
                    'Deal Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final result = await context.pushNamed(kRouteAddDeal, extra: deal);
                          if (result == true && mounted) {
                            context.read<DealBloc>().add(FetchDealDetail(widget.dealId));
                          }
                        },
                        icon: const Icon(LucideIcons.edit3, color: Colors.white, size: 22),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(context, deal),
                        icon: const Icon(LucideIcons.trash2, color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildProfileSection(deal),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(Deal deal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Icon(LucideIcons.briefcase, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBadge(deal.status.toUpperCase(), Colors.white, Colors.white.withOpacity(0.2)),
                const SizedBox(height: 8),
                Text(
                  deal.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.building, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        deal.customer?.name ?? 'Anonymous Client',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(Deal deal) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Deal Value',
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp',
              decimalDigits: 0,
            ).format(deal.amount ?? 0),
            LucideIcons.trendingUp,
            'Est. Amount',
            true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Probability',
            '${deal.probability ?? 0}%',
            LucideIcons.target,
            'Success Rate',
            true,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, String subtext, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPlaceholder, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStageCard(Deal deal) {
    return GestureDetector(
      onTap: () => _showStagePicker(context, deal),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PIPELINE STAGE',
                  style: TextStyle(color: AppColors.textPlaceholder, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.edit2, color: AppColors.primary, size: 12),
                      SizedBox(width: 6),
                      Text('UPDATE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              deal.stage.toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 20),
            _buildStageProgress(deal.stage),
          ],
        ),
      ),
    );
  }

  Widget _buildStageProgress(String currentStage) {
    final stages = ['prospect', 'survey', 'negotiation', 'closing', 'closed_won'];
    final currentIndex = stages.indexOf(currentStage.toLowerCase());
    
    return Row(
      children: List.generate(stages.length, (index) {
        final isActive = index <= currentIndex;
        final isLast = index == stages.length - 1;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (!isLast) const SizedBox(width: 6),
            ],
          ),
        );
      }),
    );
  }

  void _showStagePicker(BuildContext context, Deal deal) {
    final stages = [
      {'id': 'prospect', 'label': 'Prospect', 'desc': 'Initial identifying of opportunity'},
      {'id': 'survey', 'label': 'Survey', 'desc': 'Location & needs assessment'},
      {'id': 'negotiation', 'label': 'Negotiation', 'desc': 'Price & contract discussions'},
      {'id': 'closing', 'label': 'Closing', 'desc': 'Finalizing offer details'},
      {'id': 'closed_won', 'label': 'Closed Won', 'desc': 'Deal successfully closed'},
      {'id': 'closed_lost', 'label': 'Closed Lost', 'desc': 'Deal failed or cancelled'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Change Pipeline Stage', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 24),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: stages.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final s = stages[index];
                  final isCurrent = s['id'] == deal.stage;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    title: Text(s['label']!, style: TextStyle(fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700, color: isCurrent ? AppColors.primary : AppColors.textPrimary)),
                    subtitle: Text(s['desc']!, style: const TextStyle(fontSize: 12)),
                    trailing: isCurrent ? const Icon(LucideIcons.checkCircle2, color: AppColors.primary) : null,
                    onTap: () {
                      context.read<DealBloc>().add(UpdateDealStageSubmitted(id: deal.id, stage: s['id']!));
                      context.pop();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Deal deal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Deal?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to delete "${deal.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textPlaceholder, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DealBloc>().add(DeleteDealSubmitted(deal.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete Deal', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitSection(BuildContext context, Deal deal) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FIELD ACTIVITY',
                style: TextStyle(color: AppColors.textPlaceholder, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
                child: const Icon(LucideIcons.calendar, color: AppColors.textSecondary, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Visit Verification',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.3),
          ),
          const SizedBox(height: 6),
          const Text(
            'Verify deal progress through physical site visits or meetings.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleVisitAction(context, deal),
                  icon: const Icon(LucideIcons.mapPin, size: 18),
                  label: const Text('Check-in Now', style: TextStyle(fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleVisitAction(BuildContext context, Deal deal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.calendar, color: AppColors.primary, size: 20),
              ),
              title: const Text('Schedule Visit', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('Set a date for the next meeting'),
              onTap: () => context.pop(),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.mapPin, color: Color(0xFF0EA5E9), size: 20),
              ),
              title: const Text('Instant Check-in', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('Start an ad-hoc visit at current location'),
              onTap: () {
                context.pop();
                context.pushNamed(
                  'visit_check_in', 
                  extra: {
                    'scheduleId': 'adhoc',
                    'customerId': deal.customerId,
                    'customerName': deal.customer?.name ?? deal.title,
                    'customerAddress': deal.customer?.address ?? 'Address not available',
                    'targetLat': (deal.customer?.latitude ?? 0.0).toDouble(),
                    'targetLng': (deal.customer?.longitude ?? 0.0).toDouble(),
                    'targetRadiusMeters': (deal.customer?.checkinRadius ?? 500).toDouble(),
                    'dealId': deal.id,
                  }
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealConfidenceCard(Deal deal) {
    final probability = deal.probability ?? 0;
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.barChart, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              const Text(
                'DEAL CONFIDENCE',
                style: TextStyle(color: AppColors.textPlaceholder, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const Spacer(),
              Text(
                '$probability%',
                style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: probability / 100.0,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'DEAL SUMMARY',
            style: TextStyle(color: AppColors.textPlaceholder, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            deal.description ?? 'No detailed description available for this deal.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline(Deal deal) {
    return BlocBuilder<VisitBloc, VisitState>(
      builder: (context, state) {
        List<VisitActivity> activities = [];
        if (state is ActivitiesLoaded) {
          activities = state.activities.where((a) => a.customerId == deal.customerId).toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity History',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 24),
            if (activities.isEmpty)
              _buildTimelineItem(
                icon: LucideIcons.filePlus,
                iconBg: AppColors.primary.withOpacity(0.08),
                iconColor: AppColors.primary,
                title: 'Deal Registered',
                time: 'Initial Event',
                desc: 'Opportunity "${deal.title}" was registered into the CRM system.',
                isLast: true,
              )
            else
              ...activities.asMap().entries.map((entry) {
                final index = entry.key;
                final activity = entry.value;
                final isLast = index == activities.length - 1;
                
                final isCheckIn = activity.type.toLowerCase().contains('checkin') || activity.type.toLowerCase().contains('check-in');

                return _buildTimelineItem(
                  icon: isCheckIn ? LucideIcons.mapPin : LucideIcons.checkCircle,
                  iconBg: isCheckIn ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                  iconColor: isCheckIn ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                  title: isCheckIn ? 'Site Visit: Check-in' : 'Visit Completed',
                  time: DateFormat('HH:mm').format(activity.createdAt),
                  desc: activity.notes ?? 'Interaction recorded with customer at site.',
                  isLast: isLast,
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String time,
    required String desc,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFF1F5F9),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w900)),
                      Text(time, style: const TextStyle(color: AppColors.textPlaceholder, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealItemsSection(BuildContext context, Deal deal) {
    final items = deal.items ?? [];
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ORDER ITEMS',
                style: TextStyle(color: AppColors.textPlaceholder, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              IconButton(
                icon: const Icon(LucideIcons.plusCircle, color: AppColors.primary, size: 20),
                onPressed: () => _showAddProductDialog(context, deal),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('No products added to this deal.', style: TextStyle(color: AppColors.textPlaceholder, fontSize: 13, fontWeight: FontWeight.w500)),
            )
          else
            ...items.map((item) => _buildProductItem(context, item, deal.id)),
          
          if (items.isNotEmpty) ...[
            const Divider(height: 32, color: Color(0xFFF1F5F9)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Value', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Text(
                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(deal.amount ?? 0),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, DealItem item, String dealId) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.package, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity} Unit x ${currencyFormatter.format(item.price)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => context.read<DealBloc>().add(RemoveDealItemSubmitted(item.id, dealId)),
                  child: const Text('Remove', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Text(
            currencyFormatter.format(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, Deal deal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddProductSheet(dealId: deal.id),
    );
  }
}

class _AddProductSheet extends StatefulWidget {
  final String dealId;
  const _AddProductSheet({required this.dealId});

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  String? _selectedProductId;
  double _quantity = 1;
  double _price = 0;
  String _productName = '';
  String _unit = 'pcs';
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        left: 24,
        right: 24,
        top: 30,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.x, size: 16, color: AppColors.textPlaceholder),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            tileColor: const Color(0xFFF8FAFC),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: const Color(0xFFF1F5F9))),
            leading: const Icon(LucideIcons.search, color: AppColors.primary),
            title: Text(_selectedProductId == null ? 'Select Product' : _productName, style: TextStyle(fontWeight: FontWeight.w700, color: _selectedProductId == null ? AppColors.textPlaceholder : AppColors.textPrimary)),
            trailing: const Icon(LucideIcons.chevronRight, size: 18),
            onTap: () async {
              final product = await context.pushNamed(kRouteProducts, extra: {'isSelectionMode': true}) as Product?;
              if (product != null) {
                setState(() {
                  _selectedProductId = product.id;
                  _productName = product.name;
                  _price = product.price;
                  _unit = product.unit ?? 'pcs';
                  _priceController.text = _price.toStringAsFixed(0);
                });
              }
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        suffixText: _unit,
                        hintText: '0',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (value) => setState(() => _quantity = double.tryParse(value) ?? 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Negotiated Price', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        hintText: '0',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (value) => setState(() => _price = double.tryParse(value) ?? 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ITEM SUBTOTAL', style: TextStyle(color: AppColors.textPlaceholder, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
              Text(
                NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(_price * _quantity),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _selectedProductId == null ? null : () {
              context.read<DealBloc>().add(AddDealItemSubmitted(
                dealId: widget.dealId,
                productId: _selectedProductId!,
                name: _productName,
                quantity: _quantity,
                price: _price,
                unit: _unit,
              ));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Save Item', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
