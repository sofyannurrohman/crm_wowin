import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:http/http.dart' as http;
import '../../../../core/utils/image_utils.dart';

import '../bloc/visit_bloc.dart';
import '../bloc/visit_event.dart';
import '../bloc/visit_state.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CheckInPage extends StatefulWidget {
  final String scheduleId;
  final String? customerName;
  final String? customerAddress;
  final double? targetLat;
  final double? targetLng;
  final double targetRadiusMeters;
  final String? dealId;
  final String? taskDestinationId;

  const CheckInPage({
    super.key,
    required this.scheduleId,
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
  XFile? _storefrontPhoto;
  XFile? _selfiePhoto;

  // Camera State
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  List<CameraDescription> _cameras = [];
  bool _isCapturing = false;

  // GPS Override
  String? _overrideReason;
  int _gpsSecondsElapsed = 0;
  bool _showOverrideButton = false;
  Timer? _gpsTimer;

  // Live GPS tracking
  StreamSubscription<Position>? _positionStreamSubscription;

  // OSRM Route
  List<ll.LatLng> _routePoints = [];

  static const Color _orange = Color(0xFFEA580C);
  static const Color _bg = Color(0xFFF9FAFB);
  static const int _totalSteps = 5; // 0=Select, 1=Proximity, 2=Storefront, 3=Selfie, 4=Summary

  @override
  void initState() {
    super.initState();
    _initWizard();
    _determinePosition();
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
        id: 'external',
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
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = useFront
          ? (_cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => _cameras.first))
          : _cameras.first;

      await _cameraController?.dispose();
      _cameraController = CameraController(camera, ResolutionPreset.medium, enableAudio: false);
      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _determinePosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() => _currentPosition = position);
        if (_selectedCustomer?.latitude != null) _fetchRoute();
      }
    } catch (e) {
      debugPrint('Location error: $e');
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

    setState(() => _isCapturing = true);
    try {
      final photo = await _cameraController!.takePicture();
      final compressed = await ImageUtils.compressImage(File(photo.path));
      setState(() {
        if (isStorefront) {
          _storefrontPhoto = XFile(compressed.path);
        } else {
          _selfiePhoto = XFile(compressed.path);
        }
      });
      _nextStep();
    } catch (e) {
      debugPrint('Photo capture error: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _submitCheckIn() {
    if (_storefrontPhoto == null || _selfiePhoto == null || _currentPosition == null || _selectedCustomer == null) return;

    context.read<VisitBloc>().add(
      CheckInSubmitted(
        scheduleId: widget.scheduleId,
        latitude: _currentPosition?.latitude ?? 0.0,
        longitude: _currentPosition?.longitude ?? 0.0,
        photoFile: File(_storefrontPhoto!.path),
        selfiePhotoFile: File(_selfiePhoto!.path),
        notes: _notesController.text,
        dealId: widget.dealId,
        overrideReason: _overrideReason,
        customerName: _selectedCustomer?.name,
        taskDestinationId: widget.taskDestinationId,
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

    return Padding(
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

          const Spacer(),

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

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: dist != null || _overrideReason != null ? _nextStep : null,
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
            TextButton.icon(
              onPressed: _showOverrideDialog,
              icon: const Icon(LucideIcons.shieldAlert, size: 16),
              label: const Text('Manual Override', style: TextStyle(color: _orange, fontWeight: FontWeight.bold)),
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
    final capturedPhoto = isStorefront ? _storefrontPhoto : _selfiePhoto;
    final title = isStorefront ? 'Foto Depan Toko / Lokasi' : 'Selfie dengan Pelanggan';
    final hint = isStorefront ? 'Ambil foto yang jelas dari depan toko' : 'Foto bersama pelanggan sebagai bukti pertemuan';

    return Stack(
      children: [
        if (_isCameraInitialized && _cameraController != null)
          Positioned.fill(child: CameraPreview(_cameraController!))
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
              if (capturedPhoto != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => setState(() {
                    if (isStorefront) _storefrontPhoto = null;
                    else _selfiePhoto = null;
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

  // ── STEP 4: Summary & Submit
  Widget _buildStepSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RINGKASAN KUNJUNGAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 16),
          _buildSummaryTile(LucideIcons.building, 'Pelanggan', _selectedCustomer?.name ?? ''),
          _buildSummaryTile(LucideIcons.mapPin, 'Jarak', _overrideReason != null ? 'Override Manual' : 'Terverifikasi'),
          const SizedBox(height: 20),

          // Dual photo previews
          Row(
            children: [
              if (_storefrontPhoto != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FOTO TOKO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(_storefrontPhoto!.path), height: 110, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ],
                  ),
                ),
              if (_storefrontPhoto != null && _selfiePhoto != null) const SizedBox(width: 10),
              if (_selfiePhoto != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SELFIE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(_selfiePhoto!.path), height: 110, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),
          const Text('CATATAN (OPSIONAL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Masukkan catatan kunjungan...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 28),

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
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('KONFIRMASI KEDATANGAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _orange),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
