import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../domain/entities/task.dart' as ent;
import '../../domain/entities/task_destination.dart' as ent;
import '../../domain/entities/warehouse.dart' as ent;
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart' as cust;
import '../../../leads/domain/entities/lead.dart';
import '../../../leads/presentation/bloc/lead_bloc.dart';
import '../../../leads/presentation/bloc/lead_event.dart';
import '../../../leads/presentation/bloc/lead_state.dart' as lead;
import '../../../deals/presentation/bloc/deal_bloc.dart';
import '../../../deals/presentation/bloc/deal_event.dart' as dl;
import '../../../deals/presentation/bloc/deal_state.dart' as dl;
import '../../../deals/domain/entities/deal.dart';

class NewTaskPage extends StatefulWidget {
  final ent.Task? initialTask;
  const NewTaskPage({super.key, this.initialTask});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> with SingleTickerProviderStateMixin {
  static const Color _orange = Color(0xFF0D8549);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _searchController = TextEditingController();
  late TabController _tabController;
  
  DateTime? _selectedDate;
  String? _selectedWarehouseId;
  List<ent.Warehouse> _warehouses = [];
  List<ent.TaskDestination> _destinations = [];
  Map<String, List<Deal>> _customerDeals = {};
  bool _isSubmitting = false;

  bool get _isEditMode => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<TaskBloc>().add(const FetchWarehouses());
    context.read<CustomerBloc>().add(const FetchCustomers());
    context.read<LeadBloc>().add(const FetchLeads());

    // Pre-fill fields if in edit mode
    if (_isEditMode) {
      final t = widget.initialTask!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _selectedDate = t.dueDate;
      _selectedWarehouseId = t.warehouseId;
      _destinations = List.from(t.destinations);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addDestination(dynamic target) {
    final String taskId = 'temp-id'; // Will be set on submit
    final bool alreadyAdded = _destinations.any((d) => 
      (target is Customer && d.customerId == target.id) || 
      (target is Lead && d.leadId == target.id)
    );

    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tujuan sudah ada dalam daftar')),
      );
      return;
    }

    setState(() {
      _destinations.add(ent.TaskDestination(
        id: const Uuid().v4(),
        taskId: taskId,
        leadId: target is Lead ? target.id : null,
        customerId: target is Customer ? target.id : null,
        sequenceOrder: _destinations.length + 1,
        status: ent.TaskStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        targetName: target is Lead ? target.name : (target as Customer).name,
        targetAddress: target is Lead ? (target.address ?? '') : (target as Customer).address,
        targetLatitude: target is Lead ? target.latitude : (target as Customer).latitude,
        targetLongitude: target is Lead ? target.longitude : (target as Customer).longitude,
      ));

      if (target is Customer) {
        context.read<DealBloc>().add(dl.FetchDeals(customerId: target.id));
      }
    });
  }

