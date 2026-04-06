import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/lead.dart';
import '../bloc/lead_bloc.dart';
import '../bloc/lead_event.dart';
import '../bloc/lead_state.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../products/domain/entities/product.dart';

class AddLeadPage extends StatefulWidget {
  final Lead? initialLead;
  const AddLeadPage({super.key, this.initialLead});

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
  List<Product> _selectedProducts = [];
  
  Position? _currentPosition;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    final lead = widget.initialLead;
    if (lead != null) {
      _titleController.text = lead.title;
      _nameController.text = lead.name;
      _companyController.text = lead.company ?? '';
      _emailController.text = lead.email ?? '';
      _phoneController.text = lead.phone ?? '';
      _valueController.text = lead.estimatedValue?.toString() ?? '';
      _notesController.text = lead.notes ?? '';
      _selectedSource = lead.source;
      
      // We will need to fetch actual product objects if we have IDs
      // For now, let's trigger production fetch
      if (lead.latitude != null && lead.longitude != null) {
        // Mocking Position since geolocator doesn't have a simple constructor for this
        _currentPosition = Position(
          latitude: lead.latitude!,
          longitude: lead.longitude!,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    }
    context.read<ProductBloc>().add(const FetchProducts());
  }

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

  Future<void> _getLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final lead = Lead(
        id: widget.initialLead?.id ?? const Uuid().v4(),
        title: _titleController.text,
        name: _nameController.text,
        company: _companyController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        source: _selectedSource.toLowerCase(),
        status: widget.initialLead?.status ?? 'NEW',
        estimatedValue: double.tryParse(_valueController.text) ?? 0.0,
        potentialProducts: _selectedProducts.map((p) => p.name).toList(), // Using names for now as per "berpotensi menjual produk apa"
        notes: _notesController.text,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
      );
      
      if (widget.initialLead == null) {
        context.read<LeadBloc>().add(CreateLeadSubmitted(lead));
      } else {
        context.read<LeadBloc>().add(UpdateLeadSubmitted(lead));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.initialLead == null ? 'Add New Lead' : 'Edit Lead Data', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  label: 'Nama Toko / Bisnis',
                  hint: 'Contoh: Toko Berkah atau Warung Makan Sedap',
                  icon: LucideIcons.shoppingBag,
                  validator: (v) => v!.isEmpty ? 'Nama toko wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Pemilik / PIC',
                  hint: 'Nama lengkap pemilik atau penanggung jawab',
                  icon: LucideIcons.user,
                  validator: (v) => v!.isEmpty ? 'Nama PIC wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _companyController,
                  label: 'Tipe Bisnis / Cabang',
                  hint: 'Contoh: Warung Makan, Toko Kelontong, Agen',
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
                          labelText: 'Sumber Prospek',
                          prefixIcon: const Icon(LucideIcons.compass, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _sources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _selectedSource = v!),
                      ),
                    ),
                  ],
                ),
                if (_selectedSource == 'Survey') ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader('Survey Location', LucideIcons.mapPin),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_currentPosition != null) ...[
                          Row(
                            children: [
                              const Icon(LucideIcons.checkCircle, color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Lon: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              TextButton(
                                onPressed: _getLocation,
                                child: const Text('Refresh', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ] else ...[
                          const Text(
                            'Lokasi survey sangat disarankan untuk validasi.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isGettingLocation ? null : _getLocation,
                              icon: _isGettingLocation 
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(LucideIcons.mapPin, size: 16),
                              label: Text(_isGettingLocation ? 'Mengambil Lokasi...' : 'Ambil Titik Lokasi Survey'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFE8622A),
                                side: const BorderSide(color: Color(0xFFE8622A)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildSectionHeader('Produk Potensial', LucideIcons.package),
                const SizedBox(height: 16),
                _buildProductSelector(),
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
                            : Text(
                                widget.initialLead == null ? 'Save Lead Data' : 'Update Lead Data',
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
    );
  }

  Widget _buildProductSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedProducts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.info, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text('Belum ada produk yang dipilih', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedProducts.map((product) => Chip(
              label: Text(product.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onDeleted: () => setState(() => _selectedProducts.remove(product)),
              deleteIconColor: Colors.red,
              backgroundColor: const Color(0xFFEFFBF5),
              side: const BorderSide(color: Color(0xFF0D8549), width: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            )).toList(),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _showProductPickerDialog,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Pilih Produk dari Katalog'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0D8549),
            side: const BorderSide(color: Color(0xFF0D8549)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  void _showProductPickerDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Pilih Produk Katalog', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) return const Center(child: CircularProgressIndicator());
                    if (state is ProductsLoaded) {
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: state.products.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final Product product = state.products[index];
                              final isSelected = _selectedProducts.any((Product p) => p.id == product.id);
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D8549).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(LucideIcons.package, color: Color(0xFF0D8549), size: 20),
                                ),
                                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text('Rp ${product.price.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                trailing: Icon(
                                  isSelected ? LucideIcons.checkCircle2 : LucideIcons.plusCircle,
                                  color: isSelected ? const Color(0xFF0D8549) : const Color(0xFFE8622A),
                                  size: 22,
                                ),
                                onTap: () {
                                  if (isSelected) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Item sudah ditambahkan sebelumnya'),
                                        duration: Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      _selectedProducts.add(product);
                                    });
                                    setModalState(() {}); // Update modal UI
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} ditambahkan'),
                                        duration: const Duration(seconds: 1),
                                        backgroundColor: const Color(0xFF0D8549),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      );
                    }
                    return const Center(child: Text('Gagal memuat produk'));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
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
