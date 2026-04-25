import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/visit_activity.dart';

class FinalizeVisitPage extends StatefulWidget {
  final VisitActivity activity;

  const FinalizeVisitPage({super.key, required this.activity});

  @override
  State<FinalizeVisitPage> createState() => _FinalizeVisitPageState();
}

class _FinalizeVisitPageState extends State<FinalizeVisitPage> {
  final List<Map<String, dynamic>> _selectedItems = [];
  final TextEditingController _notesController = TextEditingController();
  String _selectedOutcome = 'deal_won';
  
  // Base URL for images
  static const String _baseUrl = 'http://localhost:8080'; // Change to real IP later

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const FetchProducts());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    return _selectedItems.fold(0, (sum, it) => sum + (it['subtotal'] as double));
  }

  void _submit() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 item!')),
      );
      return;
    }

    context.read<VisitBloc>().add(FinalizeVisitSubmitted(
      activityId: widget.activity.id,
      items: _selectedItems,
      outcome: _selectedOutcome,
      notes: _notesController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for photo viewing
      appBar: AppBar(
        title: Text('Finalisasi: ${widget.activity.customerName ?? 'Kunjungan'}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Berhasil difinalisasi!'), backgroundColor: Colors.green),
            );
            context.pop(true);
          } else if (state is VisitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Column(
          children: [
            // Top: Photo Viewer
            Expanded(
              flex: 2,
              child: _buildPhotoViewer(),
            ),
            
            // Bottom: Input Form
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: _buildInputSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoViewer() {
    final String photoUrl = widget.activity.notaPhotoPath != null 
        ? '$_baseUrl${widget.activity.notaPhotoPath}' 
        : '';

    return Stack(
      children: [
        if (photoUrl.isNotEmpty)
          InteractiveViewer(
            child: Center(
              child: Image.network(
                photoUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
                errorBuilder: (context, error, stack) => const Icon(LucideIcons.imageOff, color: Colors.white, size: 48),
              ),
            ),
          )
        else
          const Center(child: Text('Foto tidak tersedia', style: TextStyle(color: Colors.white))),
        
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(LucideIcons.zoomIn, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('Cubit untuk zoom', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        // Tab Header / Summary
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('INPUT DETAIL ITEM', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('Gunakan foto di atas sebagai referensi', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(_calculateTotal())}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              // List of added items
              ..._selectedItems.asMap().entries.map((entry) => _buildItemTile(entry.key, entry.value)),
              
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _showProductPicker,
                icon: const Icon(LucideIcons.plus),
                label: const Text('TAMBAH ITEM BARU'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              
              const SizedBox(height: 24),
              const Text('Catatan Tambahan', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Misal: Promo bundle, Retur, dll',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 100), // Space for fab
            ],
          ),
        ),
        
        // Final Action
        Padding(
          padding: const EdgeInsets.all(24),
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: AppColors.primary.withOpacity(0.4),
            ),
            child: const Text('SIMPAN & FINALISASI DATA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildItemTile(int index, Map<String, dynamic> it) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${it['quantity']} ${it['unit']} x Rp ${NumberFormat('#,###').format(it['unit_price'])}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Text(
            'Rp ${NumberFormat('#,###').format(it['subtotal'])}',
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
            onPressed: () => setState(() => _selectedItems.removeAt(index)),
          ),
        ],
      ),
    );
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Pilih Produk', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                        return ListTile(
                          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Rp ${NumberFormat('#,###').format(product.price)}'),
                          trailing: const Icon(LucideIcons.plusCircle, color: AppColors.primary),
                          onTap: () {
                            _addOrUpdateItem(product);
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

  void _addOrUpdateItem(dynamic product) {
    setState(() {
      _selectedItems.add({
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
}
