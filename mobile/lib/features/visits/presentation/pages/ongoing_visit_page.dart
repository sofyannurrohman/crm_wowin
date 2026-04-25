import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/theme/app_colors.dart';

class OngoingVisitPage extends StatefulWidget {
  final String scheduleId;
  final String? customerId;
  final String? customerName;
  final String? leadId;
  final String? taskDestinationId;
  final DateTime checkInTime;
  final String? dealId;

  const OngoingVisitPage({
    super.key,
    required this.scheduleId,
    this.customerId,
    this.customerName,
    this.leadId,
    this.taskDestinationId,
    required this.checkInTime,
    this.dealId,
  });

  @override
  State<OngoingVisitPage> createState() => _OngoingVisitPageState();
}

class _OngoingVisitPageState extends State<OngoingVisitPage> {
  XFile? _notaPhoto;
  bool _isSubmitting = false;
  Position? _currentPosition;

  static const Color _emerald = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 6),
      );
      if (mounted) setState(() => _currentPosition = pos);
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null && mounted) setState(() => _currentPosition = last);
      } catch (_) {}
    }
  }

  Future<void> _takeNotaPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,       // higher quality so text on receipts is sharp
      preferredCameraDevice: CameraDevice.rear,
    );
    if (photo != null && mounted) {
      setState(() => _notaPhoto = photo);
    }
  }

  void _retakePhoto() {
    setState(() => _notaPhoto = null);
    _takeNotaPhoto();
  }

  void _submitCheckOut() async {
    if (_notaPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto nota wajib diambil sebelum submit.'),
          backgroundColor: Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    if (_currentPosition == null) {
      await _getLocation();
    }

    if (!mounted) return;
    context.read<VisitBloc>().add(
      CheckOutSubmitted(
        scheduleId: widget.scheduleId,
        latitude: _currentPosition?.latitude ?? 0.0,
        longitude: _currentPosition?.longitude ?? 0.0,
        visitResult: 'Nota foto diupload',
        nextAction: '',
        taskDestinationId: widget.taskDestinationId,
        customerId: widget.customerId,
        leadId: widget.leadId,
        dealId: widget.dealId,
        outcome: 'deal_won',
        receiptPhotoFile: _notaPhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitSuccess &&
              (state.message.contains('simpan') ||
                  state.message.contains('Berhasil') ||
                  state.message.contains('Saved') ||
                  state.message.contains('selesai'))) {
            if (mounted) {
              setState(() => _isSubmitting = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Nota berhasil diupload! Input detail di sore hari ya.'),
                backgroundColor: _emerald,
                behavior: SnackBarBehavior.floating,
              ));
              // Immediately re-fetch activities so dashboard evening section has fresh data
              final authState = context.read<AuthBloc>().state;
              final salesId = authState is Authenticated ? authState.user.id : null;
              final visitBloc = context.read<VisitBloc>();
              final router = GoRouter.of(context);
              visitBloc.add(FetchActivities(salesId: salesId));
              // Small delay so FetchActivities starts before pop
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) router.pop(true);
              });
            }
          } else if (state is VisitError) {
            if (mounted) setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: Column(
                  children: [
                    _buildInstructionCard(),
                    const SizedBox(height: 32),
                    _buildPhotoSection(),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final elapsed = now.difference(widget.checkInTime);
    final hh = elapsed.inHours.toString().padLeft(2, '0');
    final mm = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (elapsed.inSeconds % 60).toString().padLeft(2, '0');

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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('$hh:$mm:$ss', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: const Icon(LucideIcons.store, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                widget.customerName ?? 'Kunjungan',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Check-in ${DateFormat('HH:mm').format(widget.checkInTime)}',
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, color: Color(0xFF16A34A), size: 22),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cara Kerja', style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w900, fontSize: 16)),
                SizedBox(height: 6),
                Text(
                  '1. Foto nota transaksi dengan jelas\n2. Pastikan teks nota terbaca\n3. Klik "Selesai & Kirim Nota"\n4. Sore hari: input detail penjualan dari dashboard',
                  style: TextStyle(color: Color(0xFF166534), fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildPhotoSection() {
    if (_notaPhoto == null) {
      return _buildCameraButton();
    } else {
      return _buildPhotoPreview();
    }
  }

  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: _takeNotaPhoto,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 52),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: _emerald.withOpacity(0.3), width: 2),
          boxShadow: [BoxShadow(color: _emerald.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _emerald.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Icon(LucideIcons.camera, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'FOTO NOTA SEKARANG',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ketuk untuk membuka kamera',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    ).animate().scale(begin: const Offset(0.95, 0.95)).fadeIn();
  }

  Widget _buildPhotoPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('FOTO NOTA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1)),
            GestureDetector(
              onTap: _retakePhoto,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.refreshCw, size: 14, color: Color(0xFFF97316)),
                    SizedBox(width: 6),
                    Text('Foto Ulang', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.w900, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: kIsWeb
                ? Image.network(_notaPhoto!.path, width: double.infinity, fit: BoxFit.cover)
                : Image.file(File(_notaPhoto!.path), width: double.infinity, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.checkCircle2, color: Color(0xFF16A34A), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Foto terlihat jelas? Jika buram, ketuk "Foto Ulang" di atas.',
                  style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.05);
  }

  Widget _buildSubmitButton() {
    final hasPhoto = _notaPhoto != null;

    return Column(
      children: [
        if (!hasPhoto)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Ambil foto nota terlebih dahulu',
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: (hasPhoto && !_isSubmitting) ? _submitCheckOut : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _emerald,
              disabledBackgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: hasPhoto ? 0 : 0,
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(hasPhoto ? LucideIcons.send : LucideIcons.camera, color: hasPhoto ? Colors.white : Colors.grey.shade400, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        hasPhoto ? 'SELESAI & KIRIM NOTA' : 'BELUM ADA FOTO',
                        style: TextStyle(
                          color: hasPhoto ? Colors.white : Colors.grey.shade400,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
