import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LivePhotoCapturePage extends StatefulWidget {
  const LivePhotoCapturePage({super.key});

  @override
  State<LivePhotoCapturePage> createState() => _LivePhotoCapturePageState();
}

class _LivePhotoCapturePageState extends State<LivePhotoCapturePage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInit = false;
  int _step = 1; // 1: Selfie, 2: Storefront

  String? _selfieBase64;
  String? _storefrontBase64;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _setupCamera(CameraLensDirection.front);
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  Future<void> _setupCamera(CameraLensDirection direction) async {
    final camera = _cameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(camera, ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
    
    if (mounted) {
      setState(() {
        _isInit = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      if (_step == 1) {
        setState(() {
          _selfieBase64 = base64String;
          _step = 2;
          _isInit = false;
        });
        await _controller!.dispose();
        await _setupCamera(CameraLensDirection.back);
      } else {
        _storefrontBase64 = base64String;
        Navigator.pop(context, {
          'selfie': _selfieBase64,
          'storefront': _storefrontBase64,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_step == 1 ? '1/2: Selfie Depan Toko' : '2/2: Tampak Depan Toko', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  _step == 1 ? 'Ambil Selfie di Depan Toko' : 'Ambil Foto Tampak Depan Toko', 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    shadows: [Shadow(color: Colors.black, blurRadius: 6, offset: Offset(0, 2))],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.camera, color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
