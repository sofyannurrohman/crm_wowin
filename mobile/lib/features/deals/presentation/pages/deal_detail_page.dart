import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/deal.dart';
import '../../domain/entities/deal_item.dart';
import '../../../products/domain/entities/product.dart';
import '../bloc/deal_bloc.dart';
import '../bloc/deal_event.dart';
import '../bloc/deal_state.dart';
import '../../../../core/router/route_constants.dart';

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
  void initState() {
    super.initState();
    context.read<DealBloc>().add(FetchDealDetail(widget.dealId));
  }

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
            if (state is DealLoading && state is! DealDetailLoaded) {
              return const Center(child: CircularProgressIndicator(color: _orange));
            } else if (state is DealDetailLoaded) {
              return _buildDealDetails(context, state.deal);
            } else if (state is DealError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<DealBloc>().add(FetchDealDetail(widget.dealId)),
                      child: const Text('Retry'),
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
          _buildHeader(deal),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMetricsGrid(deal),
                const SizedBox(height: 12),
                _buildDealItemsSection(context, deal),
                const SizedBox(height: 12),
                _buildCurrentStageCard(deal),
                const SizedBox(height: 12),
                _buildVisitSection(context, deal),
                const SizedBox(height: 12),
                _buildDealConfidenceCard(deal),
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

  Widget _buildCurrentStageCard(Deal deal) {
    return GestureDetector(
      onTap: () => _showStagePicker(context, deal),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _orange.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: _orange.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tahapan Penjualan',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _lightOrangeBg, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.edit3, color: _orange, size: 12),
                      const SizedBox(width: 4),
                      const Text('UBAH', style: TextStyle(color: _orange, fontSize: 10, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              deal.stage.toUpperCase(),
              style: const TextStyle(color: _orange, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 16),
            _buildStageProgress(deal.stage),
          ],
        ),
      ),
    );
  }

  Widget _buildStageProgress(String currentStage) {
    final stages = ['prospecting', 'qualification', 'proposal', 'negotiation', 'closed_won'];
    final currentIndex = stages.indexOf(currentStage.toLowerCase());
    
    return Row(
      children: List.generate(stages.length, (index) {
        final isActive = index <= currentIndex;
        final isLast = index == stages.length - 1;
        return Expanded(
          child: Row(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? _orange : Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              if (!isLast) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }

  void _showStagePicker(BuildContext context, Deal deal) {
    final stages = [
      {'id': 'prospecting', 'label': 'Prospecting', 'desc': 'Identifikasi awal peluang'},
      {'id': 'qualification', 'label': 'Qualification', 'desc': 'Validasi kebutuhan & budget'},
      {'id': 'proposal', 'label': 'Proposal', 'desc': 'Pengiriman penawaran resmi'},
      {'id': 'negotiation', 'label': 'Negotiation', 'desc': 'Diskusi harga & kontrak'},
      {'id': 'closed_won', 'label': 'Closed Won', 'desc': 'Deal berhasil ditutup'},
      {'id': 'closed_lost', 'label': 'Closed Lost', 'desc': 'Deal gagal/dibatalkan'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Tahapan Penjualan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            ...stages.map((s) {
              final isCurrent = s['id'] == deal.stage;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                title: Text(s['label']!, style: TextStyle(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600, color: isCurrent ? _orange : _textPrimary)),
                subtitle: Text(s['desc']!),
                trailing: isCurrent ? const Icon(LucideIcons.checkCircle2, color: _orange) : null,
                onTap: () {
                  context.read<DealBloc>().add(UpdateDealStageSubmitted(id: deal.id, stage: s['id']!));
                  context.pop();
                },
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitSection(BuildContext context, Deal deal) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kunjungan Lapangan',
                style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
              ),
              IconButton(
                icon: const Icon(LucideIcons.calendarPlus, color: _orange, size: 20),
                onPressed: () => _handleVisitAction(context, deal),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Verifikasi progres deal melalui kunjungan fisik atau meeting di lokasi pelanggan.',
            style: TextStyle(color: _textSecondary.withOpacity(0.8), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _handleVisitAction(context, deal),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _orange),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Buat Jadwal / Check-in', style: TextStyle(color: _orange, fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.calendar, color: _orange),
              title: const Text('Jadwalkan Kunjungan', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Atur waktu untuk meeting berikutnya'),
              onTap: () {
                context.pop();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(LucideIcons.mapPin, color: _orange),
              title: const Text('Check-in Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Mulai kunjungan ad-hoc saat ini juga'),
              onTap: () {
                context.pop();
                context.pushNamed(
                  'visit_check_in', 
                  extra: {
                    'scheduleId': 'adhoc',
                    'customerId': deal.customerId,
                    'customerName': deal.customer?.name ?? deal.title,
                    'customerAddress': deal.customer?.address ?? 'Alamat tidak tersedia',
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

  Widget _buildDealItemsSection(BuildContext context, Deal deal) {
    final items = deal.items ?? [];
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Produk & Layanan',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.plusCircle, color: _orange, size: 20),
                onPressed: () => _showAddProductDialog(context, deal),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.package, color: Colors.grey[300], size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada produk yang ditambahkan',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildDealItemTile(context, item, deal.id);
              },
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Nilai',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  currencyFormatter.format(deal.amount ?? 0),
                  style: const TextStyle(
                    color: _orange,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDealItemTile(BuildContext context, DealItem item, String dealId) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(LucideIcons.package, size: 20, color: _textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName ?? 'Produk ${item.productId.substring(0, 4)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.quantity} x ${currencyFormatter.format(item.unitPrice)}',
                style: const TextStyle(color: _textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormatter.format(item.subtotal),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                context.read<DealBloc>().add(RemoveDealItemSubmitted(item.id, dealId));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Hapus',
                  style: TextStyle(color: Colors.red[400], fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddProductDialog(BuildContext context, Deal deal) {
    // We'll navigate to product catalog and wait for result
    // But for a faster demo, I'll just show a "mock" add or simple selection
    // In real app: context.pushNamed(kRouteProducts, extra: {'isSelection': true})
    
    // Let's implement a simple dialog for now to show the feature works
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
  int _quantity = 1;
  double _price = 0;
  String _productName = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tambah Produk ke Deal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(LucideIcons.search),
            title: Text(_selectedProductId == null ? 'Pilih Produk' : _productName),
            trailing: const Icon(LucideIcons.chevronRight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            onTap: () async {
              final product = await context.pushNamed(
                kRouteProducts,
                extra: {'isSelectionMode': true},
              ) as Product?;
              
              if (product != null) {
                setState(() {
                  _selectedProductId = product.id;
                  _productName = product.name;
                  _price = product.price;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Jumlah', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.minusCircle),
                          onPressed: () => setState(() { if(_quantity > 1) _quantity--; }),
                        ),
                        Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(LucideIcons.plusCircle),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Harga Unit', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_price)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _selectedProductId == null ? null : () {
              context.read<DealBloc>().add(AddDealItemSubmitted(
                dealId: widget.dealId,
                productId: _selectedProductId!,
                quantity: _quantity,
                price: _price,
              ));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
