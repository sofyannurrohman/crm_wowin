import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_state.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../products/domain/entities/product.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../customers/domain/entities/invoice.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';

class OngoingVisitPage extends StatefulWidget {
  final String scheduleId;
  final String? customerId;
  final String? customerName;
  final String? leadId;
  final String? taskDestinationId;
  final DateTime checkInTime;
  final String? dealId;

  const OngoingVisitPage({
    super.key,
    required this.scheduleId,
    this.customerId,
    this.customerName,
    this.leadId,
    this.taskDestinationId,
    required this.checkInTime,
    this.dealId,
  });

  @override
  State<OngoingVisitPage> createState() => _OngoingVisitPageState();
}

class _OngoingVisitPageState extends State<OngoingVisitPage> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;
  final TextEditingController _notesController = TextEditingController();
  List<Map<String, dynamic>> _selectedDealItems = [];
  bool _isNegotiation = false;

  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.checkInTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(widget.checkInTime);
        });
      }
    });
    // Pre-fetch products if we might need them
    context.read<ProductBloc>().add(const FetchProducts());
  }

  @override
  void dispose() {
    _timer.cancel();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProductSheet(),
    );
  }

  Widget _buildProductSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Pilih Produk untuk Deal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) return const Center(child: CircularProgressIndicator());
                  if (state is ProductsLoaded) {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        final isSelected = _selectedDealItems.any((it) => it['product_id'] == product.id);
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(LucideIcons.package, color: Colors.blue, size: 20),
                          ),
                          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Rp ${NumberFormat('#,###', 'id_ID').format(product.price)}'),
                          trailing: Icon(
                            isSelected ? LucideIcons.checkCircle : LucideIcons.plusCircle,
                            color: isSelected ? Colors.green : Colors.grey,
                          ),
                          onTap: () {
                            if (!isSelected) {
                              setState(() {
                                _selectedDealItems.add({
                                  'product_id': product.id,
                                  'name': product.name,
                                  'quantity': 1.0,
                                  'unit': product.unit ?? 'pcs',
                                  'base_price': product.price,
                                  'unit_price': product.price,
                                  'subtotal': product.price,
                                  'discount': 0.0,
                                });
                              });
                            }
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Gagal memuat produk'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitActivity() async {
    // Navigate to Checkout, passing all collected data
    final result = await context.pushNamed(
      kRouteCheckOut,
      extra: {
        'scheduleId': widget.scheduleId,
        'customerId': widget.customerId,
        'leadId': widget.leadId,
        'customerName': widget.customerName,
        'taskDestinationId': widget.taskDestinationId,
        'dealId': widget.dealId,
        'dealItems': _selectedDealItems,
        'checkInTime': widget.checkInTime,
        'activitySubmitTime': DateTime.now(),
        'activityNotes': _notesController.text,
      },
    );

    // If checkout was successful (returned true), we also pop this page
    // to return to the Map optimized sequence (RoutePlannerPage)
    if (result == true && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kunjungan Berlangsung',
            style: TextStyle(
                color: Color(0xFF111827), fontWeight: FontWeight.w800)),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<VisitBloc, VisitState>(
        builder: (context, visitState) {
          if (visitState is! VisitSuccess) return const Center(child: CircularProgressIndicator());
          
          final authState = context.read<AuthBloc>().state;
          final salesType = authState is Authenticated ? authState.user.salesType : 'taskOrder';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSuccessBanner(),
                const SizedBox(height: 24),
                _buildTimerCard(),
                const SizedBox(height: 24),
                
                // --- Credit / AR Info (Task Order only) ---
                if (salesType == 'taskOrder' && visitState.invoices.isNotEmpty)
                  _buildCreditInfoCard(visitState.invoices),
                
                const SizedBox(height: 16),

                // --- Motoris Fast Entry ---
                if (salesType == 'motoris')
                  _buildMotorisFastEntry(),

                const SizedBox(height: 32),

                // --- Activity Section ---
                _buildActivitySection(salesType, visitState),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.checkCircle, color: Colors.green),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Check-in Berhasil! Lokasi terverifikasi.',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildTimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
           const Text(
            'DURASI KUNJUNGAN',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Text(
            _formatDuration(_elapsed),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: _orange, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          Text(
            'Pelanggan: ${widget.customerName ?? 'Tidak Diketahui'}',
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale();
  }

  Widget _buildCreditInfoCard(List<Invoice> invoices) {
    double totalOutstanding = 0;
    for (var inv in invoices) {
      totalOutstanding += (inv.amount - inv.paidAmount);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('INFORMASI KREDIT', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1.2)),
              const Icon(LucideIcons.creditCard, color: Colors.white54, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Piutang (AR)', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(totalOutstanding)}',
                      style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sisa Limit', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    const SizedBox(height: 4),
                    const Text(
                      'Rp 5.000.000', // Hardcoded limit for demo, should come from customer entity
                      style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          TextButton(
            onPressed: () => _showInvoiceDetails(invoices),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('LIHAT DETAIL INVOICE', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(width: 4),
                Icon(LucideIcons.chevronRight, color: Colors.blueAccent, size: 14),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  void _showInvoiceDetails(List<Invoice> invoices) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, controller) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Tagihan Belum Lunas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final inv = invoices[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(inv.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                'Jatuh Tempo: ${inv.dueAt != null ? DateFormat('dd MMM yyyy').format(inv.dueAt!) : '-'}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          Text(
                            'Rp ${NumberFormat('#,###', 'id_ID').format(inv.amount - inv.paidAmount)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotorisFastEntry() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is! ProductsLoaded) return const SizedBox.shrink();
        
        final fastProducts = state.products.take(6).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FAST ENTRY (POPULAR)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.primary, letterSpacing: 1)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fastProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final p = fastProducts[index];
                final isSelected = _selectedDealItems.any((it) => it['product_id'] == p.id);
                
                return GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      setState(() {
                        _selectedDealItems.add({
                          'product_id': p.id,
                          'name': p.name,
                          'quantity': 1.0,
                          'unit': p.unit ?? 'pcs',
                          'base_price': p.price,
                          'unit_price': p.price,
                          'subtotal': p.price,
                          'discount': 0.0,
                        });
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.package, color: isSelected ? Colors.blue : Colors.grey, size: 24),
                        const SizedBox(height: 8),
                        Text(
                          p.name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isSelected ? Colors.blue.shade900 : Colors.black87),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivitySection(String? salesType, VisitSuccess visitState) {
    final String dealLabel = salesType == 'taskOrder' ? 'PESANAN BARANG (SO)' : 'PENJUALAN LANGSUNG';
    final String dealSubtitle = salesType == 'taskOrder' 
      ? 'Pesan barang untuk dikirim nanti' 
      : 'Serahkan barang dan terima pembayaran sekarang';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('LAPORAN KEGIATAN', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF374151), fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 16),
        
        // Deal Toggle
        SwitchListTile(
          value: _selectedDealItems.isNotEmpty,
          onChanged: (v) {
            if (v) _showProductPicker();
            else setState(() => _selectedDealItems.clear());
          },
          title: Text(dealLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(dealSubtitle),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),

        if (_selectedDealItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._selectedDealItems.asMap().entries.map((entry) {
            final it = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  const Icon(LucideIcons.package, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(it['unit_price'])} / ${it['unit']}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _buildQuantityControl(entry.key, it),
                  const SizedBox(width: 8),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(it['subtotal'])}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1F2937), fontSize: 13),
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: _showProductPicker,
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Tambah Produk Lain'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],

        const SizedBox(height: 24),

        const Text('Catatan Negosiasi / Diskusi', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tuliskan hasil diskusi atau kendala di lapangan...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),

        const SizedBox(height: 48),

        ElevatedButton(
          onPressed: _submitActivity,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
          child: const Text('SELESAI & LANJUT CHECK-OUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildQuantityControl(int key, Map<String, dynamic> it) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.minusCircle, size: 18, color: Colors.grey),
            onPressed: () {
              setState(() {
                if (it['quantity'] > 1) {
                  it['quantity'] -= 1;
                  it['subtotal'] = it['quantity'] * it['unit_price'];
                } else {
                  _selectedDealItems.removeAt(key);
                }
              });
            },
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(it['quantity'].toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          IconButton(
            icon: const Icon(LucideIcons.plusCircle, size: 18, color: AppColors.primary),
            onPressed: () {
              setState(() {
                it['quantity'] += 1;
                it['subtotal'] = it['quantity'] * it['unit_price'];
              });
            },
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }
}
