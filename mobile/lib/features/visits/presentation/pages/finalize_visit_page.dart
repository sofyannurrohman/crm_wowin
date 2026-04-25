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
import '../../../../core/api/api_endpoints.dart';

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
  
  static const String _baseUrl = ApiEndpoints.uploadsBaseUrl; 

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
        const SnackBar(content: Text('Please add at least one item.'), backgroundColor: Color(0xFFF59E0B), behavior: SnackBarBehavior.floating),
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
      backgroundColor: Colors.black, 
      appBar: AppBar(
        title: Text('Finalize: ${widget.activity.customerName ?? 'Visit'}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary)),
      ),
      body: BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Visit finalized successfully.'), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating),
            );
            context.pop(true);
          } else if (state is VisitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating),
            );
          }
        },
        child: Column(
          children: [
            Expanded(flex: 2, child: _buildPhotoViewer()),
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
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
                errorBuilder: (context, error, stack) => const Icon(LucideIcons.imageOff, color: Colors.white24, size: 48),
              ),
            ),
          )
        else
          const Center(child: Text('Receipt image not available', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600))),
        
        Positioned(
          bottom: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(LucideIcons.zoomIn, color: Colors.white, size: 14),
                SizedBox(width: 8),
                Text('Pinch to zoom', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ITEM ENTRY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 10, color: AppColors.textPlaceholder)),
                    SizedBox(height: 4),
                    Text('Refer to the receipt above', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
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
              ..._selectedItems.asMap().entries.map((entry) => _buildItemTile(entry.key, entry.value).animate().fadeIn().slideX()),
              
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _showProductPicker,
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('ADD TRANSACTION ITEM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 60),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              
              const SizedBox(height: 32),
              const Text('REMARKS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.textPlaceholder, letterSpacing: 1)),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g., Promo bundle, partial return...',
                  hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('FINALIZE VISIT DATA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.3)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(LucideIcons.package, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary)),
                Text('${it['quantity'].toStringAsFixed(0)} ${it['unit']} x Rp ${NumberFormat('#,###').format(it['unit_price'])}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${NumberFormat('#,###').format(it['subtotal'])}',
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 14),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedItems.removeAt(index)),
                child: const Text('REMOVE', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
              ),
            ],
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Select Products', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            ),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  if (state is ProductsLoaded) {
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      itemCount: state.products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return GestureDetector(
                          onTap: () {
                            _addOrUpdateItem(product);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(LucideIcons.package, color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                                      Text('Rp ${NumberFormat('#,###', 'id_ID').format(product.price)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                const Icon(LucideIcons.plusCircle, color: Color(0xFFCBD5E1), size: 22),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Failed to load products'));
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
