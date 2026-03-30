import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

class AttendanceHomePage extends StatefulWidget {
  const AttendanceHomePage({super.key});

  @override
  State<AttendanceHomePage> createState() => _AttendanceHomePageState();
}

class _AttendanceHomePageState extends State<AttendanceHomePage> {
  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _navy = Color(0xFF1A237E);

  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  File? _imageFile;
  Position? _currentPosition;
  String? _address;

  @override
  void initState() {
    super.initState();
    // Start live clock
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _address = "Lokasi Berhasil Dikunci"; // Placeholder for reverse geocoding
    });
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleClockAction(bool isClockIn) {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan ambil foto selfie terlebih dahulu')),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sedang mengunci lokasi GPS...')),
      );
      return;
    }

    if (isClockIn) {
      context.read<AttendanceBloc>().add(ClockInSubmitted(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        photoPath: _imageFile!.path,
        address: _address,
      ));
    } else {
      context.read<AttendanceBloc>().add(ClockOutSubmitted(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        photoPath: _imageFile!.path,
        address: _address,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          // Refresh or Go Back
          context.pop();
        } else if (state is AttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildCameraPreview(),
              const SizedBox(height: 24),
              _buildClockSection(),
              const SizedBox(height: 24),
              _buildClockButtons(),
              const SizedBox(height: 32),
              _buildRecentActivity(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: _textPrimary),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: const Text(
        'Attendance',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.settings, color: _textPrimary, size: 22),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return GestureDetector(
      onTap: _takePhoto,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFE5D5CD),
              image: _imageFile != null
                  ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                  : const DecorationImage(
                      image: NetworkImage('https://randomuser.me/api/portraits/women/44.jpg'),
                      fit: BoxFit.cover,
                      opacity: 0.5,
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'PREVIEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_imageFile == null)
                  const Center(
                    child: Icon(LucideIcons.camera, color: Colors.white, size: 48),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: -30,
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
        ],
      ),
    );
  }

  Widget _buildClockSection() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          DateFormat('HH:mm:ss').format(_currentTime),
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMM d, yyyy').format(_currentTime),
          style: TextStyle(
            color: _textSecondary.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6ED),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.mapPin, color: _orange, size: 14),
              const SizedBox(width: 6),
              Text(
                _address ?? 'Mencari Lokasi...',
                style: const TextStyle(
                  color: _orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClockButtons() {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        final isLoading = state is AttendanceLoading;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _handleClockAction(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('CLOCK IN', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _handleClockAction(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('CLOCK OUT', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const LinearProgressIndicator(color: _orange, backgroundColor: Color(0xFFE5E7EB)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _currentPosition != null ? LucideIcons.checkCircle2 : LucideIcons.refreshCw,
                    color: _currentPosition != null ? const Color(0xFF10B981) : Colors.amber,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentPosition != null ? 'GPS Terverifikasi' : 'Mencari GPS...',
                    style: TextStyle(
                      color: _textSecondary.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  color: _orange.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            isClockIn: true,
            title: 'Clock In',
            timeStr: 'Oct 22, 2023 • 08:55 AM',
            status: 'On Time',
            statusColor: const Color(0xFF16A34A),
            statusBgColor: const Color(0xFFDCFCE7),
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            isClockIn: false,
            title: 'Clock Out',
            timeStr: 'Oct 21, 2023 • 05:12 PM',
            status: 'Normal',
            statusColor: const Color(0xFF6B7280),
            statusBgColor: const Color(0xFFF3F4F6),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required bool isClockIn,
    required String title,
    required String timeStr,
    required String status,
    required Color statusColor,
    required Color statusBgColor,
  }) {
    final iconBgColor = isClockIn ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final iconColor = isClockIn ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final iconData = isClockIn ? LucideIcons.logIn : LucideIcons.logOut;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    color: _textSecondary.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(LucideIcons.home, 'Home', false, () => context.goNamed(kRouteDashboard)),
          _buildNavItem(Icons.fingerprint, 'Attendance', true, () {}),
          _buildNavItem(LucideIcons.calendar, 'Schedule', false, () {}),
          _buildNavItem(LucideIcons.user, 'Profile', false, () => context.goNamed(kRouteProfile)),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: isActive ? _orange : const Color(0xFF9CA3AF), 
            size: 28 // slightly larger matching mock
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? _orange : const Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
