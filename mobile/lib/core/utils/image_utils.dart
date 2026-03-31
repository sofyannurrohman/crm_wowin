import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<File> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final path = file.absolute.path;
    final outPath = p.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg');

    var result = await FlutterImageCompress.compressAndGetFile(
      path,
      outPath,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
    );

    if (result == null) return file;
    return File(result.path);
  }
}
