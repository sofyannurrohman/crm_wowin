import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../../domain/entities/stock_transfer.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/theme/app_colors.dart';

class InventoryTransferPage extends StatefulWidget {
  const InventoryTransferPage({super.key});

  @override
  State<InventoryTransferPage> createState() => _InventoryTransferPageState();
}

class _InventoryTransferPageState extends State<InventoryTransferPage> {
  StockTransferType _transferType = StockTransferType.loading;
  final List<Map<String, dynamic>> _selectedItems = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(const FetchTransfers());
  }

  void _addItem(String productId, String name, String unit) {
    setState(() {
      _selectedItems.add({
        'product_id': productId,
        'name': name,
        'unit': unit,
        'quantity': 1.0,
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  void _submit() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu produk')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    final salesId = authState is Authenticated ? authState.user.id : '';
    
    // Use the user's default warehouse if available, or a fallback
    final warehouseId = '';

    final transfer = StockTransfer(
      id: '', // Backend will generate
      warehouseId: warehouseId,
      salesId: salesId,
      type: _transferType,
      status: StockTransferStatus.pending,
      notes: _notesController.text,
      items: _selectedItems.map((e) => StockTransferItem(
        id: '',
        transferId: '',
        productId: e['product_id'],
        quantity: e['quantity'],
      )).toList(),
    );

    context.read<InventoryBloc>().add(SubmitStockTransfer(transfer));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manajemen Stok Van', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocListener<InventoryBloc, InventoryState>(
        listener: (context, state) {
          state.maybeWhen(
            success: (_, __, message) {
              if (message != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                setState(() {
                   _selectedItems.clear();
                   _notesController.clear();
                });
              }
            },
            error: (msg) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
            },
            orElse: () {},
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelector(),
              const SizedBox(height: 24),
              _buildProductList(),
              const SizedBox(height: 24),
              _buildNotesField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 32),
              _buildHistoryHeader(),
              const SizedBox(height: 16),
              _buildTransferHistory(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showProductPicker,
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _transferType = StockTransferType.loading),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _transferType == StockTransferType.loading ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'LOADING',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _transferType == StockTransferType.loading ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _transferType = StockTransferType.unloading),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _transferType == StockTransferType.unloading ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'UNLOADING',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _transferType == StockTransferType.unloading ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PRODUK DIPILIH', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        if (_selectedItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Column(
              children: [
                Icon(LucideIcons.package, size: 40, color: Colors.grey),
                SizedBox(height: 12),
                Text('Belum ada produk dipilih', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        else
          ..._selectedItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Satuan: ${item['unit']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (item['quantity'] > 1) item['quantity']--;
                          });
                        },
                        icon: const Icon(LucideIcons.minusCircle, size: 20),
                      ),
                      Text(item['quantity'].toInt().toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            item['quantity']++;
                          });
                        },
                        icon: const Icon(LucideIcons.plusCircle, size: 20),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _removeItem(index),
                    icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CATATAN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tambahkan alasan atau detail transfer...',
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
          return ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('AJUKAN TRANSFER SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return const Row(
      children: [
        Icon(LucideIcons.history, size: 20, color: Colors.grey),
        SizedBox(width: 8),
        Text('RIWAYAT TRANSFER TERAKHIR', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTransferHistory() {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        return state.maybeWhen(
          success: (_, transfers, __) {
            if (transfers.isEmpty) {
              return const Center(child: Text('Belum ada riwayat transfer', style: TextStyle(color: Colors.grey)));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final st = transfers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: st.type == StockTransferType.loading ? Colors.blue.shade50 : Colors.orange.shade50,
                        child: Icon(
                          st.type == StockTransferType.loading ? LucideIcons.arrowUpFromLine : LucideIcons.arrowDownToLine,
                          color: st.type == StockTransferType.loading ? Colors.blue : Colors.orange,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              st.type == StockTransferType.loading ? 'Loading Barang' : 'Unloading Barang',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(st.createdAt ?? DateTime.now()),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(st.status),
                    ],
                  ),
                );
              },
            );
          },
          orElse: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildStatusChip(StockTransferStatus status) {
    Color color;
    String label;
    switch (status) {
      case StockTransferStatus.pending:
        color = Colors.orange;
        label = 'PENDING';
        break;
      case StockTransferStatus.confirmed:
        color = Colors.green;
        label = 'CONFIRMED';
        break;
      case StockTransferStatus.rejected:
        color = Colors.red;
        label = 'REJECTED';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Pilih Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        return state is ProductsLoaded
                            ? ListView.builder(
                                controller: controller,
                                itemCount: state.products.length,
                                itemBuilder: (context, index) {
                                  final p = state.products[index];
                                  return ListTile(
                                    leading: const Icon(LucideIcons.package),
                                    title: Text(p.name),
                                    subtitle: Text(p.unit ?? 'Pcs'),
                                    trailing: Icon(LucideIcons.plus, color: AppColors.primary),
                                    onTap: () {
                                      _addItem(p.id, p.name, p.unit ?? 'Pcs');
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              )
                            : const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
