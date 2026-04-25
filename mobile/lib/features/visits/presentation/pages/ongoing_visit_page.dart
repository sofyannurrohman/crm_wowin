import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
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
  String? _notaPhotoPath; // Local path to captured nota photo
  String? _selectedOutcome;
  bool _isSubmitting = false;
  Position? _currentPosition;
  
  final Map<String, String> _outcomeOptions = {
    'negotiation': 'Tahap Negosiasi',
    'deal_won': 'Tawaran Berhasil',
    'collection': 'Tagihan (Collection)',
    'deal_lost': 'Tawaran Ditolak',
    'follow_up': 'Perlu Follow Up',
  };

  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _elapsed = DateTime.now().difference(widget.checkInTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(widget.checkInTime);
        });
      }
    });
    // Restore active visit state if it was lost (e.g. background sync or refresh)
    final visitState = context.read<VisitBloc>().state;
    if (visitState is! VisitSuccess) {
      context.read<VisitBloc>().add(const RestoreActiveVisit());
    }
    // Pre-fetch products if we might need them
    context.read<ProductBloc>().add(const FetchProducts());
  }

  Future<void> _determinePosition() async {
    try {
      // 1. Try to get current position with a short timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // Medium is faster than High
        timeLimit: const Duration(seconds: 5),
      );
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    } catch (e) {
      debugPrint('OngoingVisitPage: Current location fetch failed/timed out: $e');
      // 2. Fallback to last known position if current fails
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null && mounted) {
          setState(() => _currentPosition = lastPosition);
        }
      } catch (lastError) {
        debugPrint('OngoingVisitPage: Last known location also failed: $lastError');
      }
    }
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

  void _submitCheckOut() async {
    if (_isSubmitting) return;

    if (_selectedOutcome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih hasil kunjungan (Hasil Akhir)'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_selectedOutcome == 'deal_won' && _notaPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wajib upload foto nota untuk hasil "Tawaran Berhasil"'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_currentPosition == null) {
      setState(() => _isSubmitting = true);
      await _determinePosition();
      setState(() => _isSubmitting = false);
      if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mendapatkan lokasi GPS. Pastikan GPS aktif.'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    context.read<VisitBloc>().add(
          CheckOutSubmitted(
            scheduleId: widget.scheduleId,
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            visitResult: _notesController.text,
            nextAction: '',
            nextVisitDate: '',
            taskDestinationId: widget.taskDestinationId,
            customerId: widget.customerId,
            leadId: widget.leadId,
            dealId: widget.dealId,
            dealItems: _selectedDealItems,
            outcome: _selectedOutcome,
            receiptPhotoFile: _notaPhotoPath != null ? XFile(_notaPhotoPath!) : null,
          ),
        );
  }

  void _submitActivity() async {
    // This is now replaced by _submitCheckOut logic directly on this page
    _submitCheckOut();
  }

  Future<void> _pickNotaPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (photo != null) {
      setState(() {
        _notaPhotoPath = photo.path;
      });
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
      body: BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          debugPrint('OngoingVisitPage: New state received: ${state.runtimeType}');
          if (state is VisitSuccess) {
            debugPrint('OngoingVisitPage: VisitSuccess message: ${state.message}');
            if (state.message.toLowerCase().contains('simpan') || 
                state.message.toLowerCase().contains('selesai')) {
              setState(() => _isSubmitting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              if (mounted) Navigator.of(context).pop(true);
            }
          } else if (state is VisitError) {
            debugPrint('OngoingVisitPage: VisitError: ${state.message}');
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<VisitBloc, VisitState>(
          builder: (context, visitState) {
            if (visitState is! VisitSuccess && visitState is! VisitLoading && visitState is! ActivitiesLoaded) {
            if (visitState is VisitError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertTriangle, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(visitState.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.read<VisitBloc>().add(const RestoreActiveVisit()),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
          
          final effectiveState = visitState is VisitSuccess 
              ? visitState 
              : VisitSuccess('Memuat data...', 
                  scheduleId: widget.scheduleId,
                  customerId: widget.customerId,
                  leadId: widget.leadId,
                  customerName: widget.customerName,
                  checkInTime: widget.checkInTime,
                  currentDealId: widget.dealId,
                  taskDestinationId: widget.taskDestinationId,
                );

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
                if (salesType == 'taskOrder' && effectiveState.invoices.isNotEmpty)
                  _buildCreditInfoCard(effectiveState.invoices),
                
                const SizedBox(height: 16),

                // --- Motoris Fast Entry ---
                if (salesType == 'motoris')
                  _buildMotorisFastEntry(),

                const SizedBox(height: 32),

                // --- Activity Section ---
                _buildActivitySection(salesType, effectiveState),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
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
        
        // --- HYBRID WORKFLOW: FOTO NOTA ---
        _buildNotaPhotoSection(),
        const SizedBox(height: 24),
        
        const Divider(),
        const SizedBox(height: 16),
        const Text('Opsi: Input Detail Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        
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
        const Text('Hasil Kunjungan (HASIL AKHIR)', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF374151), fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedOutcome,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
          ),
          hint: const Text('Pilih Hasil Kunjungan', style: TextStyle(fontSize: 14)),
          items: _outcomeOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedOutcome = value),
        ),

        const SizedBox(height: 24),
        const Text('Catatan Negosiasi / Diskusi (OPSIONAL)', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF374151), fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 12),
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
          onPressed: _isSubmitting ? null : _submitCheckOut,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedOutcome == 'deal_won' ? Colors.green : AppColors.primary,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
          child: _isSubmitting 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'SIMPAN & SELESAI KUNJUNGAN',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
              ),
        ),
      ],
    );
  }

  Widget _buildQuantityControl(int key, Map<String, dynamic> it) {
    return GestureDetector(
      onTap: () => _showNumpad(key, it),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              it['quantity'].toStringAsFixed(0),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.edit2, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showNumpad(int key, Map<String, dynamic> it) {
    String qtyInput = it['quantity'].toStringAsFixed(0);
    String priceInput = it['unit_price'].toStringAsFixed(0);
    bool isEditingPrice = false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String currentVal = isEditingPrice ? priceInput : qtyInput;

            void updateValue(String val) {
              setModalState(() {
                String newVal = currentVal;
                if (val == 'C') {
                  newVal = '0';
                } else if (val == 'DEL') {
                  if (newVal.length > 1) {
                    newVal = newVal.substring(0, newVal.length - 1);
                  } else {
                    newVal = '0';
                  }
                } else {
                  if (newVal == '0') {
                    newVal = val;
                  } else {
                    newVal += val;
                  }
                  // Limit max length
                  int maxLen = isEditingPrice ? 10 : 5;
                  if (newVal.length > maxLen) {
                    newVal = newVal.substring(0, maxLen);
                  }
                }
                
                if (isEditingPrice) {
                  priceInput = newVal;
                } else {
                  qtyInput = newVal;
                }
              });
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                top: 20, left: 20, right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    Text(it['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    
                    // Toggle Tabs
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isEditingPrice = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isEditingPrice ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: !isEditingPrice ? AppColors.primary : Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  const Text('JUMLAH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  Text(qtyInput, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: !isEditingPrice ? AppColors.primary : Colors.black87)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isEditingPrice = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isEditingPrice ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isEditingPrice ? AppColors.primary : Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  const Text('HARGA (PROMO)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  Text('Rp ${NumberFormat('#,###', 'id_ID').format(double.tryParse(priceInput) ?? 0)}', 
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isEditingPrice ? AppColors.primary : Colors.black87)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      childAspectRatio: 1.8,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (var i = 1; i <= 9; i++)
                          _buildNumpadBtn(i.toString(), () => updateValue(i.toString())),
                        _buildNumpadBtn('C', () => updateValue('C'), color: Colors.red.shade50),
                        _buildNumpadBtn('0', () => updateValue('0')),
                        _buildNumpadBtn('DEL', () => updateValue('DEL'), color: Colors.grey.shade100),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final double qty = double.tryParse(qtyInput) ?? 0;
                        final double price = double.tryParse(priceInput) ?? 0;
                        setState(() {
                          if (qty > 0) {
                            it['quantity'] = qty;
                            it['unit_price'] = price;
                            it['subtotal'] = qty * price;
                          } else {
                            _selectedDealItems.removeAt(key);
                          }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('SIMPAN PERUBAHAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNumpadBtn(String text, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: text == 'C' ? Colors.red : (text == 'DEL' ? Colors.grey.shade700 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotaPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_notaPhotoPath == null)
          GestureDetector(
            onTap: _takeNotaPhoto,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.blue.shade200, width: 2, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.camera, color: Colors.blue, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text('AMBIL FOTO NOTA FISIK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.blue)),
                  const SizedBox(height: 4),
                  Text('Bukti transaksi untuk diinput nanti', style: TextStyle(color: Colors.blue.shade700, fontSize: 13)),
                ],
              ),
            ),
          )
        else
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: kIsWeb 
                  ? Image.network(
                      _notaPhotoPath!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(_notaPhotoPath!),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () => setState(() => _notaPhotoPath = null),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Foto Nota Tersimpan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _takeNotaPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    
    if (image != null) {
      setState(() {
        _notaPhotoPath = image.path;
      });
    }
  }
}
