import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageUtils {
  static Future<Uint8List> compressImage(Uint8List bytes) async {
    if (kIsWeb) {
      // flutter_image_compress doesn't support Web in the same way,
      // browsers are usually capable of handling larger images, 
      // or we could use another web-specific package. 
      // For now, return original bytes on web.
      return bytes;
    }

    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );
      return result;
    } catch (e) {
      return bytes;
    }
  }
}