  void _removeDestination(int index) {
    setState(() {
      _destinations.removeAt(index);
      // Re-index
      for (int i = 0; i < _destinations.length; i++) {
        _destinations[i] = _destinations[i].copyWith(sequenceOrder: i + 1);
      }
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tugas tidak boleh kosong'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gudang asal'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_destinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daftar tujuan tidak boleh kosong'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_isEditMode) {
      // UPDATE mode
      final existing = widget.initialTask!;
      final updated = ent.Task(
        id: existing.id,
        salesId: existing.salesId,
        warehouseId: _selectedWarehouseId,
        title: title,
        description: _descController.text.trim(),
        status: existing.status,
        destinations: _destinations.map((d) => ent.TaskDestination(
          id: d.id,
          taskId: existing.id,
          leadId: d.leadId,
          customerId: d.customerId,
          dealId: d.dealId,
          sequenceOrder: d.sequenceOrder,
          status: d.status,
          createdAt: d.createdAt,
          updatedAt: DateTime.now(),
        )).toList(),
        dueDate: _selectedDate,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
      context.read<TaskBloc>().add(UpdateTask(updated));
    } else {
      // CREATE mode
      final taskId = const Uuid().v4();
      final newTask = ent.Task(
        id: taskId,
        salesId: const Uuid().v4(),
        warehouseId: _selectedWarehouseId,
        title: title,
        description: _descController.text.trim(),
        status: ent.TaskStatus.pending,
        destinations: _destinations.map((d) => ent.TaskDestination(
          id: d.id,
          taskId: taskId,
          leadId: d.leadId,
          customerId: d.customerId,
          dealId: d.dealId,
          sequenceOrder: d.sequenceOrder,
          status: d.status,
          createdAt: d.createdAt,
          updatedAt: d.updatedAt,
        )).toList(),
        dueDate: _selectedDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<TaskBloc>().add(CreateTask(newTask));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TaskBloc, TaskState>(
          listener: (context, state) {
            if (state is TaskLoading) {
               setState(() => _isSubmitting = true);
            } else if (state is WarehousesLoaded) {
               setState(() {
                 _isSubmitting = false;
                 _warehouses = state.warehouses;
                 if (_warehouses.isNotEmpty && _selectedWarehouseId == null) {
                   _selectedWarehouseId = _warehouses.first.id;
                 }
               });
            } else if (state is TaskOperationSuccess) {
               setState(() => _isSubmitting = false);
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(state.message), backgroundColor: Colors.green),
               );
               context.pop();
            } else if (state is TaskError) {
               setState(() => _isSubmitting = false);
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(state.message), backgroundColor: Colors.red),
               );
            }
          },
        ),
        BlocListener<DealBloc, dl.DealState>(
          listener: (context, state) {
            if (state is dl.DealsLoaded) {
               if (state.deals.isNotEmpty) {
                 final cid = state.deals.first.customerId;
                 if (cid.isNotEmpty) {
                   setState(() {
                     _customerDeals[cid] = state.deals;
                   });
                 }
               }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Task Title / Trip Name'),
              _buildTextField(_titleController, 'Contoh: Kunjungan Rutin Senin', 1),
              const SizedBox(height: 24),
              
              _buildLabel('Description / Objective'),
              _buildTextField(_descController, 'Catatan tambahan...', 3),
              const SizedBox(height: 24),
              
              const SizedBox(height: 24),
              
              _buildLabel('Trip Date'),
              _buildDateField(),
              const SizedBox(height: 24),

              _buildLabel('Starting Warehouse'),
              _buildWarehouseDropdown(),
              const SizedBox(height: 24),
              
              _buildLabel('Destinations (${_destinations.length})'),
              _buildDestinationList(),
              const SizedBox(height: 12),
              _buildAddDestinationAction(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomAction(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: _orange),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: Text(
        _isEditMode ? 'Edit Jadwal Kunjungan' : 'New Visit Schedule',
        style: const TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey.shade200, height: 1.0),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF374151), fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, int lines) {
    return TextField(
      controller: controller,
      maxLines: lines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCFF1E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCFF1E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _orange, width: 1.5),
        ),
      ),
    );
  }


  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (mounted && picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFCFF1E0), width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate != null ? '${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.year}' : 'mm/dd/yyyy',
              style: TextStyle(color: _selectedDate == null ? _textSecondary : _textPrimary, fontSize: 16),
            ),
            const Icon(LucideIcons.calendar, size: 20, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFCFF1E0), width: 1)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedWarehouseId,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 20, color: _textSecondary),
          hint: const Text('Pilih Gudang', style: TextStyle(color: Color(0xFF9CA3AF))),
          items: _warehouses.map<DropdownMenuItem<String>>((w) {
            return DropdownMenuItem<String>(value: w.id, child: Text(w.name, style: const TextStyle(color: _textPrimary, fontSize: 15)));
          }).toList(),
          onChanged: (val) => setState(() => _selectedWarehouseId = val),
        ),
      ),
    );
  }

  Widget _buildDestinationList() {
    if (_destinations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200, style: BorderStyle.none)),
        child: Column(
          children: [
            Icon(LucideIcons.mapPin, color: Colors.grey.shade300, size: 32),
            const SizedBox(height: 8),
            Text('Belum ada tujuan ditambahkan', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(_destinations.length, (index) {
        final dest = _destinations[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFCFF1E0))),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: _orange.withOpacity(0.1), radius: 14, child: Text('${index + 1}', style: const TextStyle(color: _orange, fontSize: 12, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dest.targetName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(dest.targetAddress ?? '', style: TextStyle(color: _textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (dest.dealTitle != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.briefcase, size: 12, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(dest.dealTitle!, style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (dest.customerId != null)
                IconButton(
                  onPressed: () => _showDealSelectionSheet(index),
                  icon: Icon(LucideIcons.link, color: dest.dealId != null ? Colors.blue : Colors.grey, size: 18),
                ),
              IconButton(onPressed: () => _removeDestination(index), icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 18)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAddDestinationAction() {
    return ElevatedButton.icon(
      onPressed: _showAddDestinationSheet,
      icon: const Icon(LucideIcons.plus, size: 16),
      label: const Text('Tambah Tujuan (Lead/Customer)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _orange,
        side: const BorderSide(color: _orange),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAddDestinationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Cari Lead/Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    context.read<CustomerBloc>().add(FetchCustomers(query: val));
                    context.read<LeadBloc>().add(FetchLeads(query: val));
                  },
                  decoration: InputDecoration(
                    hintText: 'Nama atau alamat...',
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                indicatorColor: _orange,
                labelColor: _orange,
                unselectedLabelColor: Colors.grey,
                tabs: const [Tab(text: 'Customers'), Tab(text: 'Leads')],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildCustomerTab(scrollController), _buildLeadTab(scrollController)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerTab(ScrollController scrollController) {
    return BlocBuilder<CustomerBloc, cust.CustomerState>(
      builder: (context, state) {
        if (state is cust.CustomerLoading) return const Center(child: CircularProgressIndicator(color: _orange));
        if (state is cust.CustomersLoaded) {
          if (state.customers.isEmpty) return const Center(child: Text('Tidak ada pelanggan ditemukan'));
          return ListView.builder(
            controller: scrollController,
            itemCount: state.customers.length,
            itemBuilder: (context, index) {
              final c = state.customers[index];
              return ListTile(
                leading: CircleAvatar(backgroundColor: const Color(0xFFF3FBF7), child: const Icon(LucideIcons.building, color: _orange, size: 20)),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(c.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  _addDestination(c);
                  context.pop();
                },
              );
            },
          );
        }
        return const Center(child: Text('Gagal memuat data'));
      },
    );
  }

  Widget _buildLeadTab(ScrollController scrollController) {
    return BlocBuilder<LeadBloc, lead.LeadState>(
      builder: (context, state) {
        if (state is lead.LeadLoading) return const Center(child: CircularProgressIndicator(color: _orange));
        if (state is lead.LeadsLoaded) {
          if (state.leads.isEmpty) return const Center(child: Text('Tidak ada lead ditemukan'));
          return ListView.builder(
            controller: scrollController,
            itemCount: state.leads.length,
            itemBuilder: (context, index) {
              final l = state.leads[index];
              return ListTile(
                leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(LucideIcons.user, color: Colors.blue, size: 20)),
                title: Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('', maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  _addDestination(l);
                  context.pop();
                },
              );
            },
          );
        }
        return const Center(child: Text('Gagal memuat data'));
      },
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _bg, border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)))),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _orange,
            disabledBackgroundColor: _orange.withValues(alpha: 0.5),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSubmitting
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  _isEditMode ? 'Simpan Perubahan' : 'Create Schedule Trip',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      ),
    );
  }

  void _showDealSelectionSheet(int destinationIndex) {
    final dest = _destinations[destinationIndex];
    final cid = dest.customerId;
    if (cid == null) return;

    final deals = _customerDeals[cid] ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Relasi Deal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (deals.isEmpty)
              const Center(child: Text('Tidak ada deal aktif untuk pelanggan ini'))
            else
              ...deals.map((deal) => ListTile(
                    leading: const Icon(LucideIcons.calculator),
                    title: Text(deal.title),
                    subtitle: Text('Rp${deal.amount} • ${deal.stage}'),
                    selected: dest.dealId == deal.id,
                    onTap: () {
                      setState(() {
                        _destinations[destinationIndex] = dest.copyWith(
                          dealId: deal.id,
                          dealTitle: deal.title,
                        );
                      });
                      context.pop();
                    },
                  )),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(LucideIcons.link2Off, color: Colors.red),
              title: const Text('Hapus Relasi Deal', style: TextStyle(color: Colors.red)),
              onTap: () {
                setState(() {
                  _destinations[destinationIndex] = dest.copyWith(
                    dealId: null,
                    dealTitle: null,
                  );
                });
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
