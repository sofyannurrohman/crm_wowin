import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:wowin_crm/l10n/app_localizations.dart';

import '../bloc/deal_bloc.dart';
import '../bloc/deal_event.dart';
import '../bloc/deal_state.dart';
import '../../domain/entities/deal.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_sidebar.dart';

class DealKanbanPage extends StatefulWidget {
  const DealKanbanPage({super.key});

  @override
  State<DealKanbanPage> createState() => _DealKanbanPageState();
}

class _DealKanbanPageState extends State<DealKanbanPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _stages = [
    'prospecting',
    'qualification',
    'negotiation',
    'proposal',
  ];

  static const Color _orange = Color(0xFFE8622A);
  static const Color _navy = Color(0xFF1A237E);
  static const Color _bg = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _stages.length, vsync: this);
    context.read<DealBloc>().add(FetchDeals());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppSidebar(),
      floatingActionButton: _buildFab(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: BlocBuilder<DealBloc, DealState>(
                builder: (context, state) {
                  if (state is DealLoading) {
                    return const Center(child: CircularProgressIndicator(color: _orange));
                  } else if (state is DealsLoaded) {
                    return TabBarView(
                      controller: _tabController,
                      children: _stages.map((stage) {
                        final stageDeals = state.deals.where((d) => d.stage == stage).toList();
                        return _buildStageContent(stageDeals);
                      }).toList(),
                    );
                  } else if (state is DealError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.menu, color: _orange, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales Pipeline',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  'Q3 Revenue Forecast',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.search, color: Color(0xFF4B5563)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: _orange,
      indicatorWeight: 3,
      labelColor: _orange,
      unselectedLabelColor: Colors.grey.shade500,
      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      tabs: const [
        Tab(text: 'PROSPECTING'),
        Tab(text: 'QUALIFICATION'),
        Tab(text: 'NEGOTIATION'),
        Tab(text: 'PROPOSAL'),
      ],
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          Text('($count)', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStageContent(List<Deal> deals) {
    double totalValue = deals.fold(0, (sum, item) => sum + (item.amount ?? 0));
    double weightedValue = deals.fold(0, (sum, item) => sum + ((item.amount ?? 0) * (item.probability ?? 0) / 100));

    return RefreshIndicator(
      color: _orange,
      onRefresh: () async => context.read<DealBloc>().add(FetchDeals()),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(totalValue, weightedValue),
          const SizedBox(height: 20),
          ...deals.map((deal) => _DealCard(deal: deal)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double total, double weighted) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '${AppLocalizations.of(context)!.currencySymbol} ',
      decimalDigits: 0,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL PIPELINE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  fmt.format(total),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _orange),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade100),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WEIGHTED VALUE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  fmt.format(weighted),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _navy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () async {
        final result = await context.pushNamed(kRouteAddDeal);
        if (result == true) {
          if (mounted) {
            context.read<DealBloc>().add(FetchDeals());
          }
        }
      },
      backgroundColor: _orange,
      child: const Icon(LucideIcons.plus, color: Colors.white),
    );
  }
}

class _DealCard extends StatelessWidget {
  final Deal deal;
  const _DealCard({required this.deal});

  static const Color _orange = Color(0xFFE8622A);
  static const Color _navy = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '${AppLocalizations.of(context)!.currencySymbol} ',
      decimalDigits: 0,
    );
    final bool isOverdue = deal.expectedClose != null && deal.expectedClose!.isBefore(DateTime.now());
    final bool isFollowUp = deal.probability != null && deal.probability! < 50; 

    Color accentColor = isOverdue ? const Color(0xFFEF4444) : (isFollowUp ? const Color(0xFF10B981) : _navy);
    String badgeText = isOverdue ? "! TERLAMBAT" : (isFollowUp ? "FOLLOW-UP HARI INI" : "DIPERBARUI 2J LALU");
    Color badgeBg = isOverdue ? const Color(0xFFFEE2E2) : (isFollowUp ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6));
    Color badgeTextCol = isOverdue ? const Color(0xFFB91C1C) : (isFollowUp ? const Color(0xFF047857) : const Color(0xFF4B5563));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: GestureDetector(
        onTap: () => context.pushNamed(
          kRouteDealDetail,
          pathParameters: {'id': deal.id},
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              badgeText,
                              style: TextStyle(color: badgeTextCol, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ),
                          const Icon(LucideIcons.moreHorizontal, color: Color(0xFF9CA3AF), size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        deal.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                            child: const Icon(LucideIcons.building2, size: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Client Corporation',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fmt.format(deal.amount ?? 0),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${deal.probability ?? 0}% Probability',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => context.pushNamed(
                              kRouteDealDetail,
                              pathParameters: {'id': deal.id},
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isOverdue ? _orange : const Color(0xFFF1F5F9),
                              foregroundColor: isOverdue ? Colors.white : const Color(0xFF1A1A1A),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Details', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
