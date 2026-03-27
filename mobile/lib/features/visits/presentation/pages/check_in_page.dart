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
import '../../../../core/theme/app_colors.dart';

class CheckInPage extends StatefulWidget {
  final String scheduleId;
  final double targetLat;
  final double targetLng;
  final double targetRadiusMeters;

  const CheckInPage({
    super.key,
    required this.scheduleId,
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
  double? _distanceToTarget;
  bool _isLoadingLocation = true;
  String? _locationError;

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
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Layanan lokasi dinonaktifkan.';
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen, mohon aktifkan di pengaturan.';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.targetLat,
        widget.targetLng,
      );

      setState(() {
        _currentPosition = position;
        _distanceToTarget = distance;
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
    // WAJIB gunakan ImageSource.camera
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // Compress photo
      final tmpDir = Directory.systemTemp;
      final targetPath =
          '${tmpDir.path}/${DateTime.now().millisecondsSinceEpoch}.webp';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        minWidth: 1280,
        minHeight: 1280,
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
    bool isOutOfRadius = (_distanceToTarget != null &&
        _distanceToTarget! > widget.targetRadiusMeters);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Kunjungan'),
        scrolledUnderElevation: 0,
      ),
      body: BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
            context.pop(); // Back after success
          } else if (state is VisitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Location Info Badge
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person,
                                color: Colors.blue, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Status Lokasi',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      if (_isLoadingLocation)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        )
                      else if (_locationError != null)
                        Text(
                          _locationError!,
                          style: const TextStyle(color: AppColors.error),
                        )
                      else if (_distanceToTarget != null) ...[
                        Text(
                          'Jarak: ${_distanceToTarget!.toStringAsFixed(1)} meter',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        if (isOutOfRadius)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.error.withOpacity(0.2)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person,
                                    color: AppColors.error, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'DI LUAR RADIUS',
                                  style: TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.success.withOpacity(0.2)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person,
                                    color: AppColors.success, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'DALAM RADIUS',
                                  style: TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          )
                      ],
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _determinePosition,
                        icon: const Icon(Icons.person, size: 16),
                        label: const Text('Perbarui Lokasi'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Photo Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: _photoFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(_photoFile!,
                                    height: 200, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person,
                                      size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Belum ada foto',
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.person, size: 18),
                        label: Text(_photoFile == null
                            ? 'Ambil Foto (Wajib)'
                            : 'Ambil Ulang Foto'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Input
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  alignLabelWithHint: true,
                  hintText: 'Tambahkan catatan jika diperlukan...',
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              BlocBuilder<VisitBloc, VisitState>(
                builder: (context, state) {
                  final isLoading = state is VisitLoading;
                  final canSubmit = _photoFile != null &&
                      _currentPosition != null &&
                      !isLoading;

                  return ElevatedButton(
                    onPressed: canSubmit ? _submitCheckIn : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SUBMIT CHECK-IN',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
