import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _customerSearchController = TextEditingController();
  
  String _selectedPriority = 'Medium';
  String _dueDate = 'mm/dd/yyyy';
  bool _isSubmitting = false;

  Future<void> _submitMockBackend() async {
    setState(() => _isSubmitting = true);
    
    // Simulating API integration request
    /* Code to send to backend:
       TaskRepository.createTask({
         'title': _titleController.text,
         'description': _descController.text,
         'priority': _selectedPriority.toUpperCase(),
         'dueDate': _dueDate,
         'customerId': 'JD-123',
       });
    */
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully!'), backgroundColor: Colors.green),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            
            _buildLabel('Link to Customer'),
            _buildCustomerSearch(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(),
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
          borderSide: BorderSide(color: const Color(0xFFFED7AA) /* light orange accent */, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFFED7AA), width: 1),
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
        color: const Color(0xFFF3E8E0), // Soft pale orange/grey mix mimicking mock
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildPriorityOption('Low'),
          _buildPriorityOption('Medium'),
          _buildPriorityOption('High'),
        ],
      ),
    );
  }

  Widget _buildPriorityOption(String options) {
    final isSelected = _selectedPriority == options;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = options),
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
            options,
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
        if (picked != null) {
          setState(() {
            _dueDate = '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
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
              _dueDate,
              style: TextStyle(
                color: _dueDate == 'mm/dd/yyyy' ? _textPrimary : _textPrimary,
                fontSize: 16,
              ),
            ),
            Icon(LucideIcons.calendar, size: 20, color: const Color(0xFF9CA3AF)),
          ],
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
            hintText: 'Search customers...',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
            suffixIcon: const Icon(LucideIcons.search, color: Color(0xFF9CA3AF), size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFFED7AA), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFFED7AA), width: 1),
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
            color: const Color(0xFFFDF6F3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFAEBE5)),
          ),
          child: Row(
            children: [
               Container(
                 width: 36,
                 height: 36,
                 alignment: Alignment.center,
                 decoration: BoxDecoration(color: const Color(0xFFFCD3AD), shape: BoxShape.circle),
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
          onPressed: _isSubmitting ? null : _submitMockBackend,
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
