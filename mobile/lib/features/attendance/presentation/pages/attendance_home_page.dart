import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:wowin_crm/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/entities/attendance_record.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../../../visits/presentation/bloc/visit_bloc.dart';
import '../../../visits/presentation/bloc/visit_event.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../../core/services/face_detector_service.dart';
import '../../../../core/widgets/face_validation_overlay.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' as ml;

class AttendanceHomePage extends StatefulWidget {
  const AttendanceHomePage({super.key});

  @override
  State<AttendanceHomePage> createState() => _AttendanceHomePageState();
}

class _AttendanceHomePageState extends State<AttendanceHomePage> with WidgetsBindingObserver {
  // changed orange -> new green #0D8549
  static const Color _orange = Color(0xFF0D8549);
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _navy = Color(0xFF1A237E);

  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  File? _imageFile;
  String? _imagePath;
  Position? _currentPosition;
  String? _address;
  
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  List<CameraDescription> _cameras = [];
  
  final FaceDetectorService _faceDetectorService = FaceDetectorService();
  FaceValidationStatus _faceStatus = FaceValidationStatus.none;
  bool _isProcessingFrame = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start live clock
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
    _determinePosition();
    _initCamera();
    _fetchHistory();
  }

  void _fetchHistory() {
    context.read<AttendanceBloc>().add(FetchAttendanceHistory(
          month: DateTime.now().month,
          year: DateTime.now().year,
        ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      _isCameraInitialized = false;
      _cameraController?.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // Use front camera if available
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        if (!kIsWeb) _startImageStream();
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  void _startImageStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (kIsWeb) return;
    _cameraController!.startImageStream((image) async {
      if (_isProcessingFrame || _imagePath != null || !mounted) return;

      _isProcessingFrame = true;
      try {
        final inputImage = _faceDetectorService.inputImageFromCameraImage(
          image,
          _cameraController!.description,
        );

        if (inputImage != null) {
          final faces = await _faceDetectorService.detectFaces(inputImage);
          _validateFaces(faces);
        }
      } catch (e) {
        debugPrint('Frame processing error: $e');
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  void _validateFaces(List<ml.Face> faces) {
    if (!mounted) return;

    FaceValidationStatus newStatus;
    if (faces.isEmpty) {
      newStatus = FaceValidationStatus.notDetected;
    } else if (faces.length > 1) {
      newStatus = FaceValidationStatus.multipleFaces;
    } else {
      final face = faces.first;
      
      // Basic "unclear" checks:
      // 1. Check if looking relatively straight (Euler X/Y/Z)
      final bool isLookingStraight = (face.headEulerAngleY! < 20 && face.headEulerAngleY! > -20) &&
                                     (face.headEulerAngleZ! < 15 && face.headEulerAngleZ! > -15);
      
      // 2. Check eyes open probability if available
      final bool eyesOpen = (face.leftEyeOpenProbability ?? 1.0) > 0.4 &&
                            (face.rightEyeOpenProbability ?? 1.0) > 0.4;

      if (!isLookingStraight) {
        newStatus = FaceValidationStatus.lookStraight;
      } else if (!eyesOpen) {
        newStatus = FaceValidationStatus.eyesClosed;
      } else {
        // Check face size relative to frame (rough proximity check)
        // Camera medium is usually 720x480 or similar.
        final faceWidth = face.boundingBox.width;
        if (faceWidth < 100) {
          newStatus = FaceValidationStatus.tooFar;
        } else if (faceWidth > 400) {
          newStatus = FaceValidationStatus.tooClose;
        } else {
          newStatus = FaceValidationStatus.valid;
        }
      }
    }

    if (_faceStatus != newStatus) {
      setState(() {
        _faceStatus = newStatus;
      });
    }
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      debugPrint('Take photo error: Camera not initialized');
      return;
    }

    if (_imagePath == null && _faceStatus != FaceValidationStatus.valid) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wajah tidak jelas. Cari posisi atau cahaya lebih baik di depan toko.')),
      );
      return;
    }

    if (_cameraController!.value.isTakingPicture) {
      debugPrint('Take photo error: Camera is already taking picture');
      return;
    }

    try {
      // Stop image stream during capture
      await _cameraController!.stopImageStream();
      
      final image = await _cameraController!.takePicture();
      setState(() {
        _imagePath = image.path;
        if (!kIsWeb) {
          _imageFile = File(image.path);
        }
      });
    } catch (e) {
      debugPrint('Error taking photo: $e');
      // Restart stream on error if needed
      _startImageStream();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _isCameraInitialized = false;
    _cameraController?.dispose();
    _cameraController = null;
    _faceDetectorService.dispose();
    super.dispose();
  }

  void _handleClockAction(bool isClockIn) {
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.takeSelfieError)),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.locatingGpsWait)),
      );
      return;
    }

    if (isClockIn) {
      context.read<AttendanceBloc>().add(ClockInSubmitted(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        photoPath: _imagePath!,
        address: _address,
      ));
    } else {
      context.read<AttendanceBloc>().add(ClockOutSubmitted(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        photoPath: _imagePath!,
        address: _address,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.green),
          );
          // Refresh or Go Back
          // Refresh is now handled by Bloc auto-adding Fetch event
          context.read<VisitBloc>().add(const FetchActivities());
        } else if (state is AttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        drawer: const AppSidebar(),
        appBar: _buildAppBar(context, l10n),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildCameraPreview(l10n),
              const SizedBox(height: 48),
              _buildClockSection(l10n),
              const SizedBox(height: 32),
              _buildClockButtons(l10n),
              const SizedBox(height: 32),
              _buildRecentActivity(l10n),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(LucideIcons.menu, color: _textPrimary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      centerTitle: true,
      title: Text(
        l10n.attendance,
        style: const TextStyle(
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

  Widget _buildCameraPreview(AppLocalizations l10n) {
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
              // previous warm color replaced with subtle greenish placeholder
              color: const Color(0xFFE5F3EA),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_imagePath != null)
                    kIsWeb 
                    ? Image.network(
                        _imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Web Image build error: $error');
                          return const Center(
                            child: Icon(LucideIcons.imageOff,
                                color: Colors.white70, size: 48),
                          );
                        },
                      )
                    : Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Image build error: $error');
                          return const Center(
                            child: Icon(LucideIcons.imageOff,
                                color: Colors.white70, size: 48),
                          );
                        },
                      )
                  else if (_isCameraInitialized && _cameraController != null && _cameraController!.value.isInitialized)
                    Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(_cameraController!),
                        Center(
                          child: FaceValidationOverlay(status: _faceStatus),
                        ),
                      ],
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(color: _orange),
                    ),

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
                          Text(
                            l10n.preview,
                            style: const TextStyle(
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
                  if (_imagePath != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(LucideIcons.refreshCw, color: Colors.white),
                      onPressed: () => setState(() {
                          _imageFile = null;
                          _imagePath = null;
                          _faceStatus = FaceValidationStatus.none;
                          _startImageStream();
                        }),
                      ),
                    ),
                  if (_imagePath == null)
                    const Center(
                      child: Icon(LucideIcons.camera, color: Colors.white70, size: 48),
                    ),
                ],
              ),
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
                child: const Icon(LucideIcons.camera,
                    color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockSection(AppLocalizations l10n) {
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
          DateFormat('EEEE, MMM d, yyyy', l10n.localeName).format(_currentTime),
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
            color: const Color(0xFFEFFBF5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.mapPin, color: _orange, size: 14),
              const SizedBox(width: 6),
              Text(
                _address ?? l10n.locatingGps,
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

  Widget _buildClockButtons(AppLocalizations l10n) {
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
                      onPressed:
                          isLoading ? null : () => _handleClockAction(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.clockIn,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : () => _handleClockAction(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.clockOut,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const LinearProgressIndicator(
                    color: _orange, backgroundColor: Color(0xFFE5E7EB)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _currentPosition != null
                        ? LucideIcons.checkCircle2
                        : LucideIcons.refreshCw,
                    color: _currentPosition != null
                        ? const Color(0xFF10B981)
                        : Colors.amber,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentPosition != null
                        ? l10n.gpsVerified
                        : l10n.locatingGps,
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

  Widget _buildRecentActivity(AppLocalizations l10n) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        List<AttendanceRecord> history = [];
        if (state is AttendanceHistoryLoaded) {
          history = state.history;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentActivity,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pushNamed(kRouteAttendanceHistory),
                    child: Text(
                      l10n.viewAll,
                      style: TextStyle(
                        color: _orange.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (history.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Belum ada aktivitas hari ini',
                      style: TextStyle(color: _textSecondary.withOpacity(0.5)),
                    ),
                  ),
                )
              else
                ...history.take(5).map((record) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildActivityCard(
                        isClockIn: record.type.toLowerCase().contains('in'),
                        title: record.type.toLowerCase().contains('in')
                            ? l10n.clockIn
                            : l10n.clockOut,
                        timeStr: DateFormat('MMM d, yyyy • HH:mm')
                            .format(record.timestampAt),
                        status: l10n.normal,
                        statusColor: record.type.toLowerCase().contains('in')
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF6B7280),
                        statusBgColor: record.type.toLowerCase().contains('in')
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF3F4F6),
                      ),
                    )),
            ],
          ),
        );
      },
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

}
