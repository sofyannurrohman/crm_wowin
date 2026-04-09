import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WatermarkService {
  static Future<Uint8List> addAddressWatermark(Uint8List imageBytes, Position? position) async {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    String watermarkText = '';
    
    // 1. Get Address
    if (position != null) {
      if (kIsWeb) {
        // Geocoding often fails or behaves differently on web without proper setup, 
        // fallback to coordinates for now on web.
        watermarkText = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      } else {
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
    }

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final fullText = '$watermarkText\n$timestamp';

    // 2. Draw Watermark
    const padding = 20;
    final fontSize = (image.width / 35).clamp(14.0, 48.0).toInt();

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
      font: fontSize > 24 ? img.arial48 : img.arial24,
      x: padding,
      y: image.height - (fontSize * 2) - padding,
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    // 3. Return as JPG bytes
    return Uint8List.fromList(img.encodeJpg(image, quality: 85));
  }
}
