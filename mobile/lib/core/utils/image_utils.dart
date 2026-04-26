import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  /// Robust Image Preprocessing for Mobile (Optimized for "HP Lawas")
  /// 1. Decodes image (supports many formats)
  /// 2. Resizes if width > 1024px while maintaining aspect ratio
  /// 3. Compresses to JPEG with target quality
  static Future<Uint8List> preprocessImage(Uint8List bytes, {int maxWidth = 1024, int quality = 80}) async {
    try {
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return bytes;

      // 1. Resize if too large (HP Lawas optimization)
      if (image.width > maxWidth) {
        image = img.copyResize(
          image, 
          width: maxWidth,
          interpolation: img.Interpolation.linear,
        );
      }

      // 2. High Efficiency Compression
      final compressedBytes = img.encodeJpg(image, quality: quality);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      return bytes;
    }
  }

  /// Legacy compression method updated to use 'image' library as requested.
  static Future<Uint8List> compressImage(Uint8List bytes) async {
    // If it's already small and compressed, preprocessImage will handle it gracefully.
    return preprocessImage(bytes, maxWidth: 1024, quality: 75);
  }

  /// Helper for XFile/File based workflows (used in CheckOutPage)
  static Future<File> processImageForUpload(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final processedBytes = await preprocessImage(bytes);
      
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final processedFile = File(tempPath);
      await processedFile.writeAsBytes(processedBytes);
      
      return processedFile;
    } catch (e) {
      return file;
    }
  }
}
