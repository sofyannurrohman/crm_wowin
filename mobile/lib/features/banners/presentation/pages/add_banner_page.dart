import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../leads/domain/entities/lead.dart';
import '../../../customers/domain/entities/customer.dart';
import '../bloc/banner_bloc.dart';
import '../bloc/banner_event.dart';
import '../bloc/banner_state.dart';

class AddBannerPage extends StatefulWidget {
  final Lead? lead;
  final Customer? customer;

  const AddBannerPage({super.key, this.lead, this.customer});

  @override
  State<AddBannerPage> createState() => _AddBannerPageState();
}

class _AddBannerPageState extends State<AddBannerPage> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _contentController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _addressController = TextEditingController();

  File? _photo;
  LatLng? _location;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.lead != null) {
      _shopNameController.text = widget.lead!.name;
      _addressController.text = widget.lead!.address ?? '';
      if (widget.lead!.latitude != null && widget.lead!.longitude != null) {
        _location = LatLng(widget.lead!.latitude!, widget.lead!.longitude!);
      }
    } else if (widget.customer != null) {
      _shopNameController.text = widget.customer!.companyName ?? widget.customer!.name;
      _addressController.text = widget.customer!.address ?? '';
      if (widget.customer!.latitude != null && widget.customer!.longitude != null) {
        _location = LatLng(widget.customer!.latitude!, widget.customer!.longitude!);
      }
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _contentController.dispose();
    _dimensionsController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_location == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi belum ditentukan')),
        );
        return;
      }

      context.read<BannerBloc>().add(CreateBannerSubmitted(
            shopName: _shopNameController.text,
            content: _contentController.text,
            dimensions: _dimensionsController.text,
            latitude: _location!.latitude,
            longitude: _location!.longitude,
            address: _addressController.text,
            photo: _photo,
            leadId: widget.lead?.id,
            customerId: widget.customer?.id,
          ));
    }
  }

  void _launchWhatsApp(String message) async {
    final phone = '6281239496328'; // Formatted from 081239496328
    final url = 'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback to web link
      final webUrl = 'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _showSuccessDialog(dynamic banner) {
    final message = '''
*DATA SURVEY SPANDUK WOWIN*
Nama Warung: ${banner.shopName}
Isi Spanduk: ${banner.content}
Ukuran: ${banner.dimensions}
Lokasi: ${banner.address}
Link Maps: https://www.google.com/maps/search/?api=1&query=${banner.latitude},${banner.longitude}
''';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(LucideIcons.checkCircle, color: Colors.green),
            SizedBox(width: 12),
            Text('Berhasil Disimpan'),
          ],
        ),
        content: const Text('Data survey spanduk telah disimpan ke sistem. Teruskan data ini ke tim design melalui WhatsApp?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop(); // Back to detail
            },
            child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _launchWhatsApp(message);
              context.pop(); // Back to detail
            },
            icon: const Icon(LucideIcons.messageSquare),
            label: const Text('Kirim WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Survey Spanduk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocConsumer<BannerBloc, BannerState>(
        listener: (context, state) {
          if (state is BannerSuccess) {
            _showSuccessDialog(state.banner);
          } else if (state is BannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(LucideIcons.store, 'Informasi Warung'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Nama Warung',
                    controller: _shopNameController,
                    hint: 'Masukkan nama warung',
                    prefixIcon: LucideIcons.home,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(LucideIcons.layout, 'Detail Spanduk'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Isi Spanduk/Keterangan',
                    controller: _contentController,
                    hint: 'Contoh: Menu Ayam Geprek & Minuman',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Ukuran (Panjang x Lebar)',
                    controller: _dimensionsController,
                    hint: 'Contoh: 3m x 1m',
                    prefixIcon: LucideIcons.maximize,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(LucideIcons.camera, 'Foto Lokasi'),
                  const SizedBox(height: 16),
                  _buildImagePicker(),
                  const SizedBox(height: 32),
                  _buildSectionHeader(LucideIcons.mapPin, 'Lokasi Pemasangan'),
                  const SizedBox(height: 16),
                  _buildLocationInfo(),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: state is BannerLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: state is BannerLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Simpan Data Survey',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _takePhoto,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: _photo != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_photo!, fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.camera, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Ambil Foto Spanduk/Lokasi', style: TextStyle(color: Colors.grey)),
                ],
              ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.mapPin, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Koordinat GPS', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  _location != null
                      ? '${_location!.latitude.toStringAsFixed(6)}, ${_location!.longitude.toStringAsFixed(6)}'
                      : 'Lokasi belum tersedia',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_addressController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _addressController.text,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (_location == null)
            TextButton(
              onPressed: () {
                // Future: Integrate manual location picker if needed
              },
              child: const Text('Cari Lokasi'),
            ),
        ],
      ),
    );
  }
}
