import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';

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
      final targetPath = '${tmpDir.path}/${DateTime.now().millisecondsSinceEpoch}.webp';

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
    bool isOutOfRadius = (_distanceToTarget != null && _distanceToTarget! > widget.targetRadiusMeters);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Kunjungan'),
      ),
      body: BlocListener<VisitBloc, VisitState>(
        listener: (context, state) {
          if (state is VisitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            context.pop(); // Back after success
          } else if (state is VisitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Theme.of(context).colorScheme.error),
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Status Lokasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(),
                      if (_isLoadingLocation)
                        const CircularProgressIndicator()
                      else if (_locationError != null)
                        Text(
                          _locationError!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        )
                      else if (_distanceToTarget != null) ...[
                        Text('Jarak: ${_distanceToTarget!.toStringAsFixed(1)} meter'),
                        if (isOutOfRadius)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'DI LUAR RADIUS PELANGGAN',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'DALAM RADIUS PELANGGAN',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          )
                      ],
                      TextButton.icon(
                        onPressed: _determinePosition,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Perbarui Lokasi'),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Photo Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _photoFile != null
                          ? Image.file(_photoFile!, height: 200, fit: BoxFit.cover)
                          : Container(
                              height: 200,
                              color: Colors.grey.shade200,
                              child: const Center(child: Text('Belum ada foto')),
                            ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(_photoFile == null ? 'Buka Kamera (Wajib)' : 'Ambil Ulang Foto'),
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
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              BlocBuilder<VisitBloc, VisitState>(
                builder: (context, state) {
                  final isLoading = state is VisitLoading;
                  final canSubmit = _photoFile != null && _currentPosition != null && !isLoading;

                  return ElevatedButton(
                    onPressed: canSubmit ? _submitCheckIn : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SUBMIT CHECK-IN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
