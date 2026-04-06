import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../domain/entities/task.dart' as ent;
import '../../domain/entities/warehouse.dart' as ent;

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  // changed orange -> new green #0D8549
  static const Color _orange = Color(0xFF0D8549);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _customerSearchController = TextEditingController();
  
  ent.TaskPriority _selectedPriority = ent.TaskPriority.MEDIUM;
  DateTime? _selectedDate;
  String? _selectedWarehouseId;
  List<ent.Warehouse> _warehouses = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const FetchWarehouses());
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

    final newTask = ent.Task(
      id: const Uuid().v4(),
      salesId: 'CURRENT_USER_ID', // In real app, get from AuthBloc
      warehouseId: _selectedWarehouseId,
      title: title,
      description: _descController.text.trim(),
      priority: _selectedPriority,
      status: ent.TaskStatus.TODO,
      dueDate: _selectedDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<TaskBloc>().add(CreateTask(newTask));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
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
      child: Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Task Title'),
            _buildTextField(_titleController, 'What needs to be done?', 1),
            const SizedBox(height: 24),
            
            _buildLabel('Description'),
            _buildTextField(_descController, 'Add more details about this task...', 4),
            const SizedBox(height: 24),
            
            _buildLabel('Priority'),
            _buildPriorityToggle(),
            const SizedBox(height: 24),
            
            _buildLabel('Due Date'),
            _buildDateField(),
            const SizedBox(height: 24),

            _buildLabel('Starting Warehouse'),
            _buildWarehouseDropdown(),
            const SizedBox(height: 24),
            
            _buildLabel('Link to Customer'),
            _buildCustomerSearch(),
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
      title: const Text(
        'New Task',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
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
          // light border from orange -> light green tint
          borderSide: BorderSide(color: const Color(0xFFCFF1E0) /* light green accent */, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFCFF1E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _orange, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPriorityToggle() {
    return Container(
      decoration: BoxDecoration(
        // soft pale orange -> soft pale green
        color: const Color(0xFFF3FBF7),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildPriorityOption(ent.TaskPriority.LOW),
          _buildPriorityOption(ent.TaskPriority.MEDIUM),
          _buildPriorityOption(ent.TaskPriority.HIGH),
        ],
      ),
    );
  }

  Widget _buildPriorityOption(ent.TaskPriority priority) {
    final isSelected = _selectedPriority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = priority),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
            ] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            priority.name,
            style: TextStyle(
              color: isSelected ? _orange : const Color(0xFF4B5563),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
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
        if (mounted && picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFED7AA), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate != null 
                ? '${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                : 'mm/dd/yyyy',
              style: TextStyle(
                color: _selectedDate == null ? _textSecondary : _textPrimary,
                fontSize: 16,
              ),
            ),
            Icon(LucideIcons.calendar, size: 20, color: const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCFF1E0), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedWarehouseId,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 20, color: _textSecondary),
          hint: const Text('Pilih Gudang', style: TextStyle(color: Color(0xFF9CA3AF))),
          items: _warehouses.map<DropdownMenuItem<String>>((w) {
            return DropdownMenuItem<String>(
              value: w.id,
              child: Text(w.name, style: const TextStyle(color: _textPrimary, fontSize: 15)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedWarehouseId = val),
        ),
      ),
    );
  }

  Widget _buildCustomerSearch() {
    return Column(
      children: [
        TextField(
          controller: _customerSearchController,
          decoration: InputDecoration(
            hintText: 'Cari Customer...',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
            suffixIcon: const Icon(LucideIcons.search, color: Color(0xFF9CA3AF), size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFCFF1E0), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFCFF1E0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _orange, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Selected Customer Card Mockup
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3FBF7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3FBF7)),
          ),
          child: Row(
            children: [
               Container(
                 width: 36,
                 height: 36,
                 alignment: Alignment.center,
                 // pale accent -> pale green
                 decoration: BoxDecoration(color: const Color(0xFFCFF1E0), shape: BoxShape.circle),
                 child: const Text('JD', style: TextStyle(color: _orange, fontWeight: FontWeight.bold, fontSize: 13)),
               ),
               const SizedBox(width: 12),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text('John Doe', style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                   Text('Acme Corporation', style: TextStyle(color: _textSecondary.withOpacity(0.8), fontSize: 11)),
                 ],
               ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: SafeArea( // Keep it above device rounded edges/software bars
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _orange,
            disabledBackgroundColor: _orange.withOpacity(0.5),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSubmitting 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text(
                  'Create Task',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
