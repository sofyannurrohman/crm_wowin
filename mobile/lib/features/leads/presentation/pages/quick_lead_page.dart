import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import '../../../leads/presentation/bloc/lead_bloc.dart';
import '../../../leads/presentation/bloc/lead_event.dart';
import '../../../leads/presentation/bloc/lead_state.dart';
import '../../../leads/domain/entities/lead.dart';
import '../../../../core/theme/app_colors.dart';

class QuickLeadPage extends StatefulWidget {
  const QuickLeadPage({super.key});

  @override
  State<QuickLeadPage> createState() => _QuickLeadPageState();
}

class _QuickLeadPageState extends State<QuickLeadPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  Position? _currentPosition;
  bool _isLoadingLoc = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLoc = true);
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = pos;
        _isLoadingLoc = false;
      });
    } catch (e) {
      setState(() => _isLoadingLoc = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mendapatkan lokasi GPS')));
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _currentPosition != null) {
      setState(() => _isSubmitting = true);
      
      final lead = Lead(
        id: '',
        title: _nameController.text,
        name: _nameController.text,
        phone: _phoneController.text,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        source: 'direct',
        status: 'prospect',
      );

      context.read<LeadBloc>().add(CreateLeadSubmitted(lead));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quick Lead (Pinpoint)', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocListener<LeadBloc, LeadState>(
        listener: (context, state) {
          if (state is LeadOperationSuccess) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead berhasil didaftarkan!')));
            context.pop();
          } else if (state is LeadError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationCard(),
                const SizedBox(height: 32),
                const Text('DETAIL PROSPEK', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Toko / Pelanggan',
                    prefixIcon: const Icon(LucideIcons.store),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon (Opsional)',
                    prefixIcon: const Icon(LucideIcons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isLoadingLoc || _isSubmitting) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: (_isLoadingLoc || _isSubmitting)
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('DAFTARKAN SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.mapPin, color: Colors.blue, size: 32),
          const SizedBox(height: 12),
          const Text('KORDINAT GPS SAAT INI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          if (_isLoadingLoc)
            const Text('Mendeteksi lokasi...', style: TextStyle(color: Colors.grey, fontSize: 12))
          else if (_currentPosition != null)
            Text(
              '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blue, fontSize: 16),
            )
          else
            const Text('GPS Tidak Terdeteksi', style: TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ),
    );
  }
}
