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

class DealKanbanPage extends StatefulWidget {
  const DealKanbanPage({super.key});

  @override
  State<DealKanbanPage> createState() => _DealKanbanPageState();
}

class _DealKanbanPageState extends State<DealKanbanPage> {
  final List<String> _stages = [
    'prospect',
    'survey',
    'negotiation',
    'closing',
    'closed_won',
    'closed_lost'
  ];

  final Map<String, String> _stageLabels = {
    'prospect': 'PROSPECT',
    'survey': 'SURVEY',
    'negotiation': 'NEGOTIATION',
    'closing': 'CLOSING',
    'closed_won': 'WON',
    'closed_lost': 'LOST',
  };

  final Map<String, Color> _stageColors = {
    'prospect': const Color(0xFF3B82F6),
    'survey': const Color(0xFF8B5CF6),
    'negotiation': const Color(0xFFF59E0B),
    'closing': const Color(0xFF10B981),
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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Deal Kanban Pipeline', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF111827))),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: _refreshDeals,
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/deals/add'),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Add Deal', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8622A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
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
        child: BlocBuilder<DealBloc, DealState>(
          builder: (context, state) {
            if (state is DealLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFE8622A)));
            }

            if (state is DealsLoaded) {
              return _buildKanbanBoard(state.deals);
            }

            if (state is DealError) {
              return Center(child: Text(state.message));
            }

            return const Center(child: Text('No deals found'));
          },
        ),
      ),
    );
  }

  Widget _buildKanbanBoard(List<Deal> deals) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      itemCount: _stages.length,
      separatorBuilder: (context, index) => const SizedBox(width: 16),
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
          width: 300,
          decoration: BoxDecoration(
            color: isColumnHovered ? stageColor.withOpacity(0.05) : const Color(0xFFF3F4F6).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isColumnHovered ? stageColor.withOpacity(0.2) : Colors.transparent, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: stageColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            _stageLabels[stage]!,
                            style: TextStyle(color: stageColor, fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Text(deals.length.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(totalAmount)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Deal Cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
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
        childWhenDragging: Opacity(opacity: 0.3, child: _CardContent(deal: deal, isLocked: isLocked)),
        child: InkWell(
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
      width: isDragging ? 280 : double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  deal.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827)),
                ),
              ),
              if (isLocked)
                const Icon(LucideIcons.lock, size: 14, color: Colors.grey)
              else
                const Icon(LucideIcons.moreHorizontal, size: 14, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.user, size: 12, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  deal.customer?.name ?? 'Unknown Customer',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format(deal.amount ?? 0)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFE8622A)),
              ),
              if (deal.probability != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFE8622A).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('${deal.probability}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFE8622A))),
                ),
            ],
          ),
          if (deal.salesmanName != null && !isDragging) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(radius: 8, backgroundColor: Colors.grey[200], child: const Icon(LucideIcons.user, size: 8, color: Colors.grey)),
                const SizedBox(width: 6),
                Text(deal.salesmanName!, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
