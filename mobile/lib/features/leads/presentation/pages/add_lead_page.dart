import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedBusinessType;
  final List<String> _businessTypes = ['Warung Makan', 'Toko Kelontong', 'Retail / Minimarket', 'Agen / Distributor', 'Restoran', 'Cafe', 'Lainnya'];
  String _selectedSource = 'Survey';
  String _selectedStatus = 'new';
  List<Product> _selectedProducts = [];
  
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();
  bool _isGettingLocation = false;

  static const Color _green = Color(0xFF0D8549);

  @override
  void initState() {
    super.initState();
    final lead = widget.initialLead;
    if (lead != null) {
      _titleController.text = lead.title;
      _nameController.text = lead.name;
      _selectedBusinessType = _businessTypes.cast<String?>().firstWhere(
        (t) => t?.toLowerCase() == lead.company?.toLowerCase(),
        orElse: () => _businessTypes.contains(lead.company) ? lead.company : null,
      );
      _emailController.text = lead.email ?? '';
      _phoneController.text = lead.phone ?? '';
      _valueController.text = lead.estimatedValue?.toString() ?? '';
      _notesController.text = lead.notes ?? '';
      
      _selectedSource = _sources.firstWhere(
        (s) => s.toLowerCase() == lead.source.toLowerCase(),
        orElse: () => _sources.first,
      );
      
      if (lead.latitude != null && lead.longitude != null) {
        _selectedLocation = LatLng(lead.latitude!, lead.longitude!);
      }
      _addressController.text = lead.address ?? '';
      _selectedStatus = lead.status;
    }
    context.read<ProductBloc>().add(const FetchProducts());
  }

  final List<String> _sources = ['Survey', 'Referral', 'Website', 'Event', 'Other'];

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    _mapController.dispose();
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
      _reverseGeocode(latLng);
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

  Future<void> _reverseGeocode(LatLng location) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1');
      final response = await http.get(url, headers: {
        'User-Agent': 'WowinCRM/1.0',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String? displayName = data['display_name'];
        if (displayName != null) {
          setState(() {
            _addressController.text = displayName;
          });
        }
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final lead = Lead(
        id: widget.initialLead?.id ?? const Uuid().v4(),
        title: _titleController.text,
        name: _nameController.text,
        company: _selectedBusinessType,
        email: _emailController.text,
        phone: _phoneController.text,
        source: _selectedSource.toLowerCase(),
        status: _selectedStatus,
        estimatedValue: double.tryParse(_valueController.text) ?? 0.0,
        potentialProducts: _selectedProducts.map((p) => p.name).toList(), // Using names for now as per "berpotensi menjual produk apa"
        notes: _notesController.text,
        address: _addressController.text,
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
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
        backgroundColor: const Color(0xFF0D8549),
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
                DropdownButtonFormField<String>(
                  value: _selectedBusinessType,
                  decoration: InputDecoration(
                    labelText: 'Tipe Bisnis / Cabang',
                    prefixIcon: const Icon(LucideIcons.building, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0D8549), width: 2),
                    ),
                  ),
                  items: _businessTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _selectedBusinessType = v),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          prefixIcon: const Icon(LucideIcons.activity, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'new', child: Text('Baru')),
                          DropdownMenuItem(value: 'contacted', child: Text('Dihubungi')),
                          DropdownMenuItem(value: 'qualified', child: Text('Qualified')),
                          DropdownMenuItem(value: 'unqualified', child: Text('Unqualified')),
                        ],
                        onChanged: (v) => setState(() => _selectedStatus = v!),
                      ),
                    ),
                  ],
                ),
                if (_selectedSource == 'Survey') ...[
                  const SizedBox(height: 24),
                  _buildLocationHeader(),
                  const SizedBox(height: 16),
                  _buildMapPreview(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Alamat / Lokasi (Auto-Geocode)',
                    hint: 'Pilih lokasi di peta atau gunakan GPS untuk mengisi alamat',
                    icon: LucideIcons.mapPin,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildLocationBtn(LucideIcons.mapPin, 'Use My Current Location', _getCurrentLocation)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildLocationBtn(LucideIcons.search, 'Search Address', () {})),
                    ],
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
                                  color: isSelected ? const Color(0xFF0D8549) : const Color(0xFF0D8549),
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
        Icon(icon, size: 18, color: _green),
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
          borderSide: const BorderSide(color: _green, width: 2),
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Row(
      children: [
        const Icon(LucideIcons.map, color: _green, size: 20),
        const SizedBox(width: 10),
        const Text('Survey Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
        const Spacer(),
        if (_selectedLocation != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(
              'GPS: ${_selectedLocation!.latitude.toStringAsFixed(4)}° N, ${_selectedLocation!.longitude.toStringAsFixed(4)}° E',
              style: const TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w800),
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
                initialCenter: _selectedLocation ?? const LatLng(-6.200000, 106.816666),
                initialZoom: 14.0,
                onTap: (tapPosition, latLng) {
                   setState(() => _selectedLocation = latLng);
                   _reverseGeocode(latLng);
                },
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
                        child: const Icon(LucideIcons.mapPin, color: _green, size: 40),
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
                    const Icon(LucideIcons.mapPin, color: _green, size: 40),
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
