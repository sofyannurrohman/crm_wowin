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
import '../../../../core/router/route_constants.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/services/watermark_service.dart';
import '../../../../core/services/geocoding_service.dart';
import '../../../../core/theme/app_colors.dart';

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
  final String? salesId;
  final String? salesmanName;

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
    this.salesId,
    this.salesmanName,
  });

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final PageController _pageController = PageController();
  final MapController _mapController = MapController();

  int _currentStep = 0;
  Customer? _selectedCustomer;
  Position? _currentPosition;
  String? _currentAddress;
  XFile? _storefrontPhoto;
  Uint8List? _storefrontBytes;
  XFile? _selfiePhoto;
  Uint8List? _selfieBytes;
  DateTime? _checkInTime;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  List<CameraDescription> _cameras = [];
  bool _isCapturing = false;
  bool _isWatermarking = false;

  String? _overrideReason;
  int _gpsSecondsElapsed = 0;
  bool _showOverrideButton = false;
  Timer? _gpsTimer;

  StreamSubscription<Position>? _positionStreamSubscription;
  List<ll.LatLng> _routePoints = [];

  final FaceDetectorService _faceDetectorService = FaceDetectorService();
  FaceValidationStatus _faceStatus = FaceValidationStatus.none;
  bool _isProcessingFrame = false;

  static const int _totalSteps = 4; // 0=Select, 1=Proximity, 2=Selfie, 3=Summary

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
      distanceFilter: 10,
    );
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (!mounted) return;
        setState(() => _currentPosition = position);
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
        salesId: widget.salesId,
        salesmanName: widget.salesmanName,
      );
      _currentStep = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(1);
        _fetchRoute();
      });
    }
  }

  Future<void> _initializeCamera({bool useFront = false}) async {
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

      if (kIsWeb) await Future.delayed(const Duration(milliseconds: 300));

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
            imageFormatGroup: ImageFormatGroup.jpeg,
          );
          
          await _cameraController!.initialize();
          lastEx = null;
          break;
        } on CameraException catch (e) {
          debugPrint('Failed to init camera ${camera.name}: ${e.code}');
          lastEx = e;
          if (e.code == 'cameraNotReadable' || e.code == 'CameraAccessDenied') {
            await _cameraController?.dispose();
            _cameraController = null;
            continue;
          }
          rethrow;
        }
      }

      if (lastEx != null) throw lastEx;

      if (mounted && _cameraController != null) { 
        setState(() => _isCameraInitialized = true);
        if (useFront && !kIsWeb) _startImageStream();
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        String msg = 'Failed to open camera.';
        if (e is CameraException) {
          if (e.code == 'cameraNotReadable') msg = 'Camera is in use or not readable.';
          if (e.code == 'CameraAccessDenied') msg = 'Camera permission denied.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _startImageStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized || kIsWeb) return;
    _cameraController!.startImageStream(_processCameraImage);
  }

  void _processCameraImage(CameraImage image) async {
    if (kIsWeb || _isProcessingFrame || _currentStep != 2) return;
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
      setState(() => _faceStatus = newStatus);
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
    final address = await GeocodingService.reverseGeocode(pos.latitude, pos.longitude);
    if (address != null && mounted) {
      setState(() => _currentAddress = address);
    }
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
    } catch (_) {}
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    _positionStreamSubscription?.cancel();
    _pageController.dispose();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Manual GPS Override', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GPS Signal is weak. Provide a reason to continue manually.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Inside building, no signal',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _overrideReason = controller.text);
                Navigator.pop(context);
                _gpsTimer?.cancel();
                _nextStep();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('VERIFY MANUALLY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      if (_currentStep == 2) _initializeCamera(useFront: true);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      if (_currentStep == 1) _initializeCamera(useFront: false);
    } else {
      context.pop();
    }
  }

  Future<void> _takePhoto({required bool isStorefront}) async {
    if (!_isCameraInitialized || _cameraController == null || _isCapturing) return;

    if (!isStorefront && _selfieBytes == null && !kIsWeb && _faceStatus != FaceValidationStatus.valid) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Face not clearly detected. Please find better lighting.'), behavior: SnackBarBehavior.floating),
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
      
      setState(() => _isWatermarking = true);
      final watermarkedBytes = await WatermarkService.addAddressWatermark(
        bytes, 
        _currentPosition,
        address: '${_selectedCustomer?.name ?? ""}\n${_selectedCustomer?.address ?? _currentAddress ?? ""}',
      );
      
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
    if (_selfieBytes == null || _currentPosition == null || _selectedCustomer == null) return;

    context.read<VisitBloc>().add(
      CheckInSubmitted(
        scheduleId: widget.scheduleId,
        latitude: _currentPosition?.latitude ?? 0.0,
        longitude: _currentPosition?.longitude ?? 0.0,
        photoFile: _selfiePhoto!,
        selfiePhotoFile: _selfiePhoto!,
        notes: '',
        dealId: widget.dealId,
        overrideReason: _overrideReason,
        customerId: (_selectedCustomer?.id == 'external' || _selectedCustomer?.id == null) ? null : _selectedCustomer!.id,
        leadId: widget.leadId,
        customerName: _selectedCustomer?.name,
        taskDestinationId: widget.taskDestinationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildPremiumHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStepSelection(),
                    _buildStepProximity(),
                    _buildCameraStep(isStorefront: false),
                    _buildStepSummary(),
                  ],
                ),
              ),
            ],
          ),
          if (_isWatermarking)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      const SizedBox(height: 24),
                      Text(
                        'Adding Location Watermark...',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
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

  Widget _buildPremiumHeader() {
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _prevStep,
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  ),
                  Column(
                    children: [
                      const Text(
                        'Check-In Verification',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                      ),
                      Text(
                        _getStepTitle(),
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'SELECT CUSTOMER';
      case 1: return 'LOCATION VERIFICATION';
      case 2: return 'SELFIE EVIDENCE';
      case 3: return 'REVIEW & SUBMIT';
      default: return '';
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = _currentStep >= index;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index == _totalSteps - 1 ? 0 : 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── STEP 0: Customer Selection ─────────────────────────
  Widget _buildStepSelection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: TextField(
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search target customer...',
                hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 14),
                prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary, size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(18),
              ),
              onChanged: (val) => context.read<CustomerBloc>().add(FetchCustomers(query: val)),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              if (state is CustomersLoaded) {
                if (state.customers.isEmpty) {
                  return const Center(child: Text('No customers found', style: TextStyle(color: AppColors.textPlaceholder, fontWeight: FontWeight.w600)));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  itemCount: state.customers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = state.customers[index];
                    final isSelected = _selectedCustomer?.id == c.id;
                    return GestureDetector(
                      onTap: () {
                        final authState = context.read<auth.AuthBloc>().state;
                        final currentUser = (authState is auth.Authenticated) ? authState.user : null;
                        final bool isOwner = currentUser != null && (c.salesId?.toLowerCase().trim() == currentUser.id.toLowerCase().trim());
                        final bool isAdmin = currentUser?.role == 'admin';
                        final bool isAssigned = widget.scheduleId != 'adhoc';
                        final bool isLocked = !isOwner && !isAdmin && !isAssigned;

                        if (isLocked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Access denied: Owned by another salesperson.'), backgroundColor: Color(0xFFEF4444), behavior: SnackBarBehavior.floating),
                          );
                          return;
                        }

                        setState(() => _selectedCustomer = c);
                        _fetchRoute();
                        _nextStep();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9), width: 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(LucideIcons.building, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary)),
                                  Text(c.address ?? 'No address', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            if (isSelected) const Icon(LucideIcons.checkCircle2, color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(child: Text('Search to find customers'));
            },
          ),
        ),
      ],
    );
  }

  // ── STEP 1: Proximity ────────────────────
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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedCustomer?.latitude != null
                            ? ll.LatLng(_selectedCustomer!.latitude!, _selectedCustomer!.longitude!)
                            : const ll.LatLng(0, 0),
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.wowin.crm',
                        ),
                        if (_routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(points: _routePoints, strokeWidth: 4.0, color: const Color(0xFF3B82F6)),
                            ],
                          ),
                        if (_selectedCustomer?.latitude != null)
                          CircleLayer(
                            circles: [
                              CircleMarker(
                                point: ll.LatLng(_selectedCustomer!.latitude!, _selectedCustomer!.longitude!),
                                radius: widget.targetRadiusMeters,
                                useRadiusInMeter: true,
                                color: AppColors.primary.withOpacity(0.12),
                                borderColor: AppColors.primary.withOpacity(0.5),
                                borderStrokeWidth: 2,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            if (_selectedCustomer?.latitude != null)
                              Marker(
                                point: ll.LatLng(_selectedCustomer!.latitude!, _selectedCustomer!.longitude!),
                                width: 40,
                                height: 40,
                                child: const Icon(LucideIcons.mapPin, color: AppColors.primary, size: 30),
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
                const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    children: [
                      Text(_selectedCustomer?.name ?? 'Unknown Target', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.navigation, size: 16, color: isWithinRadius ? AppColors.primary : const Color(0xFFF59E0B)),
                          const SizedBox(width: 8),
                          Text(
                            dist != null ? '${dist.toStringAsFixed(1)}m from destination' : 'Locating...',
                            style: TextStyle(color: isWithinRadius ? AppColors.primary : const Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ],
                      ),
                      if (!isWithinRadius && dist != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFED7AA))),
                          child: const Row(
                            children: [
                              Icon(LucideIcons.alertTriangle, color: Color(0xFFF59E0B), size: 16),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('OUTSIDE RADIUS: Visit will be marked for manager review.', style: TextStyle(color: Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _buildBottomAction(
          onPressed: () {
             if (dist != null || _overrideReason != null) _nextStep();
          },
          label: _overrideReason != null ? 'CONTINUE (OVERRIDE)' : (isWithinRadius ? 'PROCEED TO SELFIE' : 'PROCEED ANYWAY'),
          color: isWithinRadius ? AppColors.primary : const Color(0xFF475569),
        ),
        if (!isWithinRadius && _showOverrideButton && _overrideReason == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextButton.icon(
              onPressed: _showOverrideDialog,
              icon: const Icon(LucideIcons.shieldAlert, size: 16, color: AppColors.primary),
              label: const Text('Manual Override', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ),
      ],
    );
  }

  // ── STEP 2: Camera Selfie ───────────
  Widget _buildCameraStep({required bool isStorefront}) {
    return Stack(
      children: [
        if (_isCameraInitialized && _cameraController != null)
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController!),
                FaceValidationOverlay(status: _faceStatus),
              ],
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),

        // Frame guide
        Center(
          child: Container(
            width: 280,
            height: 380,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),

        // Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 60),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent]),
            ),
            child: Column(
              children: [
                const Text('Face Verification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.3)),
                const SizedBox(height: 8),
                Text('Align your face within the frame and look straight.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _isCapturing ? null : () => _takePhoto(isStorefront: false),
                  child: Container(
                    height: 84,
                    width: 84,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: _isCapturing ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── STEP 3: Summary & Submit ───────────
  Widget _buildStepSummary() {
    final checkInTimeStr = _checkInTime != null ? DateFormat('EEEE, MMM d, HH:mm').format(_checkInTime!) : '-';
    double? dist;
    if (_currentPosition != null && _selectedCustomer?.latitude != null) {
      dist = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, _selectedCustomer!.latitude!, _selectedCustomer!.longitude!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.fileCheck, color: AppColors.primary, size: 20)),
                    const SizedBox(width: 12),
                    const Text('VISIT REPORT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.textPlaceholder)),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                _buildReportRow('Customer', _selectedCustomer?.name ?? '-', isBold: true),
                _buildReportRow('Arrival Time', checkInTimeStr),
                _buildReportRow('Distance', dist != null ? '${dist.toStringAsFixed(1)}m' : '-'),
                _buildReportRow('Status', _overrideReason != null ? 'OVERRIDE' : 'VERIFIED', color: _overrideReason != null ? const Color(0xFFF59E0B) : AppColors.primary),
                const SizedBox(height: 24),
                const Text('EVIDENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.textPlaceholder)),
                const SizedBox(height: 12),
                if (_selfieBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(_selfieBytes!, height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          BlocConsumer<VisitBloc, VisitState>(
            listener: (context, state) {
              if (state is VisitSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating));
                context.pushReplacementNamed(
                  kRouteOngoingVisit,
                  extra: {
                    'scheduleId': widget.scheduleId,
                    'customerId': state.customerId,
                    'leadId': state.leadId,
                    'customerName': state.customerName ?? widget.customerName,
                    'taskDestinationId': widget.taskDestinationId,
                    'checkInTime': state.checkInTime ?? DateTime.now(),
                    'dealId': widget.dealId,
                  },
                );
              } else if (state is VisitError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating));
              }
            },
            builder: (context, state) {
              final isLoading = state is VisitLoading;
              return ElevatedButton(
                onPressed: isLoading ? null : _submitCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                    : const Text('SUBMIT VISIT RECORD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.3)),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 14, color: color ?? AppColors.textPrimary, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildBottomAction({required VoidCallback onPressed, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.3)),
        ),
      ),
    );
  }
}
