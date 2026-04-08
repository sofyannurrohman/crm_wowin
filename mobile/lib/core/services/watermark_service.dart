import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class WatermarkService {
  static Future<File> addAddressWatermark(File imageFile, Position? position) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return imageFile;

    String watermarkText = '';
    
    // 1. Get Address
    if (position != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          final parts = [
            place.street,
            place.subLocality,
            place.locality,
            place.subAdministrativeArea,
          ].where((p) => p != null && p.isNotEmpty).toList();
          watermarkText = parts.join(', ');
        }
      } catch (e) {
        // Fallback to coordinates
        watermarkText = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      }
    }

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final fullText = '$watermarkText\n$timestamp';

    // 2. Draw Watermark
    // We'll draw at the bottom of the image
    const padding = 20;
    
    // Auto-scale font based on image width
    // image.width / 40 is a rough estimation for a readable font size
    final fontSize = (image.width / 35).clamp(14.0, 48.0).toInt();

    // Use a built-in bitmap font for speed if possible, 
    // but the 'image' package 4.x supports TrueType fonts too.
    // For simplicity and speed, we use default fonts or draw pixels.
    
    // Draw a dark overlay for readability
    img.fillRect(
      image,
      x1: 0,
      y1: image.height - (fontSize * 3) - padding,
      x2: image.width,
      y2: image.height,
      color: img.ColorRgba8(0, 0, 0, 100), // Semi-transparent black
    );

    img.drawString(
      image,
      fullText,
      font: fontSize > 24 ? img.arial48 : img.arial24, // Use available bitmap fonts
      x: padding,
      y: image.height - (fontSize * 2) - padding,
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    // 3. Save to Temp File
    final tempDir = await getTemporaryDirectory();
    final outPath = p.join(tempDir.path, 'watermarked_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final watermarkedFile = File(outPath);
    await watermarkedFile.writeAsBytes(img.encodeJpg(image, quality: 85));

    return watermarkedFile;
  }
}
