import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/services/face_detector_service.dart';
import '../../../../core/widgets/face_validation_overlay.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' as ml;

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

  final FaceDetectorService _faceDetectorService = FaceDetectorService();
  FaceValidationStatus _faceStatus = FaceValidationStatus.none;
  bool _isProcessingFrame = false;

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
      if (direction == CameraLensDirection.front) {
        _startImageStream();
      }
    }
  }

  void _startImageStream() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    _controller!.startImageStream((image) async {
      if (_isProcessingFrame || _step != 1 || !mounted) return;

      _isProcessingFrame = true;
      try {
        final inputImage = _faceDetectorService.inputImageFromCameraImage(
          image,
          _controller!.description,
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

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_step == 1 && _faceStatus != FaceValidationStatus.valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wajah tidak jelas. Cari posisi atau cahaya lebih baik di depan toko.')),
      );
      return;
    }

    try {
      if (_step == 1) {
        await _controller!.stopImageStream();
      }
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller!),
                if (_step == 1)
                  Center(
                    child: FaceValidationOverlay(status: _faceStatus),
                  ),
              ],
            ),
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
