import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class GeocodingService {
  /// Reverse geocodes coordinates into a human-readable address.
  /// Uses Nominatim on Web and the Native Geocoder on Mobile.
  static Future<String?> reverseGeocode(double lat, double lng) async {
    if (kIsWeb) {
      return _reverseGeocodeWeb(lat, lng);
    } else {
      return _reverseGeocodeNative(lat, lng);
    }
  }

  static Future<String?> _reverseGeocodeNative(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final parts = [
          place.street,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
        ].where((p) => p != null && p.isNotEmpty).toList();
        
        if (parts.isEmpty) return null;
        return parts.join(', ');
      }
    } catch (e) {
      print('Native geocoding error: $e');
    }
    return null;
  }

  static Future<String?> _reverseGeocodeWeb(double lat, double lng) async {
    try {
      final res = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json'),
        headers: {'User-Agent': 'wowin_crm_mobile'},
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['display_name'];
      }
    } catch (e) {
      print('Web geocoding error: $e');
    }
    return null;
  }
}
