import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../bloc/deal_bloc.dart';
import '../bloc/deal_event.dart';
import '../bloc/deal_state.dart';

class DealDetailPage extends StatefulWidget {
  final String dealId;

  const DealDetailPage({super.key, required this.dealId});

  @override
  State<DealDetailPage> createState() => _DealDetailPageState();
}

class _DealDetailPageState extends State<DealDetailPage> {
  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _lightOrangeBg = Color(0xFFFFF7ED);
  static const Color _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return BlocListener<DealBloc, DealState>(
      listener: (context, state) {
        if (state is DealOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: _green,
            ),
          );
        } else if (state is DealError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(context),
        body: BlocBuilder<DealBloc, DealState>(
          builder: (context, state) {
            if (state is DealLoading) {
              return const Center(child: CircularProgressIndicator(color: _orange));
            } else if (state is DealsLoaded) {
              final deal = state.deals.firstWhere(
                (d) => d.id == widget.dealId,
                orElse: () => throw Exception('Deal not found'),
              );
              return _buildDealDetails(context, deal);
            }
            return const Center(child: Text('Deal details unavailable'));
          },
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildDealDetails(BuildContext context, dynamic deal) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(deal),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMetricsGrid(deal),
                const SizedBox(height: 12),
                _buildCurrentStageCard(deal),
                const SizedBox(height: 12),
                _buildDealConfidenceCard(deal),
                const SizedBox(height: 16),
                _buildUpdateButton(context, deal),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildActivityTimeline(deal),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: _textPrimary),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: const Text(
        'Detail Penjualan',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.edit2, color: _textPrimary, size: 20),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: _textPrimary, size: 20),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeader(dynamic deal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _lightOrangeBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.briefcase, color: _orange, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deal.title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(LucideIcons.building2, size: 14, color: _orange),
                    const SizedBox(width: 4),
                    Text(
                      'Pelanggan: ${deal.customerId}',
                      style: TextStyle(color: _orange.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildBadge(deal.status.toUpperCase(), const Color(0xFFDC2626), const Color(0xFFFEE2E2)), // Red
                    const SizedBox(width: 8),
                    _buildBadge('SOFTWARE', const Color(0xFF4B5563), const Color(0xFFF3F4F6)), // Gray
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(dynamic deal) {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('Nilai Penjualan', '\$${deal.amount ?? 0}', LucideIcons.trendingUp, '10% dari rata-rata', true)),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard('Peluang', '${deal.probability ?? 0}%', LucideIcons.arrowUp, 'Sinyal kuat', true)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData trendIcon, String trendText, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _textSecondary.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(trendIcon, size: 12, color: isPositive ? _green : Colors.red),
              const SizedBox(width: 4),
              Text(
                trendText,
                style: TextStyle(
                  color: isPositive ? _green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStageCard(dynamic deal) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tahapan Saat Ini',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            deal.stage[0].toUpperCase() + deal.stage.substring(1),
            style: const TextStyle(
              color: _orange,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            deal.expectedClose != null ? 'Perkiraan tutup: \${deal.expectedClose.toLocal().toString().split(\' \')[0]}' : 'Tidak ada perkiraan waktu',
            style: TextStyle(
              color: _textSecondary.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealConfidenceCard(dynamic deal) {
    final probability = deal.probability ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.barChart, color: _orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Tingkat Kepercayaan',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '$probability%',
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: probability / 100.0,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(_orange),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            deal.description ?? 'Tidak ada deskripsi tersedia untuk penjualan ini.',
            style: TextStyle(
              color: _textSecondary.withOpacity(0.9),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context, dynamic deal) {
    return BlocBuilder<DealBloc, DealState>(
      builder: (context, state) {
        final isLoading = state is DealLoading;

        return ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  // Trigger stage update to next logical stage
                  final stages = ['lead', 'contacted', 'proposal', 'negotiation', 'won', 'lost'];
                  final currentIndex = stages.indexOf(deal.stage);
                  final nextStage = currentIndex != -1 && currentIndex < stages.length - 1 ? stages[currentIndex + 1] : deal.stage;
                  context.read<DealBloc>().add(UpdateDealStageSubmitted(id: widget.dealId, stage: nextStage));
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: _orange,
            disabledBackgroundColor: _orange.withOpacity(0.5),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            shadowColor: _orange.withOpacity(0.4),
          ),
          child: isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(LucideIcons.upload, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Perbarui Tahapan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildActivityTimeline(dynamic deal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Aktivitas',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          _buildTimelineItem(
            icon: LucideIcons.fileText,
            iconBg: const Color(0xFFFFF7ED),
            iconColor: _orange,
            title: 'Penjualan Dibuat',
            time: 'N/A',
            desc: deal.title,
            isLast: true,
          ),
        ],
      ),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade200,
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
                      Text(
                        title,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: _textSecondary.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(LucideIcons.briefcase, 'Penjualan', true), // Deals active
          _buildNavItem(LucideIcons.users, 'Kontak', false),
          _buildNavItem(LucideIcons.checkSquare, 'Tugas', false),
          _buildNavItem(LucideIcons.barChart2, 'Aktivitas', false),
          _buildNavItem(LucideIcons.settings, 'Pengaturan', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? _orange : const Color(0xFF9CA3AF), size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? _orange : const Color(0xFF9CA3AF),
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
