import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  FaceDetector? _faceDetector;

  FaceDetectorService() {
    if (kIsWeb) return;
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        enableClassification: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  Future<List<Face>> detectFaces(InputImage inputImage) async {
    if (_faceDetector == null) return [];
    try {
      return await _faceDetector!.processImage(inputImage);
    } catch (e) {
      debugPrint('Face detection error: $e');
      return [];
    }
  }

  void dispose() {
    _faceDetector?.close();
    _faceDetector = null;
  }

  /// Converts a [CameraImage] to [InputImage] for processing.
  InputImage? inputImageFromCameraImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    final format = _getImageFormat(image.format.raw);
    if (format == null) return null;

    final planes = image.planes;
    if (planes.isEmpty) return null;

    final plane = planes.first;

    return InputImage.fromBytes(
      bytes: _concatenatePlanes(planes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: _rotationFromSensorOrientation(camera.sensorOrientation),
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  InputImageFormat? _getImageFormat(int rawValue) {
    if (Platform.isAndroid) {
      // Typically 35 for YUV_420_888 or 17 for NV21
      if (rawValue == 35) return InputImageFormat.yuv_420_888;
      if (rawValue == 17) return InputImageFormat.nv21;
    } else if (Platform.isIOS) {
       // Typically 1111970369 for BGRA8888
       if (rawValue == 1111970369) return InputImageFormat.bgra8888;
    }
    return InputImageFormatValue.fromRawValue(rawValue);
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  InputImageRotation _rotationFromSensorOrientation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
        return InputImageRotation.rotation0deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }
}
