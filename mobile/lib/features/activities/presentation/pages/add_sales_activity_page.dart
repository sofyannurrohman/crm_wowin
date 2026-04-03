import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/sales_activity.dart';
import '../bloc/sales_activity_bloc.dart';
import '../bloc/sales_activity_event.dart';
import '../bloc/sales_activity_state.dart';
import '../../../leads/presentation/bloc/lead_bloc.dart';
import '../../../leads/presentation/bloc/lead_event.dart';
import '../../../leads/presentation/bloc/lead_state.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../deals/presentation/bloc/deal_bloc.dart';
import '../../../deals/presentation/bloc/deal_event.dart';
import '../../../deals/presentation/bloc/deal_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AddSalesActivityPage extends StatefulWidget {
  final SalesActivity? initialActivity;

  const AddSalesActivityPage({super.key, this.initialActivity});

  @override
  State<AddSalesActivityPage> createState() => _AddSalesActivityPageState();
}

class _AddSalesActivityPageState extends State<AddSalesActivityPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;

  String _selectedType = 'visit';
  String? _selectedLeadId;
  String? _selectedLeadName;
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  String? _selectedDealId;
  String? _selectedDealTitle;

  final List<Map<String, dynamic>> _types = [
    {'value': 'visit', 'label': 'Kunjungan', 'icon': LucideIcons.mapPin},
    {'value': 'negotiation', 'label': 'Negosiasi', 'icon': LucideIcons.messageSquare},
    {'value': 'deal', 'label': 'Deal / Closing', 'icon': LucideIcons.users},
    {'value': 'follow_up', 'label': 'Follow Up', 'icon': LucideIcons.phoneCall},
    {'value': 'other', 'label': 'Lainnya', 'icon': LucideIcons.activity},
  ];

  @override
  void initState() {
    super.initState();
    final activity = widget.initialActivity;
    _titleController = TextEditingController(text: activity?.title ?? '');
    _notesController = TextEditingController(text: activity?.notes ?? '');
    _selectedType = activity?.activityType ?? 'visit';
    _selectedLeadId = activity?.leadId;
    _selectedLeadName = activity?.lead?.name;
    _selectedCustomerId = activity?.customerId;
    _selectedCustomerName = activity?.customer?.name;
    _selectedDealId = activity?.dealId;
    _selectedDealTitle = activity?.deal?.title;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showLeadPicker() {
    context.read<LeadBloc>().add(const FetchLeads());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Pilih Lead',
        child: BlocBuilder<LeadBloc, LeadState>(
          builder: (context, state) {
            if (state is LeadLoading) return const Center(child: CircularProgressIndicator());
            if (state is LeadsLoaded) {
              return ListView.builder(
                itemCount: state.leads.length,
                itemBuilder: (context, index) {
                  final lead = state.leads[index];
                  return ListTile(
                    leading: const Icon(LucideIcons.user, color: Colors.blueGrey),
                    title: Text(lead.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(lead.company ?? 'No Company'),
                    onTap: () {
                      setState(() {
                        _selectedLeadId = lead.id;
                        _selectedLeadName = lead.name;
                        _selectedCustomerId = null;
                        _selectedCustomerName = null;
                        _selectedDealId = null;
                        _selectedDealTitle = null;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }
            return const Center(child: Text('Gagal memuat lead'));
          },
        ),
      ),
    );
  }

  void _showCustomerPicker() {
    context.read<CustomerBloc>().add(const FetchCustomers());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Pilih Customer',
        child: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            if (state is CustomerLoading) return const Center(child: CircularProgressIndicator());
            if (state is CustomersLoaded) {
              return ListView.builder(
                itemCount: state.customers.length,
                itemBuilder: (context, index) {
                  final customer = state.customers[index];
                  return ListTile(
                    leading: const Icon(LucideIcons.building, color: Colors.teal),
                    title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(customer.companyName ?? 'No Company'),
                    onTap: () {
                      setState(() {
                        _selectedCustomerId = customer.id;
                        _selectedCustomerName = customer.name;
                        _selectedLeadId = null;
                        _selectedLeadName = null;
                        _selectedDealId = null;
                        _selectedDealTitle = null;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }
            return const Center(child: Text('Gagal memuat customer'));
          },
        ),
      ),
    );
  }

  void _showDealPicker() {
    context.read<DealBloc>().add(const FetchDeals());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Pilih Deal',
        child: BlocBuilder<DealBloc, DealState>(
          builder: (context, state) {
            if (state is DealLoading) return const Center(child: CircularProgressIndicator());
            if (state is DealsLoaded) {
              return ListView.builder(
                itemCount: state.deals.length,
                itemBuilder: (context, index) {
                  final deal = state.deals[index];
                  return ListTile(
                    leading: const Icon(LucideIcons.briefcase, color: Colors.indigo),
                    title: Text(deal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Rp ${NumberFormat('#,###', 'id_ID').format(deal.amount)}'),
                    onTap: () {
                      setState(() {
                        _selectedDealId = deal.id;
                        _selectedDealTitle = deal.title;
                        _selectedCustomerId = deal.customerId;
                        _selectedCustomerName = deal.customer?.name;
                        _selectedLeadId = null;
                        _selectedLeadName = null;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }
            return const Center(child: Text('Gagal memuat deal'));
          },
        ),
      ),
    );
  }

  Widget _buildPickerSheet({required String title, required Widget child}) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      String userId = '';
      if (authState is Authenticated) {
        userId = authState.user.id;
      } else if (widget.initialActivity != null) {
        userId = widget.initialActivity!.userId;
      }

      final activity = SalesActivity(
        id: widget.initialActivity?.id ?? const Uuid().v4(),
        title: _titleController.text,
        userId: userId,
        activityType: _selectedType,
        notes: _notesController.text,
        leadId: _selectedLeadId,
        customerId: _selectedCustomerId,
        dealId: _selectedDealId,
        activityAt: widget.initialActivity?.activityAt ?? DateTime.now(),
        createdAt: widget.initialActivity?.createdAt ?? DateTime.now(),
      );

      if (widget.initialActivity == null) {
        context.read<SalesActivityBloc>().add(CreateSalesActivitySubmitted(activity));
      } else {
        context.read<SalesActivityBloc>().add(UpdateSalesActivitySubmitted(activity));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialActivity != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Aktivitas' : 'Catat Aktivitas Baru', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<SalesActivityBloc, SalesActivityState>(
        listener: (context, state) {
          if (state is SalesActivityOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            context.pop(true);
          } else if (state is SalesActivityError) {
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
                _buildSectionHeader('Tipe & Judul', LucideIcons.type),
                const SizedBox(height: 16),
                const Text('Apa yang kamu lakukan?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _types.length,
                    itemBuilder: (context, index) {
                      final type = _types[index];
                      final isSelected = _selectedType == type['value'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = type['value']),
                        child: Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE8622A).withOpacity(0.1) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFE8622A) : Colors.grey[200]!,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(type['icon'], color: isSelected ? const Color(0xFFE8622A) : Colors.grey[400], size: 28),
                              const SizedBox(height: 8),
                              Text(
                                type['label'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? const Color(0xFFE8622A) : Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _titleController,
                  label: 'Judul Aktivitas',
                  hint: 'Contoh: Kunjungan Toko Kelontong Berkah',
                  icon: LucideIcons.edit3,
                  validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Hubungkan Dengan (Opsional)', LucideIcons.link2),
                const SizedBox(height: 16),
                _buildPickerField(
                  label: 'Lead',
                  value: _selectedLeadName ?? 'Hubungkan dengan Lead',
                  icon: LucideIcons.user,
                  onTap: _showLeadPicker,
                ),
                const SizedBox(height: 12),
                _buildPickerField(
                  label: 'Customer',
                  value: _selectedCustomerName ?? 'Hubungkan dengan Customer',
                  icon: LucideIcons.building,
                  onTap: _showCustomerPicker,
                ),
                const SizedBox(height: 12),
                _buildPickerField(
                  label: 'Deal',
                  value: _selectedDealTitle ?? 'Hubungkan dengan Deal',
                  icon: LucideIcons.briefcase,
                  onTap: _showDealPicker,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Catatan & Detail', LucideIcons.fileText),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _notesController,
                  label: 'Catatan Aktivitas',
                  hint: 'Tuliskan hasil diskusi, feedback, atau langkah selanjutnya...',
                  icon: LucideIcons.alignLeft,
                  maxLines: 5,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: BlocBuilder<SalesActivityBloc, SalesActivityState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is SalesActivityLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8622A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: state is SalesActivityLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isEdit ? 'Simpan Perubahan' : 'Catat Aktivitas',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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
      ),
    );
  }

  Widget _buildPickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isPlaceholder = value.contains('Hubungkan');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: isPlaceholder ? Colors.grey.shade200 : const Color(0xFFE8622A).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
          color: isPlaceholder ? Colors.grey[50] : const Color(0xFFE8622A).withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isPlaceholder ? Colors.grey : const Color(0xFFE8622A)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isPlaceholder ? Colors.grey : Colors.black,
                  fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isPlaceholder)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(LucideIcons.x, size: 16, color: Colors.red),
                onPressed: () {
                  setState(() {
                    if (label == 'Lead') { _selectedLeadId = null; _selectedLeadName = null; }
                    if (label == 'Customer') { _selectedCustomerId = null; _selectedCustomerName = null; }
                    if (label == 'Deal') { _selectedDealId = null; _selectedDealTitle = null; }
                  });
                },
              )
            else
              const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
