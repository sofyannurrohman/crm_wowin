import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
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
    final String taskId = 'temp-id'; 
    final bool alreadyAdded = _destinations.any((d) => 
      (target is Customer && d.customerId == target.id) || 
      (target is Lead && d.leadId == target.id)
    );

    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Target already in the list'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
      for (int i = 0; i < _destinations.length; i++) {
        _destinations[i] = _destinations[i].copyWith(sequenceOrder: i + 1);
      }
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip title is required'), backgroundColor: Color(0xFFEF4444), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    if (_selectedWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Starting warehouse is required'), backgroundColor: Color(0xFFEF4444), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    if (_destinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one destination'), backgroundColor: Color(0xFFEF4444), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    if (_isEditMode) {
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
                 SnackBar(content: Text(state.message), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating),
               );
               context.pop();
            } else if (state is TaskError) {
               setState(() => _isSubmitting = false);
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating),
               );
            }
          },
        ),
        BlocListener<DealBloc, dl.DealState>(
          listener: (context, state) {
            if (state is dl.DealsLoaded) {
               if (state.deals.isNotEmpty) {
                 final cid = state.deals.first.customerId;
                 if (cid != null && cid.isNotEmpty) {
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
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildPremiumHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('TRIP TITLE'),
                    _buildTextField(_titleController, 'e.g. Monday Routine Visit', 1),
                    const SizedBox(height: 24),
                    
                    _buildLabel('OBJECTIVE / NOTES'),
                    _buildTextField(_descController, 'Write trip details here...', 3),
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('TRIP DATE'),
                              _buildDateField(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('WAREHOUSE'),
                              _buildWarehouseDropdown(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('DESTINATIONS (${_destinations.length})'),
                        GestureDetector(
                          onTap: _showAddDestinationSheet,
                          child: const Text('ADD TARGET', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDestinationList(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomAction(),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              ),
              Text(
                _isEditMode ? 'Edit Planning' : 'New Planning',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 48), // Spacer to balance leading
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textPlaceholder, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, int lines) {
    return TextField(
      controller: controller,
      maxLines: lines,
      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 15, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (mounted && picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: const Color(0xFFF1F5F9))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate != null ? DateFormat('MM/dd/yyyy').format(_selectedDate!) : 'Select Date',
              style: TextStyle(
                color: _selectedDate == null ? AppColors.textPlaceholder : AppColors.textPrimary, 
                fontSize: 14, 
                fontWeight: FontWeight.w700
              ),
            ),
            const Icon(LucideIcons.calendar, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: const Color(0xFFF1F5F9))
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedWarehouseId,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 18, color: AppColors.textPlaceholder),
          hint: const Text('Origin', style: TextStyle(color: AppColors.textPlaceholder, fontSize: 14, fontWeight: FontWeight.w700)),
          items: _warehouses.map<DropdownMenuItem<String>>((w) {
            return DropdownMenuItem<String>(value: w.id, child: Text(w.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)));
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
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(24), 
          border: Border.all(color: const Color(0xFFF1F5F9), style: BorderStyle.solid)
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), shape: BoxShape.circle),
              child: const Icon(LucideIcons.mapPin, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('No destinations added yet', style: TextStyle(color: AppColors.textPlaceholder, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(_destinations.length, (index) {
        final dest = _destinations[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(20), 
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('${index + 1}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dest.targetName ?? 'Target', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(dest.targetAddress ?? 'Address unknown', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (dest.dealTitle != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.briefcase, size: 10, color: Color(0xFF3B82F6)),
                            const SizedBox(width: 6),
                            Text(dest.dealTitle!, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 10, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dest.customerId != null)
                    IconButton(
                      onPressed: () => _showDealSelectionSheet(index),
                      icon: Icon(LucideIcons.link, color: dest.dealId != null ? const Color(0xFF3B82F6) : AppColors.textPlaceholder, size: 18),
                    ),
                  IconButton(onPressed: () => _removeDestination(index), icon: const Icon(LucideIcons.trash2, color: Color(0xFFEF4444), size: 18)),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showAddDestinationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text('Select Destination', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    context.read<CustomerBloc>().add(FetchCustomers(query: val));
                    context.read<LeadBloc>().add(FetchLeads(query: val));
                  },
                  decoration: InputDecoration(
                    hintText: 'Search leads or customers...',
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                unselectedLabelColor: AppColors.textPlaceholder,
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [Tab(text: 'CUSTOMERS'), Tab(text: 'LEADS')],
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
        if (state is cust.CustomerLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        if (state is cust.CustomersLoaded) {
          if (state.customers.isEmpty) return const Center(child: Text('No customers found', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPlaceholder)));
          return ListView.builder(
            controller: scrollController,
            itemCount: state.customers.length,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemBuilder: (context, index) {
              final c = state.customers[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.building, color: AppColors.primary, size: 20),
                ),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                subtitle: Text(c.address ?? 'No address', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                onTap: () {
                  _addDestination(c);
                  context.pop();
                },
              );
            },
          );
        }
        return const Center(child: Text('Failed to load data'));
      },
    );
  }

  Widget _buildLeadTab(ScrollController scrollController) {
    return BlocBuilder<LeadBloc, lead.LeadState>(
      builder: (context, state) {
        if (state is lead.LeadLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        if (state is lead.LeadsLoaded) {
          if (state.leads.isEmpty) return const Center(child: Text('No leads found', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPlaceholder)));
          return ListView.builder(
            controller: scrollController,
            itemCount: state.leads.length,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemBuilder: (context, index) {
              final l = state.leads[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.user, color: Color(0xFF3B82F6), size: 20),
                ),
                title: Text(l.name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                subtitle: const Text('Lead Target', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                onTap: () {
                  _addDestination(l);
                  context.pop();
                },
              );
            },
          );
        }
        return const Center(child: Text('Failed to load data'));
      },
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white, 
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : Text(
                  _isEditMode ? 'Update Planning' : 'Create Schedule Trip',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3),
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Link Activity to Deal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 24),
            if (deals.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No active deals for this customer.', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPlaceholder)),
              ))
            else
              ...deals.map((deal) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(LucideIcons.briefcase, size: 18, color: AppColors.primary),
                    ),
                    title: Text(deal.title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    subtitle: Text('Rp${deal.amount} • ${deal.stage.toUpperCase()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    trailing: dest.dealId == deal.id ? const Icon(LucideIcons.checkCircle2, color: AppColors.primary) : null,
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
            const SizedBox(height: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(LucideIcons.link2Off, color: Color(0xFFEF4444), size: 20),
              title: const Text('Remove Deal Link', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w800)),
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
