import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:http/http.dart' as http;
import '../../../../core/utils/image_utils.dart';
import '../../../../core/services/watermark_service.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/services/face_detector_service.dart';
import '../../../../core/widgets/face_validation_overlay.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' as ml;
import 'package:intl/intl.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../products/domain/entities/product.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart' as auth;
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../../../auth/presentation/bloc/auth_event.dart' as auth;
import '../../../auth/domain/entities/user_entity.dart' as user_ent;

class CheckInPage extends StatefulWidget {
  final String scheduleId;
  final String? customerId;
  final String? customerName;
  final String? customerAddress;
  final double? targetLat;
  final double? targetLng;
  final double targetRadiusMeters;
  final String? dealId;
  final String? leadId;
  final String? taskDestinationId;

  const CheckInPage({
    super.key,
    required this.scheduleId,
    this.customerId,
    this.leadId,
    this.customerName,
    this.customerAddress,
    this.targetLat,
    this.targetLng,
    this.targetRadiusMeters = 200.0,
    this.dealId,
    this.taskDestinationId,
  });

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final PageController _pageController = PageController();
  final TextEditingController _notesController = TextEditingController();
  final MapController _mapController = MapController();

  // Wizard State — now 5 steps: Select, Proximity, Photo (store), Photo (selfie), Summary
  int _currentStep = 0;
  Customer? _selectedCustomer;
  Position? _currentPosition;
  String? _currentAddress;
  XFile? _storefrontPhoto;
  Uint8List? _storefrontBytes;
  XFile? _selfiePhoto;
  Uint8List? _selfieBytes;
  DateTime? _checkInTime;

  // Product Deal State
  bool _isProductDeal = false;
  List<Map<String, dynamic>> _selectedDealItems = [];

  // Camera State
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  List<CameraDescription> _cameras = [];
  bool _isCapturing = false;
  bool _isWatermarking = false;

  // GPS Override
  String? _overrideReason;
  int _gpsSecondsElapsed = 0;
  bool _showOverrideButton = false;
  Timer? _gpsTimer;

  // Live GPS tracking
  StreamSubscription<Position>? _positionStreamSubscription;

  // OSRM Route
  List<ll.LatLng> _routePoints = [];

