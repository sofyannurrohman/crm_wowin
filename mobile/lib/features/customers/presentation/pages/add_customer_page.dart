import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../domain/entities/customer.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart' as auth;
import '../../../auth/presentation/bloc/auth_state.dart' as auth;

class AddCustomerPage extends StatefulWidget {
  final Customer? initialCustomer;
  const AddCustomerPage({super.key, this.initialCustomer});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();

  XFile? _storePhotoFile;
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();
  final LatLng _defaultLocation = const LatLng(-6.2000, 106.8166); // Jakarta default
  String _address = '';
  bool _isGettingLocation = false;
  String? _selectedSalesmanId;

  static const Color _primary = Color(0xFF0066FF);
  static const Color _green = Color(0xFF10B981);
  static const Color _bg = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadPersistedState();
    if (widget.initialCustomer != null) {
      _nameController.text = widget.initialCustomer!.name;
      _ownerController.text = widget.initialCustomer!.companyName ?? '';
      _phoneController.text = widget.initialCustomer!.phone ?? '';
      if (widget.initialCustomer!.latitude != null &&
          widget.initialCustomer!.longitude != null) {
        _selectedLocation = LatLng(widget.initialCustomer!.latitude!,
            widget.initialCustomer!.longitude!);
      }
      _selectedSalesmanId = widget.initialCustomer!.salesId;
    }

    final authState = context.read<auth.AuthBloc>().state;
    if (authState is auth.Authenticated) {
      _selectedSalesmanId ??= authState.user.id;
    }
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStep = prefs.getInt('add_customer_step');
    if (savedStep != null && savedStep > 0 && widget.initialCustomer == null) {
      setState(() {
        _currentStep = savedStep;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(savedStep);
      });
    }
  }

  Future<void> _savePersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('add_customer_step', _currentStep);
  }

  Future<void> _clearPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('add_customer_step');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _takePhotoAndLocation() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _storePhotoFile = pickedFile;
      });
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = latLng;
        _isGettingLocation = false;
      });
      _mapController.move(latLng, 16);
      _reverseGeocode(latLng);
    } catch (e) {
      setState(() => _isGettingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan lokasi GPS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}&zoom=18&addressdetails=1');
      final response =
          await http.get(url, headers: {'User-Agent': 'WowinCRM/1.0'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _address = data['display_name'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && widget.initialCustomer == null && _selectedLocation == null) {
       // Only warn if location is missing, photo is now optional
       _getCurrentLocation();
    }
    if (_currentStep == 1 && !_formKey.currentState!.validate()) {
      return;
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _savePersistedState();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _savePersistedState();
    } else {
      context.pop();
    }
  }

  void _submitForm() {
    final customer = Customer(
      id: widget.initialCustomer?.id ?? const Uuid().v4(),
      name: _nameController.text,
      companyName: _ownerController.text, // Using companyName as Owner name here based on simplified wizard
      phone: _phoneController.text,
      address: _address,
      latitude: _selectedLocation?.latitude,
      longitude: _selectedLocation?.longitude,
      salesId: _selectedSalesmanId,
      status: widget.initialCustomer?.status ?? 'prospect',
      type: 'toko',
    );

    if (widget.initialCustomer != null) {
      context.read<CustomerBloc>().add(UpdateCustomerSubmitted(customer));
    } else {
      context.read<CustomerBloc>().add(CreateCustomerSubmitted(customer));
    }
    _clearPersistedState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _previousStep();
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          title: const Text('Tambah Toko Baru'),
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: _previousStep,
          ),
        ),
        body: BlocListener<CustomerBloc, CustomerState>(
          listener: (context, state) {
            if (state is CustomerOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Toko berhasil disimpan!'),
                    backgroundColor: _green),
              );
              context.pop();
            } else if (state is CustomerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1PhotoAndLocation(),
                    _buildStep2InputData(),
                    _buildStep3Confirmation(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: Colors.white,
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? _primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1PhotoAndLocation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Langkah 1: Foto & Lokasi',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ambil foto depan toko dan tentukan titik lokasi pada peta.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Photo Capture Area
          const Text('Foto Toko', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _takePhotoAndLocation,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _storePhotoFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: kIsWeb 
                        ? Image.network(_storePhotoFile!.path, width: double.infinity, fit: BoxFit.cover)
                        : Image.file(File(_storePhotoFile!.path), width: double.infinity, fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.camera, size: 48, color: _primary),
                        SizedBox(height: 8),
                        Text('Ambil Foto Toko', style: TextStyle(fontWeight: FontWeight.bold, color: _primary)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Map Selection Area
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Titik Lokasi Peta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(LucideIcons.locateFixed, size: 18),
                label: const Text('Lokasi Saat Ini'),
                style: TextButton.styleFrom(foregroundColor: _primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedLocation ?? _defaultLocation,
                  initialZoom: 15,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _selectedLocation = point;
                    });
                    _reverseGeocode(point);
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
                          width: 80,
                          height: 80,
                          child: const Icon(LucideIcons.mapPin, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isGettingLocation)
            const Center(child: CircularProgressIndicator())
          else if (_selectedLocation != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lokasi Terpilih:', style: TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(_address.isEmpty ? 'Mendapatkan alamat...' : _address, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep2InputData() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Langkah 2: Data Toko',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masukkan nama toko dan nama pemilik/penanggung jawab.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                labelText: 'Nama Toko / Warung',
                prefixIcon: Icon(LucideIcons.store),
              ),
              validator: (v) => v!.isEmpty ? 'Nama toko wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _ownerController,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                labelText: 'Nama Pemilik',
                prefixIcon: Icon(LucideIcons.user),
              ),
              validator: (v) => v!.isEmpty ? 'Nama pemilik wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                labelText: 'Nomor HP (Opsional)',
                prefixIcon: Icon(LucideIcons.phone),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3Confirmation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Langkah 3: Konfirmasi',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pastikan data di bawah ini sudah benar sebelum menyimpan.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_storePhotoFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                        ? Image.network(_storePhotoFile!.path, height: 150, width: double.infinity, fit: BoxFit.cover)
                        : Image.file(File(_storePhotoFile!.path), height: 150, width: double.infinity, fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 16),
                  _buildConfirmRow(LucideIcons.store, 'Nama Toko', _nameController.text),
                  const Divider(),
                  _buildConfirmRow(LucideIcons.user, 'Pemilik', _ownerController.text),
                  if (_phoneController.text.isNotEmpty) ...[
                    const Divider(),
                    _buildConfirmRow(LucideIcons.phone, 'No HP', _phoneController.text),
                  ],
                  if (_address.isNotEmpty) ...[
                    const Divider(),
                    _buildConfirmRow(LucideIcons.mapPin, 'Alamat', _address),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _currentStep == 2 ? _submitForm : _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: _currentStep == 2 ? _green : _primary,
        ),
        child: Text(
          _currentStep == 2 ? 'SIMPAN TOKO' : 'LANJUTKAN',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
