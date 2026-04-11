import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'geocoding_service.dart';

class WatermarkService {
  static Future<Uint8List> addAddressWatermark(Uint8List imageBytes, Position? position, {String? address}) async {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    String addressText = address ?? '';
    
    // 1. Get Address if not provided
    if (addressText.isEmpty && position != null) {
      final fetchedAddress = await GeocodingService.reverseGeocode(position.latitude, position.longitude);
      if (fetchedAddress != null) {
        addressText = fetchedAddress;
      } else {
        addressText = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      }
    }

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    
    // Determine font and char width
    final fontSize = (image.width / 40).clamp(15.0, 36.0).toInt();
    final font = fontSize > 24 ? img.arial48 : img.arial24;
    // Estimate char width: arial24 ~13px, arial48 ~26px
    final charWidth = fontSize > 24 ? 26 : 13;
    final maxCharsPerLine = ((image.width - 40) / charWidth).floor();

    // 2. Prepare lines with wrapping
    final List<String> lines = [];
    if (addressText.isNotEmpty) {
      lines.addAll(_wrapText(addressText, maxCharsPerLine));
    }
    
    // Add a separator space if we have address
    if (lines.isNotEmpty) lines.add(''); 

    if (position != null) {
      lines.add('GPS: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}');
    }
    lines.add('Waktu: $timestamp');

    // 3. Draw Watermark
    const padding = 20;
    final lineHeight = (fontSize * 1.5).toInt();
    final totalHeight = (lineHeight * lines.length) + (padding * 2);

    // Draw a dark overlay for readability
    img.fillRect(
      image,
      x1: 0,
      y1: image.height - totalHeight,
      x2: image.width,
      y2: image.height,
      color: img.ColorRgba8(0, 0, 0, 160), 
    );

    // Draw lines from bottom to top
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].isEmpty) continue; // Skip separator space for drawing text

      img.drawString(
        image,
        lines[i],
        font: font,
        x: padding,
        y: image.height - totalHeight + padding + (i * lineHeight),
        color: img.ColorRgba8(255, 255, 255, 255),
      );
    }

    // 4. Return as JPG bytes
    return Uint8List.fromList(img.encodeJpg(image, quality: 85));
  }

  static List<String> _wrapText(String text, int maxChars) {
    if (text.length <= maxChars) return [text];
    
    final List<String> lines = [];
    final List<String> words = text.split(' ');
    String currentLine = '';

    for (var word in words) {
      if ((currentLine + word).length <= maxChars) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        if (currentLine.isNotEmpty) lines.add(currentLine);
        
        // If a single word is longer than maxChars, force break it
        if (word.length > maxChars) {
          while (word.length > maxChars) {
            lines.add(word.substring(0, maxChars));
            word = word.substring(maxChars);
          }
          currentLine = word;
        } else {
          currentLine = word;
        }
      }
    }
    if (currentLine.isNotEmpty) lines.add(currentLine);
    return lines;
  }
}
