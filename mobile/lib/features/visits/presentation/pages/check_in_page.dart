import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';

class CheckInPage extends StatefulWidget {
  final String scheduleId;
  final String customerName;
  final String customerAddress;
  final double targetLat;
  final double targetLng;
  final double targetRadiusMeters;

  const CheckInPage({
    super.key,
    required this.scheduleId,
    required this.customerName,
    required this.customerAddress,
    required this.targetLat,
    required this.targetLng,
    required this.targetRadiusMeters,
  });

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final _notesController = TextEditingController();
  File? _photoFile;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String? _locationError;

  static const Color _orange = Color(0xFFE8622A);
  static const Color _navy = Color(0xFF1A237E);
  static const Color _bg = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationError = e.toString();
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final tmpDir = Directory.systemTemp;
      final targetPath =
          '${tmpDir.path}/${DateTime.now().millisecondsSinceEpoch}.webp';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        minWidth: 1024,
        minHeight: 1024,
        quality: 80,
        format: CompressFormat.webp,
      );

      if (compressedFile != null) {
        setState(() {
          _photoFile = File(compressedFile.path);
        });
      }
    }
  }

  void _submitCheckIn() {
    if (_photoFile == null || _currentPosition == null) return;

    context.read<VisitBloc>().add(
          CheckInSubmitted(
            scheduleId: widget.scheduleId,
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            photoFile: _photoFile!,
            notes: _notesController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF1A1A1A)),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Visit Check-In',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildGpsBadge(),
          ),
        ],
      ),
      body: BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFF10B981)),
            );
            context.pop();
          } else if (state is VisitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFEF4444)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerCard(),
              const SizedBox(height: 24),
              _buildPhotoHeader(),
              const SizedBox(height: 12),
              _buildCameraViewport(),
              const SizedBox(height: 20),
              _buildInstructionAlert(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'AUTOMATED SYNC ENABLED • V4.2.0',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGpsBadge() {
    final bool isLocked = _currentPosition != null;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isLocked ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLocked ? LucideIcons.mapPin : LucideIcons.loader,
              size: 14,
              color: isLocked ? const Color(0xFF065F46) : const Color(0xFFD97706),
            ),
            const SizedBox(width: 4),
            Text(
              isLocked ? 'GPS LOCKED' : 'SEARCHING...',
              style: TextStyle(
                color: isLocked ? const Color(0xFF065F46) : const Color(0xFFD97706),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.building2, color: _orange, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.customerAddress,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'MANDATORY VISIT PHOTO',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4B5563),
            letterSpacing: 0.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Required',
            style: TextStyle(
              color: _orange,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraViewport() {
    return AspectRatio(
      aspectRatio: 0.85,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: _photoFile != null
                ? FileImage(_photoFile!)
                : const NetworkImage('https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&q=80&w=800') as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: _photoFile == null ? ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken) : null,
          ),
        ),
        child: Stack(
          children: [
            // Corner Markers
            _buildCornerMarker(top: 20, left: 20, isTop: true, isLeft: true),
            _buildCornerMarker(top: 20, right: 20, isTop: true, isLeft: false),
            _buildCornerMarker(bottom: 20, left: 20, isTop: false, isLeft: true),
            _buildCornerMarker(bottom: 20, right: 20, isTop: false, isLeft: false),

            if (_photoFile == null)
              Center(
                child: Icon(
                  LucideIcons.camera,
                  color: Colors.white.withOpacity(0.5),
                  size: 64,
                ),
              ),

            // Bottom Controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircularIconBtn(LucideIcons.image),
                  GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: _orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.camera, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                  _buildCircularIconBtn(LucideIcons.refreshCw),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerMarker({double? top, double? bottom, double? left, double? right, required bool isTop, required bool isLeft}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: _orange, width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: _orange, width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: _orange, width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: _orange, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCircularIconBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildInstructionAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFedd5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, color: _orange, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'A photo of the customer\'s storefront or reception is required to verify your location. GPS timestamp will be attached to the visit record.',
              style: TextStyle(
                color: Color(0xFF9A3412),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<VisitBloc, VisitState>(
      builder: (context, state) {
        final isLoading = state is VisitLoading;
        final canSubmit = _photoFile != null && _currentPosition != null && !isLoading;

        return ElevatedButton(
          onPressed: canSubmit ? _submitCheckIn : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _orange,
            disabledBackgroundColor: _orange.withOpacity(0.5),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'SUBMIT CHECK-IN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.check, size: 14, color: Colors.white),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