  final FaceDetectorService _faceDetectorService = FaceDetectorService();
  FaceValidationStatus _faceStatus = FaceValidationStatus.none;
  bool _isProcessingFrame = false;

  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);
  static const int _totalSteps = 5; // 0=Select, 1=Proximity, 2=Storefront, 3=Selfie, 4=Summary

  @override
  void initState() {
    super.initState();
    _checkInTime = DateTime.now();
    _initWizard();
    if (!kIsWeb) {
      _determinePosition();
    }
    _initializeCamera();
    _startGpsTimer();
    _startLiveTracking();
  }

  void _startLiveTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // update every 10 meters moved
    );
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (!mounted) return;
        setState(() => _currentPosition = position);
        // Re-fetch route when user moves significantly
        if (_selectedCustomer?.latitude != null) _fetchRoute();
      },
      onError: (e) => debugPrint('Live tracking error: $e'),
    );
  }

  void _startGpsTimer() {
    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _gpsSecondsElapsed++;
        if (_gpsSecondsElapsed >= 15) _showOverrideButton = true;
      });
    });
  }

  void _initWizard() {
    if (widget.customerName != null && widget.targetLat != null) {
      _selectedCustomer = Customer(
        id: widget.customerId ?? 'external',
        name: widget.customerName!,
        address: widget.customerAddress,
        latitude: widget.targetLat,
        longitude: widget.targetLng,
      );
      _currentStep = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(1);
        _fetchRoute();
      });
    }
  }

  Future<void> _initializeCamera({bool useFront = false}) async {
    // kIsWeb no longer returns early — we want the camera to work in Chrome!
    if (!mounted) return;

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('No cameras found');
        return;
      }

      await _cameraController?.dispose();
      setState(() {
        _cameraController = null;
        _isCameraInitialized = false;
      });

      // On Web, a small delay helps the browser release the hardware from the previous session
      if (kIsWeb) await Future.delayed(const Duration(milliseconds: 300));

      // Prioritize cameras based on useFront
      List<CameraDescription> candidates = [];
      if (useFront) {
        candidates.addAll(_cameras.where((c) => c.lensDirection == CameraLensDirection.front));
        candidates.addAll(_cameras.where((c) => c.lensDirection != CameraLensDirection.front));
      } else {
        candidates.addAll(_cameras.where((c) => c.lensDirection == CameraLensDirection.back));
        candidates.addAll(_cameras.where((c) => c.lensDirection != CameraLensDirection.back));
      }
      if (candidates.isEmpty) candidates = _cameras;

      CameraException? lastEx;
      for (var camera in candidates) {
        try {
          _cameraController = CameraController(
            camera, 
            ResolutionPreset.medium, 
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.jpeg, // jpeg is safer for web capture
          );
          
          await _cameraController!.initialize();
          lastEx = null; // Success
          break;
        } on CameraException catch (e) {
          debugPrint('Failed to init camera ${camera.name}: ${e.code}');
          lastEx = e;
          if (e.code == 'cameraNotReadable' || e.code == 'CameraAccessDenied') {
            await _cameraController?.dispose();
            _cameraController = null;
            continue; // Try next camera
          }
          rethrow;
        }
      }

      if (lastEx != null) throw lastEx;

      if (mounted && _cameraController != null) { 
        setState(() => _isCameraInitialized = true);
        // Image stream (Face detection) currently only supported on native
        if (useFront && !kIsWeb) _startImageStream();
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        String msg = 'Gagal membuka kamera.';
        if (e is CameraException) {
          if (e.code == 'cameraNotReadable') msg = 'Kamera sedang digunakan aplikasi lain atau tidak terbaca.';
          if (e.code == 'CameraAccessDenied') msg = 'Izin kamera ditolak. Silakan cek pengaturan browser.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  void _startImageStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized || kIsWeb) return;
    
    _cameraController!.startImageStream(_processCameraImage);
  }

  void _processCameraImage(CameraImage image) async {
    if (kIsWeb || _isProcessingFrame || _currentStep != 3) return;
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
      
      final bool isLookingStraight = (face.headEulerAngleY! < 20 && face.headEulerAngleY! > -20) &&
                                     (face.headEulerAngleZ! < 15 && face.headEulerAngleZ! > -15);
      
      final bool eyesOpen = (face.leftEyeOpenProbability ?? 1.0) > 0.4 &&
                            (face.rightEyeOpenProbability ?? 1.0) > 0.4;

      if (!isLookingStraight) {
        newStatus = FaceValidationStatus.lookStraight;
      } else if (!eyesOpen) {
        newStatus = FaceValidationStatus.eyesClosed;
      } else {
        final faceWidth = face.boundingBox.width;
        if (faceWidth < 120) {
          newStatus = FaceValidationStatus.tooFar;
        } else if (faceWidth > 380) {
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
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() => _currentPosition = position);
        if (_selectedCustomer?.latitude != null) _fetchRoute();
        _reverseGeocode(position);
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _reverseGeocode(Position pos) async {
    try {
      final res = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${pos.latitude}&lon=${pos.longitude}&format=json'),
        headers: {'User-Agent': 'wowin_crm_mobile'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() => _currentAddress = data['display_name']);
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchRoute() async {
    if (_currentPosition == null || _selectedCustomer?.latitude == null) return;
    try {
      final start = '${_currentPosition!.longitude},${_currentPosition!.latitude}';
      final end = '${_selectedCustomer!.longitude},${_selectedCustomer!.latitude}';
      final url = 'http://router.project-osrm.org/route/v1/driving/$start;$end?geometries=geojson&overview=full';

      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        if (mounted) {
          setState(() {
            _routePoints = coords.map<ll.LatLng>((c) => ll.LatLng(c[1].toDouble(), c[0].toDouble())).toList();
          });
        }
      }
    } catch (_) {
      // Route fetch failed silently — map still shows without route
    }
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    _positionStreamSubscription?.cancel();
    _pageController.dispose();
    _notesController.dispose();
    _mapController.dispose();
    _cameraController?.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  void _showOverrideDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Manual GPS Override', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GPS sulit ditemukan. Masukkan alasan untuk melanjutkan kunjungan secara manual.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Contoh: Sinyal buruk di dalam gedung',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('BATAL')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _overrideReason = controller.text);
                Navigator.pop(context);
                _gpsTimer?.cancel();
                _nextStep();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _orange),
            child: const Text('VERIFIKASI MANUAL', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      // Switch to front camera for selfie step
      if (_currentStep == 3) _initializeCamera(useFront: true);
      if (_currentStep == 2) _initializeCamera(useFront: false);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      if (_currentStep == 2) _initializeCamera(useFront: false);
    } else {
      context.pop();
    }
  }

  Future<void> _takePhoto({required bool isStorefront}) async {
    if (!_isCameraInitialized || _cameraController == null || _isCapturing) return;

    if (!isStorefront && _selfieBytes == null && !kIsWeb && _faceStatus != FaceValidationStatus.valid) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wajah tidak jelas. Cari posisi atau cahaya lebih baik di depan toko.')),
      );
      return;
    }

    setState(() => _isCapturing = true);
    try {
      if (!isStorefront && !kIsWeb) {
        await _cameraController!.stopImageStream();
      }
      final photo = await _cameraController!.takePicture();
      final bytes = await photo.readAsBytes();
      
      // 1. Watermark first (needs position)
      setState(() => _isWatermarking = true);
      final watermarkedBytes = await WatermarkService.addAddressWatermark(bytes, _currentPosition);
      
      // 2. Compress after watermark
      final compressedBytes = await ImageUtils.compressImage(watermarkedBytes);
      
      setState(() {
        _isWatermarking = false;
        if (isStorefront) {
          _storefrontPhoto = XFile.fromData(compressedBytes, name: photo.name);
          _storefrontBytes = compressedBytes;
        } else {
          _selfiePhoto = XFile.fromData(compressedBytes, name: photo.name);
          _selfieBytes = compressedBytes;
        }
      });
      _nextStep();
    } catch (e) {
      debugPrint('Photo capture error: $e');
      if (mounted) setState(() => _isWatermarking = false);
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _submitCheckIn() {
    if (_storefrontBytes == null || _selfieBytes == null || _currentPosition == null || _selectedCustomer == null) return;

    context.read<VisitBloc>().add(
      CheckInSubmitted(
        scheduleId: widget.scheduleId,
        latitude: _currentPosition?.latitude ?? 0.0,
        longitude: _currentPosition?.longitude ?? 0.0,
        photoFile: _storefrontPhoto!,
        selfiePhotoFile: _selfiePhoto!,
        notes: _notesController.text,
        dealId: widget.dealId,
        overrideReason: _overrideReason,
        customerId: (_selectedCustomer?.id == 'external' || _selectedCustomer?.id == null) ? null : _selectedCustomer!.id,
        leadId: widget.leadId,
        customerName: _selectedCustomer?.name,
        taskDestinationId: widget.taskDestinationId,
        dealItems: _isProductDeal ? _selectedDealItems : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStepSelection(),
                _buildStepProximity(),
                _buildCameraStep(isStorefront: true),
                _buildCameraStep(isStorefront: false),
                _buildStepSummary(),
              ],
            ),
          ),
          if (_isWatermarking)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'Menambahkan Watermark Alamat...',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.x, color: Color(0xFF374151)),
        onPressed: _prevStep,
      ),
      centerTitle: true,
      title: Column(
        children: [
          const Text('Verifikasi Kedatangan', style: TextStyle(color: Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.w800)),
          Text(_getStepTitle(), style: const TextStyle(color: _orange, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'PILIH PELANGGAN';
      case 1: return 'VERIFIKASI LOKASI';
      case 2: return 'FOTO TOKO / LOKASI';
      case 3: return 'SELFIE VERIFIKASI';
      case 4: return 'REVIEW & SUBMIT';
      default: return '';
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          Container(height: 4, width: double.infinity, color: const Color(0xFFF3F4F6)),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            width: MediaQuery.of(context).size.width * ((_currentStep + 1) / _totalSteps),
            decoration: const BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(2)),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 0: Customer Selection ─────────────────────────
  Widget _buildStepSelection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari pelanggan...',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (val) => context.read<CustomerBloc>().add(FetchCustomers(query: val)),
          ),
        ),
        Expanded(
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerLoading) return const Center(child: CircularProgressIndicator(color: _orange));
              if (state is CustomersLoaded) {
                if (state.customers.isEmpty) {
                  return const Center(child: Text('Tidak ada pelanggan ditemukan'));
                }
                return ListView.builder(
                  itemCount: state.customers.length,
                  itemBuilder: (context, index) {
                    final c = state.customers[index];
                    final isSelected = _selectedCustomer?.id == c.id;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? _orange : const Color(0xFFF3F4F6),
                        child: Icon(LucideIcons.building, color: isSelected ? Colors.white : _orange),
                      ),
                      title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(c.address ?? 'No address'),
                      trailing: isSelected ? const Icon(LucideIcons.checkCircle2, color: _orange) : null,
                      onTap: () {
                        // Ownership check
                        final authState = context.read<auth.AuthBloc>().state;
                        final currentUser = (authState is auth.Authenticated) ? authState.user : null;
                        final bool isOwner = currentUser != null && (c.salesId == currentUser.id);
                        final bool isAdmin = currentUser?.role == 'admin';
                        final bool isLocked = !isOwner && !isAdmin;

                        if (isLocked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pelanggan ini dimiliki oleh ${c.salesmanName ?? "salesman lain"}. Anda tidak dapat mengunjungi pelanggan ini.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setState(() => _selectedCustomer = c);
                        _fetchRoute();
                        _nextStep();
                      },
                    );
                  },
                );
              }
              return const Center(child: Text('No customers found'));
            },
          ),
        ),
      ],
    );
  }

  // ── STEP 1: Proximity + OSRM Route ────────────────────
  Widget _buildStepProximity() {
    final dist = (_currentPosition != null && _selectedCustomer?.latitude != null)
        ? Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            _selectedCustomer!.latitude!,
            _selectedCustomer!.longitude!,
          )
        : null;

    final isWithinRadius = dist != null && dist <= widget.targetRadiusMeters;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ── Map with route polyline ──────────────────────
          Container(
            height: 260,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedCustomer?.latitude != null
                      ? ll.LatLng(_selectedCustomer!.latitude!, _selectedCustomer!.longitude!)
                      : const ll.LatLng(0, 0),
                  initialZoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.wowin.crm',
                  ),
                  // OSRM Route Polyline
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 4.0,
                          color: const Color(0xFF3B82F6),
                        ),
                      ],
                    ),
                  // Proximity radius circle
                  if (_selectedCustomer?.latitude != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: ll.LatLng(_selectedCustomer!.latitude!, _selectedCustomer!.longitude!),
                          radius: widget.targetRadiusMeters,
                          useRadiusInMeter: true,
                          color: _orange.withOpacity(0.12),
                          borderColor: _orange.withOpacity(0.5),
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                  // Markers
                  MarkerLayer(
                    markers: [
                      if (_selectedCustomer?.latitude != null)
                        Marker(
                          point: ll.LatLng(_selectedCustomer!.latitude!, _selectedCustomer!.longitude!),
                          width: 40,
                          height: 40,
                          child: const Icon(LucideIcons.mapPin, color: _orange, size: 30),
                        ),
                      if (_currentPosition != null)
                        Marker(
                          point: ll.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          width: 32,
                          height: 32,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: const Center(child: CircleAvatar(radius: 5, backgroundColor: Colors.blue)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Route badge ─────────────────────────────────
          if (_routePoints.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.navigation, size: 12, color: Color(0xFF3B82F6)),
                  SizedBox(width: 6),
                  Text('Rute optimal ditampilkan', style: TextStyle(fontSize: 11, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
                ],
              ),
            ),

          const SizedBox(height: 16),

          if (widget.dealId != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.briefcase, size: 14, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('KUNJUNGAN UNTUK DEAL', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          
          Text(_selectedCustomer?.name ?? 'Unknown', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.mapPin, size: 16, color: isWithinRadius ? Colors.green : Colors.amber),
              const SizedBox(width: 4),
              Text(
                dist != null ? '${dist.toStringAsFixed(1)}m dari target' : 'Menghitung jarak...',
                style: TextStyle(color: isWithinRadius ? Colors.green : Colors.amber, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (!isWithinRadius && dist != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.alertTriangle, color: Colors.amber, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'DI LUAR RADIUS: Kunjungan akan ditandai untuk peninjauan.',
                      style: TextStyle(color: Color(0xFF92400E), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          if (isWithinRadius)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 20, spreadRadius: 10)],
              ),
              child: const Icon(LucideIcons.checkCircle, color: Colors.green, size: 72)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1000.ms)
                  .shimmer(delay: 500.ms, duration: 2000.ms, color: Colors.white.withOpacity(0.4)),
            ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              // Ownership check in proximity step as well (extra safety)
              final authState = context.read<auth.AuthBloc>().state;
              final currentUser = (authState is auth.Authenticated) ? authState.user : null;
              final bool isOwner = currentUser != null && (_selectedCustomer?.salesId == currentUser.id);
              final bool isAdmin = currentUser?.role == 'admin';
              final bool isLocked = !isOwner && !isAdmin && _selectedCustomer?.id != 'external';

              if (isLocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Akses ditolak: Dimiliki oleh ${_selectedCustomer?.salesmanName ?? "salesman lain"}.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (dist != null || _overrideReason != null) {
                _nextStep();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isWithinRadius ? _orange : const Color(0xFF4B5563),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _overrideReason != null ? 'LANJUT (OVERRIDE)' : (isWithinRadius ? 'LANJUT KE FOTO' : 'LANJUT DENGAN PERINGATAN'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          if (!isWithinRadius && _showOverrideButton && _overrideReason == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: _showOverrideDialog,
                icon: const Icon(LucideIcons.shieldAlert, size: 16),
                label: const Text('Manual Override', style: TextStyle(color: _orange, fontWeight: FontWeight.bold)),
              ),
            ),

          if (!isWithinRadius && _overrideReason == null)
            TextButton(
              onPressed: _determinePosition,
              child: const Text('Refresh GPS', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  // ── STEP 2 & 3: Camera (Storefront / Selfie) ───────────
  Widget _buildCameraStep({required bool isStorefront}) {
    final capturedBytes = isStorefront ? _storefrontBytes : _selfieBytes;
    final title = isStorefront ? 'Foto Depan Toko / Lokasi' : 'Selfie dengan Pelanggan';
    final hint = isStorefront ? 'Ambil foto yang jelas dari depan toko' : 'Foto bersama pelanggan sebagai bukti pertemuan';

    return Stack(
      children: [
        if (_isCameraInitialized && _cameraController != null)
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController!),
                if (!isStorefront)
                  Center(
                    child: FaceValidationOverlay(status: _faceStatus),
                  ),
              ],
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: _orange)),

        // Frame guide overlay
        Center(
          child: Container(
            width: isStorefront ? double.infinity : 260,
            height: isStorefront ? double.infinity : 340,
            margin: isStorefront ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
              borderRadius: BorderRadius.circular(isStorefront ? 0 : 20),
            ),
          ),
        ),

        // Dark gradient at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
          ),
        ),

        // Controls
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, shadows: [Shadow(blurRadius: 8, color: Colors.black)])),
              const SizedBox(height: 6),
              Text(hint, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, shadows: const [Shadow(blurRadius: 4, color: Colors.black)])),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _isCapturing ? null : () => _takePhoto(isStorefront: isStorefront),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: _isCapturing ? Colors.white.withOpacity(0.5) : Colors.transparent,
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: _isCapturing ? 40 : 60,
                      width: _isCapturing ? 40 : 60,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ),
              if (capturedBytes != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => setState(() {
                    if (isStorefront) {
                      _storefrontPhoto = null;
                    } else {
                      _selfiePhoto = null;
                      _faceStatus = FaceValidationStatus.none; // Fix: use enum directly or helper
                      _startImageStream();
                    }
                  }),
                  icon: const Icon(LucideIcons.refreshCw, size: 14, color: Colors.white70),
                  label: const Text('Ambil Ulang', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── STEP 4: Summary & Submit (Sales Activity Style)
  Widget _buildStepSummary() {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy (HH:mm)', 'id_ID');
    final checkInTimeStr = _checkInTime != null ? dateFormat.format(_checkInTime!) : '-';
    
    // Calculate distance for report
    double? dist;
    if (_currentPosition != null && _selectedCustomer?.latitude != null) {
      dist = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _selectedCustomer!.latitude!,
        _selectedCustomer!.longitude!,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Header
          _buildReportHeader(),
          const SizedBox(height: 24),

          // Metadata Section
          _buildActivitySection(
            title: 'DATA KUNJUNGAN',
            icon: LucideIcons.fileText,
            color: Colors.blue,
            children: [
              _buildReportRow('Tipe', 'Check-In'),
              _buildReportRow('Waktu', checkInTimeStr),
              _buildReportRow('Target', _selectedCustomer?.name ?? '-', isBold: true),
              _buildReportRow('Petugas', 'Sales User'),
            ],
          ),
          const SizedBox(height: 16),

          // Location Section
          _buildActivitySection(
            title: 'VERIFIKASI LOKASI',
            icon: LucideIcons.mapPin,
            color: Colors.redAccent,
            children: [
              Text(
                _currentAddress ?? 'Alamat tidak ditemukan',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniMetric(
                    'Jarak', 
                    dist != null ? '${dist.toStringAsFixed(1)}m' : '-',
                    dist != null && dist <= widget.targetRadiusMeters ? Colors.green : Colors.orange,
                  ),
                  _buildMiniMetric('Status', _overrideReason != null ? 'OVERRIDE' : 'VERIFIED', _overrideReason != null ? Colors.orange : Colors.green),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Evidence Section
          _buildActivitySection(
            title: 'BUKTI VISUAL',
            icon: LucideIcons.camera,
            color: Colors.purple,
            children: [
              Row(
                children: [
                  if (_storefrontBytes != null)
                    _buildReportImage('FOTO TOKO', _storefrontBytes!),
                  if (_storefrontBytes != null && _selfieBytes != null) const SizedBox(width: 12),
                  if (_selfieBytes != null)
                    _buildReportImage('SELFIE', _selfieBytes!),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Product Deal Section
          _buildProductDealSection(),
          const SizedBox(height: 16),

          // Notes Section
          _buildActivitySection(
            title: 'CATATAN HASIL KUNJUNGAN',
            icon: LucideIcons.edit3,
            color: Colors.amber[800]!,
            children: [
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tuliskan poin penting kunjungan...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Submit Button
          BlocConsumer<VisitBloc, VisitState>(
            listener: (context, state) {
              if (state is VisitSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
                context.pop();
              } else if (state is VisitError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
              }
            },
            builder: (context, state) {
              final isLoading = state is VisitLoading;
              return ElevatedButton(
                onPressed: isLoading ? null : _submitCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SUBMIT LAPORAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
              );
            },
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildReportHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.fileCheck, color: _orange, size: 28),
            const SizedBox(width: 12),
            Text(
              'LAPORAN AKTIVITAS'.toUpperCase(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A), letterSpacing: 1),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(height: 3, width: 80, decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _buildActivitySection({required String title, required IconData icon, required Color color, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color, letterSpacing: 1)),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildReportImage(String label, Uint8List bytes) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(bytes, height: 120, width: double.infinity, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDealSection() {
    double total = 0;
    for (var item in _selectedDealItems) {
      total += (item['unit_price'] as double) * (item['quantity'] as double);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isProductDeal ? Colors.indigo[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isProductDeal ? Colors.indigo[200]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.shoppingBag, size: 16, color: _isProductDeal ? Colors.indigo : Colors.grey),
                  const SizedBox(width: 8),
                  Text('DEAL PRODUCT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _isProductDeal ? Colors.indigo : Colors.grey, letterSpacing: 1)),
                ],
              ),
              Switch.adaptive(
                value: _isProductDeal,
                activeColor: Colors.indigo,
                onChanged: (v) => setState(() => _isProductDeal = v),
              ),
            ],
          ),
          if (_isProductDeal) ...[
            const Divider(height: 24),
            ..._selectedDealItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return _buildSelectedProductItem(idx, item);
            }).toList(),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showProductPicker,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Tambah Produk'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.indigo,
                side: const BorderSide(color: Colors.indigo),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ESTIMASI DEAL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(total)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.indigo),
                ),
              ],
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Aktifkan jika terjadi transaksi produk.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedProductItem(int idx, Map<String, dynamic> item) {
    final basePrice = item['base_price'] as double;
    final negotiatedPrice = item['unit_price'] as double;
    final hasOverride = negotiatedPrice != basePrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.indigo.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              IconButton(
                icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 16),
                onPressed: () => setState(() => _selectedDealItems.removeAt(idx)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Quantity
              Container(
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.minus, size: 14),
                      onPressed: () => setState(() {
                        if (item['quantity'] > 1) item['quantity']--;
                      }),
                    ),
                    Text('${item['quantity'].toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(LucideIcons.plus, size: 14),
                      onPressed: () => setState(() => item['quantity']++),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasOverride)
                      Text(
                        'Base: Rp ${NumberFormat('#,###', 'id_ID').format(basePrice)}',
                        style: const TextStyle(fontSize: 10, decoration: TextDecoration.lineThrough, color: Colors.grey),
                      ),
                    GestureDetector(
                      onTap: () => _showPriceOverrideDialog(idx, item),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Rp ${NumberFormat('#,###', 'id_ID').format(negotiatedPrice)}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: hasOverride ? Colors.orange[800] : Colors.black),
                          ),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.edit2, size: 12, color: Colors.grey),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProductPicker() {
    context.read<ProductBloc>().add(const FetchProducts());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Pilih Produk untuk Deal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) return const Center(child: CircularProgressIndicator());
                    if (state is ProductsLoaded) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          final isSelected = _selectedDealItems.any((item) => item['product_id'] == product.id);
                          
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(LucideIcons.package, color: Colors.blue, size: 20),
                            ),
                            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Harga Katalog: Rp ${NumberFormat('#,###', 'id_ID').format(product.price)}'),
                            trailing: isSelected 
                                ? const Icon(LucideIcons.checkCircle, color: Colors.green)
                                : const Icon(LucideIcons.plusCircle, color: Colors.grey),
                            onTap: () {
                              if (!isSelected) {
                                setState(() {
                                  _selectedDealItems.add({
                                    'product_id': product.id,
                                    'name': product.name,
                                    'quantity': 1.0,
                                    'unit': product.unit ?? 'pcs',
                                    'base_price': product.price,
                                    'unit_price': product.price,
                                    'subtotal': product.price,
                                    'discount': 0.0,
                                  });
                                });
                              }
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    }
                    return const Center(child: Text('Gagal memuat produk'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPriceOverrideDialog(int idx, Map<String, dynamic> item) {
    final controller = TextEditingController(text: item['unit_price'].toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Negosiasi Harga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk: ${item['name']}', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Text('Harga Dasar: Rp ${NumberFormat('#,###', 'id_ID').format(item['base_price'])}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga Kesepakatan', prefixText: 'Rp '),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedDealItems[idx]['unit_price'] = double.tryParse(controller.text) ?? item['base_price'];
              });
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
