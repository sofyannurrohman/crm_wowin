import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';

import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../domain/entities/customer.dart';

class AddCustomerPage extends StatefulWidget {
  final Customer? initialCustomer;
  const AddCustomerPage({super.key, this.initialCustomer});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  LatLng? _selectedLocation;
  final MapController _mapController = MapController();
  bool _isGettingLocation = false;

  static const Color _orange = Color(0xFFE8622A);
  static const Color _navy = Color(0xFF1A237E);
  static const Color _bg = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomer != null) {
      _nameController.text = widget.initialCustomer!.name;
      _industryController.text = widget.initialCustomer!.industry ?? '';
      _fullNameController.text = widget.initialCustomer!.name;
      _phoneController.text = widget.initialCustomer!.phone ?? '';
      _emailController.text = widget.initialCustomer!.email ?? '';
      if (widget.initialCustomer!.latitude != null &&
          widget.initialCustomer!.longitude != null) {
        _selectedLocation = LatLng(widget.initialCustomer!.latitude!,
            widget.initialCustomer!.longitude!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = latLng;
        _isGettingLocation = false;
      });
      _mapController.move(latLng, 15.0);
    } catch (e) {
      setState(() => _isGettingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error getting location: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: widget.initialCustomer?.id ?? '', // Backend will generate if empty
        name: _nameController.text,
        companyName: _nameController.text,
        industry: _industryController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        status: widget.initialCustomer?.status ?? 'prospect',
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
      );

      if (widget.initialCustomer != null) {
        context.read<CustomerBloc>().add(UpdateCustomerSubmitted(customer));
      } else {
        context.read<CustomerBloc>().add(CreateCustomerSubmitted(customer));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialCustomer != null;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF1A1A1A)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEdit ? 'Edit Customer' : 'Add New Customer',
          style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 18,
              fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isEdit ? 'Update' : 'Save Customer',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: BlocListener<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFF10B981)),
            );
            context.pop();
          } else if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFEF4444)),
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
                _buildSectionHeader(LucideIcons.building2, 'Company Information'),
                const SizedBox(height: 16),
                _buildTextField('Company Name', _nameController, 'e.g. Acme Corp'),
                const SizedBox(height: 16),
                _buildDropdownField('Industry', _industryController, ['Tech Sector', 'Manufacturing', 'Retail', 'Agribusiness']),

                const SizedBox(height: 32),
                _buildSectionHeader(LucideIcons.user, 'Contact Person'),
                const SizedBox(height: 16),
                _buildTextField('Full Name', _fullNameController, 'John Doe'),
                const SizedBox(height: 16),
                _buildIconTextField('Phone Number', _phoneController, '+1 (555) 000-0000', LucideIcons.phone),
                const SizedBox(height: 16),
                _buildIconTextField('Email Address', _emailController, 'john@company.com', LucideIcons.mail),

                const SizedBox(height: 24),
                _buildTipsCard(),

                const SizedBox(height: 32),
                _buildLocationHeader(),
                const SizedBox(height: 16),
                _buildMapPreview(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildLocationBtn(LucideIcons.mapPin, 'Use My Current Location', _getCurrentLocation)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLocationBtn(LucideIcons.search, 'Search Address', () {})),
                  ],
                ),

                const SizedBox(height: 48),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 220,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                            isEdit
                                ? 'Update Customer Profile'
                                : 'Create Customer Profile',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Center(
                  child: Text(
                    '© 2024 Wowin CR. All rights reserved.',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
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

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: _orange, size: 20),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4B5563))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _orange, width: 2)),
          ),
          validator: (v) => v!.isEmpty ? 'Field required' : null,
        ),
      ],
    );
  }

  Widget _buildIconTextField(String label, TextEditingController controller, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4B5563))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 18),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4B5563))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          hint: const Text('Select an industry'),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: (v) => controller.text = v ?? '',
        ),
      ],
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFedd5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Registration Tips', style: TextStyle(color: _orange, fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 12),
          _buildTip(LucideIcons.info, 'Ensure company name matches legal documents.'),
          const SizedBox(height: 8),
          _buildTip(LucideIcons.info, 'Double check the contact email for billing.'),
          const SizedBox(height: 8),
          _buildTip(LucideIcons.mapPin, 'The map pin below will be used for delivery routes.'),
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: _orange),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF9A3412), fontSize: 13, height: 1.4))),
      ],
    );
  }

  Widget _buildLocationHeader() {
    return Row(
      children: [
        const Icon(LucideIcons.map, color: _orange, size: 20),
        const SizedBox(width: 10),
        const Text('Customer Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
        const Spacer(),
        if (_selectedLocation != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(20)),
            child: Text(
              'GPS: ${_selectedLocation!.latitude.toStringAsFixed(4)}° N, ${_selectedLocation!.longitude.toStringAsFixed(4)}° W',
              style: const TextStyle(color: _orange, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(-6.200000, 106.816666),
                initialZoom: 10.0,
                onTap: (tapPosition, latLng) => setState(() => _selectedLocation = latLng),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.wowin.crm',
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
                        child: const Icon(LucideIcons.mapPin, color: _orange, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
            if (_selectedLocation == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.mapPin, color: _orange, size: 40),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                      child: const Text('Pin Location Here', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF4B5563)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
