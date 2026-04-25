import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/deal.dart';
import '../bloc/deal_bloc.dart';
import '../bloc/deal_event.dart';
import '../bloc/deal_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart' as auth;
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../../../auth/presentation/bloc/auth_event.dart' as auth;
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/theme/app_colors.dart';

class DealKanbanPage extends StatefulWidget {
  const DealKanbanPage({super.key});

  @override
  State<DealKanbanPage> createState() => _DealKanbanPageState();
}

class _DealKanbanPageState extends State<DealKanbanPage> {
  List<Deal> _lastDeals = [];
  final List<String> _stages = [
    'prospect',
    'survey',
    'negotiation',
    'closing',
    'pre_order',
    'closed_won',
    'closed_lost'
  ];

  final Map<String, String> _stageLabels = {
    'prospect': 'PROSPECT',
    'survey': 'SURVEY',
    'negotiation': 'NEGOTIATION',
    'closing': 'CLOSING',
    'pre_order': 'PRE-ORDER',
    'closed_won': 'WON',
    'closed_lost': 'LOST',
  };

  final Map<String, Color> _stageColors = {
    'prospect': const Color(0xFF64748B),
    'survey': const Color(0xFF8B5CF6),
    'negotiation': const Color(0xFFF59E0B),
    'closing': const Color(0xFF10B981),
    'pre_order': const Color(0xFF6366F1),
    'closed_won': const Color(0xFF059669),
    'closed_lost': const Color(0xFFEF4444),
  };

  @override
  void initState() {
    super.initState();
    _refreshDeals();
  }

  void _refreshDeals() {
    final authState = context.read<auth.AuthBloc>().state;
    String? salesId;
    if (authState is auth.Authenticated && authState.user.role == 'sales') {
      salesId = authState.user.id;
    }
    
    context.read<DealBloc>().add(FetchDeals(salesId: salesId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSidebar(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DealBloc, DealState>(
            listener: (context, state) {
              if (state is DealOperationSuccess) {
                _refreshDeals();
              }
            },
          ),
        ],
        child: Column(
          children: [
            _buildPremiumHeader(),
            Expanded(
              child: BlocBuilder<DealBloc, DealState>(
                builder: (context, state) {
                  if (state is DealLoading && _lastDeals.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (state is DealsLoaded) {
                    _lastDeals = state.deals;
                    return _buildKanbanBoard(state.deals);
                  }

                  if (state is DealError && _lastDeals.isEmpty) {
                    return Center(child: Text(state.message));
                  }
                  
                  if (_lastDeals.isNotEmpty) {
                    return _buildKanbanBoard(_lastDeals);
                  }

                  return const Center(child: Text('No deals found'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
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
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Icon(LucideIcons.menu, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  const Column(
                    children: [
                      Text(
                        'Sales Pipeline',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Visual Board Management',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _refreshDeals,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.search, color: Colors.white60, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            'Search deals...',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.push('/deals/add'),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Icon(LucideIcons.plus, color: AppColors.primary, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKanbanBoard(List<Deal> deals) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      itemCount: _stages.length,
      separatorBuilder: (context, index) => const SizedBox(width: 20),
      itemBuilder: (context, index) {
        final stage = _stages[index];
        final stageDeals = deals.where((d) => d.stage == stage).toList();
        return _buildKanbanColumn(stage, stageDeals);
      },
    );
  }

  Widget _buildKanbanColumn(String stage, List<Deal> deals) {
    final double totalAmount = deals.fold(0, (sum, d) => sum + (d.amount ?? 0));
    final Color stageColor = _stageColors[stage] ?? Colors.grey;

    return DragTarget<Deal>(
      onAcceptWithDetails: (details) {
        final deal = details.data;
        if (deal.stage != stage) {
          context.read<DealBloc>().add(UpdateDealStageSubmitted(id: deal.id, stage: stage));
        }
      },
      builder: (context, candidateData, rejectedData) {
        final bool isColumnHovered = candidateData.isNotEmpty;

        return Container(
          width: 310,
          decoration: BoxDecoration(
            color: isColumnHovered ? stageColor.withOpacity(0.06) : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isColumnHovered ? stageColor.withOpacity(0.3) : const Color(0xFFF1F5F9), 
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: stageColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _stageLabels[stage]!,
                            style: TextStyle(color: stageColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            deals.length.toString(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(totalAmount)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'STAGED VOLUME',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPlaceholder, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              
              // Deal Cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: deals.length,
                  itemBuilder: (context, index) {
                    final deal = deals[index];
                    return _buildDealCard(deal);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDealCard(Deal deal) {
    final authState = context.read<auth.AuthBloc>().state;
    final currentUser = (authState is auth.Authenticated) ? authState.user : null;
    final bool isOwner = currentUser != null && (deal.salesId == currentUser.id);
    final bool isAdmin = currentUser?.role == 'admin';
    final bool isLocked = !isOwner && !isAdmin;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LongPressDraggable<Deal>(
        data: deal,
        maxSimultaneousDrags: isLocked ? 0 : 1,
        feedback: Material(
          color: Colors.transparent,
          child: _CardContent(deal: deal, isDragging: true, isLocked: isLocked),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: _CardContent(deal: deal, isLocked: isLocked)),
        child: GestureDetector(
          onTap: () => context.push('/deals/${deal.id}'),
          child: _CardContent(deal: deal, isLocked: isLocked),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final Deal deal;
  final bool isDragging;
  final bool isLocked;

  const _CardContent({required this.deal, this.isDragging = false, this.isLocked = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDragging ? 290 : double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  deal.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary, letterSpacing: -0.3),
                ),
              ),
              if (isLocked)
                const Icon(LucideIcons.lock, size: 14, color: AppColors.textPlaceholder)
              else
                const Icon(LucideIcons.moreHorizontal, size: 16, color: AppColors.textPlaceholder),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(LucideIcons.user, size: 12, color: AppColors.textPlaceholder),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  deal.customer?.name ?? 'Anonymous Client',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp${NumberFormat('#,###', 'id_ID').format(deal.amount ?? 0)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
              ),
              if (deal.probability != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${deal.probability}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ),
            ],
          ),
          if (deal.salesmanName != null && !isDragging) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.user, size: 10, color: AppColors.textPlaceholder),
                ),
                const SizedBox(width: 8),
                Text(deal.salesmanName!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
