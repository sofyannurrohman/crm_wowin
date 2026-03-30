import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/lead.dart';
import '../bloc/lead_bloc.dart';
import '../bloc/lead_event.dart';
import '../bloc/lead_state.dart';

class AddLeadPage extends StatefulWidget {
  const AddLeadPage({super.key});

  @override
  State<AddLeadPage> createState() => _AddLeadPageState();
}

class _AddLeadPageState extends State<AddLeadPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedSource = 'Survey';

  final List<String> _sources = ['Survey', 'Referral', 'Website', 'Event', 'Other'];

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final lead = Lead(
        id: const Uuid().v4(),
        title: _titleController.text,
        name: _nameController.text,
        company: _companyController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        source: _selectedSource,
        status: 'NEW',
        estimatedValue: double.tryParse(_valueController.text) ?? 0.0,
        notes: _notesController.text,
      );
      context.read<LeadBloc>().add(CreateLeadSubmitted(lead));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add New Lead', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE8622A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<LeadBloc, LeadState>(
        listener: (context, state) {
          if (state is LeadOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            context.pop();
          } else if (state is LeadError) {
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
                _buildSectionHeader('Lead Information', LucideIcons.user),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _titleController,
                  label: 'Lead Title / Requirement',
                  hint: 'e.g. 50pcs Office Chairs',
                  icon: LucideIcons.type,
                  validator: (v) => v!.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  label: 'Contact Name',
                  hint: 'Full name of the person',
                  icon: LucideIcons.user,
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _companyController,
                  label: 'Company Name',
                  hint: 'Business name',
                  icon: LucideIcons.building,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Contact Details', LucideIcons.phone),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'email@example.com',
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        hint: '0812...',
                        icon: LucideIcons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Opportunity Info', LucideIcons.trendingUp),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSource,
                        decoration: InputDecoration(
                          labelText: 'Lead Source',
                          prefixIcon: const Icon(LucideIcons.compass, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _sources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _selectedSource = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _valueController,
                        label: 'Estimated Value',
                        hint: 'Amount (Rp)',
                        icon: LucideIcons.dollarSign,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _notesController,
                  label: 'Internal Notes',
                  hint: 'Add any specific findings from survey...',
                  icon: LucideIcons.fileText,
                  maxLines: 3,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: BlocBuilder<LeadBloc, LeadState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is LeadLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: state is LeadLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Save Lead Data',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
            fontWeight: FontWeight.w800,
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
      ),
    );
  }
}
