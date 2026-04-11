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
import '../../../../core/router/route_constants.dart';

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
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Kunjungan Berlangsung', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800)),
        automaticallyImplyLeading: false, // Force them to finish or handle exit via action
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Success Banner ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle, color: Colors.green),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Check-in Berhasil! Lokasi terverifikasi.',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2),

            const SizedBox(height: 24),

            // --- Timer Card ---
            Container(
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
            ).animate().fadeIn(delay: 200.ms).scale(),

            const SizedBox(height: 32),

            // --- Activity Section ---
            const Text('LAPORAN KEGIATAN', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF374151), fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 16),
            
            // Deal Toggle
            SwitchListTile(
              value: _selectedDealItems.isNotEmpty,
              onChanged: (v) {
                if (v) _showProductPicker();
                else setState(() => _selectedDealItems.clear());
              },
              title: const Text('Terdapat Deal / Pesanan?', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Aktifkan jika pelanggan melakukan pemesanan'),
              activeColor: _orange,
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
                      const Icon(LucideIcons.package, size: 16, color: _orange),
                      const SizedBox(width: 8),
                      Expanded(child: Text(it['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                      Text('Rp ${NumberFormat('#,###', 'id_ID').format(it['unit_price'])}'),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                        onPressed: () => setState(() => _selectedDealItems.removeAt(entry.key)),
                      )
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _showProductPicker,
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Tambah Produk Lain'),
                style: TextButton.styleFrom(foregroundColor: _orange),
              ),
            ],

            const SizedBox(height: 24),

            // Negotiation Notes
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

            // Submit Button
            ElevatedButton(
              onPressed: _submitActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: const Text('SELESAI & LANJUT CHECK-OUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
