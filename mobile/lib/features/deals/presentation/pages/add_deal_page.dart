import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/deal.dart';
import '../bloc/deal_bloc.dart';
import '../bloc/deal_event.dart';
import '../bloc/deal_state.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart' as auth;
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../../../auth/presentation/bloc/auth_event.dart' as auth;
import '../../../auth/domain/entities/user_entity.dart' as user_ent;
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/deal_item.dart';

class AddDealPage extends StatefulWidget {
  final Deal? initialDeal;
  final String? initialCustomerId;
  final String? initialCustomerName;

  const AddDealPage({
    super.key, 
    this.initialDeal,
    this.initialCustomerId,
    this.initialCustomerName,
  });

  @override
  State<AddDealPage> createState() => _AddDealPageState();
}

class _AddDealPageState extends State<AddDealPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _probabilityController;
  late TextEditingController _descriptionController;
  late TextEditingController _expectedCloseController;
  
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  String _selectedStage = 'prospect';
  DateTime? _expectedCloseDate;
  List<DealItem> _items = [];
  String? _submittedDealId;
  
  String? _selectedSalesmanId;
  List<user_ent.UserEntity> _salesmen = [];

  final List<String> _stages = [
    'prospect',
    'survey',
    'negotiation',
    'closing',
    'closed_won',
    'closed_lost'
  ];

  @override
  void initState() {
    super.initState();
    final deal = widget.initialDeal;
    _titleController = TextEditingController(text: deal?.title ?? '');
    _amountController = TextEditingController(text: deal?.amount?.toString() ?? '');
    _probabilityController = TextEditingController(text: deal?.probability?.toString() ?? '20');
    _descriptionController = TextEditingController(text: deal?.description ?? '');
    _expectedCloseDate = deal?.expectedClose;
    _expectedCloseController = TextEditingController(
      text: _expectedCloseDate != null ? DateFormat('yyyy-MM-dd').format(_expectedCloseDate!) : '',
    );
    _selectedCustomerId = deal?.customerId ?? widget.initialCustomerId;
    _selectedCustomerName = deal?.customer?.name ?? widget.initialCustomerName;
    _selectedStage = deal?.stage ?? 'prospect';
    _items = deal?.items ?? [];
    _selectedSalesmanId = deal?.salesId;
    
    // Fetch products for the picker
    context.read<ProductBloc>().add(const FetchProducts());

    // Fetch salesmen if admin
    // Fetch salesmen if admin
    final authState = context.read<auth.AuthBloc>().state;
    if (authState is auth.Authenticated && authState.user.role == 'admin') {
      context.read<auth.AuthBloc>().add(auth.FetchSalesmen());
    } else if (authState is auth.Authenticated) {
      _selectedSalesmanId ??= authState.user.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _probabilityController.dispose();
    _descriptionController.dispose();
    _expectedCloseController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expectedCloseDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );

    if (pickedDate != null) {
      setState(() {
        _expectedCloseDate = pickedDate;
        _expectedCloseController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _calculateTotal() {
    double total = 0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    setState(() {
      _amountController.text = total.toStringAsFixed(0);
    });
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Tambah Produk dari Katalog', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProductsLoaded) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D8549).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(LucideIcons.package, color: Color(0xFF0D8549)),
                            ),
                            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${product.unit ?? 'Pcs'} • Rp ${NumberFormat('#,###', 'id_ID').format(product.price)}'),
                            trailing: const Icon(LucideIcons.plusCircle, color: Color(0xFFE8622A)),
                            onTap: () {
                              Navigator.pop(context);
                              _showQuantityDialog(product);
                            },
                          );
                        },
                      );
                    }
                    return const Center(child: Text('Gagal memuat katalog produk'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuantityDialog(Product product) {
    final qtyController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Input Jumlah: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Jumlah (${product.unit ?? 'Pcs'})',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text) ?? 0;
              if (qty > 0) {
                setState(() {
                  _items.add(DealItem(
                    id: const Uuid().v4(),
                    dealId: widget.initialDeal?.id ?? '',
                    productId: product.id,
                    name: product.name,
                    quantity: qty,
                    unitPrice: product.price,
                    discount: 0,
                    subtotal: qty * product.price,
                    unit: product.unit ?? 'Pcs',
                  ));
                });
                _calculateTotal();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8622A)),
            child: const Text('Tambah', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCustomerPicker() {
    context.read<CustomerBloc>().add(FetchCustomers());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Pilih Pelanggan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: BlocBuilder<CustomerBloc, CustomerState>(
                  builder: (context, state) {
                    if (state is CustomerLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CustomersLoaded) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: state.customers.length,
                        itemBuilder: (context, index) {
                          final customer = state.customers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE8622A).withOpacity(0.1),
                              child: Text(customer.name[0], style: const TextStyle(color: Color(0xFFE8622A))),
                            ),
                            title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(customer.companyName ?? customer.industry ?? 'General'),
                            onTap: () {
                              setState(() {
                                _selectedCustomerId = customer.id;
                                _selectedCustomerName = customer.name;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    }
                    return const Center(child: Text('Gagal memuat pelanggan'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCustomerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih pelanggan terlebih dahulu'), backgroundColor: Colors.red),
        );
        return;
      }

      final deal = Deal(
        id: widget.initialDeal?.id ?? const Uuid().v4(),
        title: _titleController.text,
        customerId: _selectedCustomerId!,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        stage: _selectedStage,
        probability: int.tryParse(_probabilityController.text) ?? 20,
        expectedClose: _expectedCloseDate,
        description: _descriptionController.text,
        status: 'open',
        items: _items,
        salesId: _selectedSalesmanId,
      );
      
      _submittedDealId = deal.id;

      if (widget.initialDeal == null) {
        context.read<DealBloc>().add(CreateDealSubmitted(deal));
      } else {
        context.read<DealBloc>().add(UpdateDealSubmitted(deal));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialDeal != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Data Deal' : 'Tambah Deal Baru', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<auth.AuthBloc, auth.AuthState>(
        listener: (context, state) {
          if (state is auth.SalesmenLoaded) {
            setState(() {
              _salesmen = state.salesmen;
            });
          }
        },
        child: BlocListener<DealBloc, DealState>(
          listener: (context, state) {
            if (state is DealOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              context.pop(_submittedDealId); // Return the deal ID to the caller
            } else if (state is DealError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   BlocBuilder<auth.AuthBloc, auth.AuthState>(
                    builder: (context, authState) {
                       if (authState is auth.Authenticated && authState.user.role == 'admin') {
                         return Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             _buildSectionHeader('Assignment (Admin Only)', LucideIcons.userCheck),
                             const SizedBox(height: 16),
                             _buildSalesmanDropdown(),
                             const SizedBox(height: 32),
                           ],
                         );
                       }
                       return const SizedBox.shrink();
                    },
                  ),
                  _buildSectionHeader('Informasi Dasar', LucideIcons.briefcase),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _titleController,
                  label: 'Judul Deal / Peluang',
                  hint: 'Contoh: Pengadaan Kursi Kantor PT ABC',
                  icon: LucideIcons.type,
                  validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildPickerField(
                  label: 'Pelanggan',
                  value: _selectedCustomerName ?? 'Pilih Pelanggan',
                  icon: LucideIcons.users,
                  onTap: _showCustomerPicker,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Detail Finansial & Progres', LucideIcons.trendingUp),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _amountController,
                        label: 'Nilai Deal (Auto-calculated)',
                        hint: 'Rp 0',
                        icon: LucideIcons.dollarSign,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _probabilityController,
                        label: 'Probabilitas (%)',
                        hint: '0-100',
                        icon: LucideIcons.percent,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final p = int.tryParse(v ?? '');
                          if (p == null || p < 0 || p > 100) return '0-100';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Produk & Item', LucideIcons.package),
                const SizedBox(height: 16),
                _buildItemsList(),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _showProductPicker,
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Tambah Produk dari Katalog'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE8622A),
                    side: const BorderSide(color: Color(0xFFE8622A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStage,
                  decoration: InputDecoration(
                    labelText: 'Tahapan Pipeline',
                    prefixIcon: const Icon(LucideIcons.gitCommit, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _stages.map((s) => DropdownMenuItem(
                    value: s, 
                    child: Text(s.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedStage = v!),
                ),
                const SizedBox(height: 16),
                _buildPickerField(
                  label: 'Estimasi Tanggal Closing',
                  value: _expectedCloseController.text.isEmpty ? 'Pilih Tanggal' : _expectedCloseController.text,
                  icon: LucideIcons.calendar,
                  onTap: _presentDatePicker,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Deskripsi & Catatan', LucideIcons.fileText),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Deskripsi Peluang',
                  hint: 'Tambahkan detail penawaran atau kebutuhan pelanggan...',
                  icon: LucideIcons.alignLeft,
                  maxLines: 4,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: BlocBuilder<DealBloc, DealState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is DealLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8622A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: state is DealLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isEdit ? 'Simpan Perubahan' : 'Buat Deal Baru',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE8622A)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Color(0xFF8E8E93),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFFE8622A)),
                const SizedBox(width: 12),
                Text(value, style: TextStyle(
                  fontSize: 16, 
                  color: value.contains('Pilih') ? Colors.grey : Colors.black,
                  fontWeight: value.contains('Pilih') ? FontWeight.normal : FontWeight.bold
                )),
                const Spacer(),
                const Icon(LucideIcons.chevronDown, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8622A), width: 2),
        ),
        fillColor: readOnly ? Colors.grey.shade50 : null,
        filled: readOnly,
      ),
    );
  }

  Widget _buildItemsList() {
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Text('Belum ada item dipilih', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: _items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${item.quantity} ${item.unit} x Rp ${NumberFormat('#,###', 'id_ID').format(item.price)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(item.price * item.quantity)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1A237E)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      _items.removeAt(index);
                    });
                    _calculateTotal();
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSalesmanDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assigned Salesman', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4B5563))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSalesmanId,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(LucideIcons.user, size: 18),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8622A), width: 2),
            ),
          ),
          hint: const Text('Assign to Salesman'),
          items: _salesmen.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
          onChanged: (v) {
            setState(() {
              _selectedSalesmanId = v;
            });
          },
          validator: (v) => v == null ? 'Please assign a salesman' : null,
        ),
      ],
    );
  }
}
