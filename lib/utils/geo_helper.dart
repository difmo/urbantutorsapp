import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class GeoAddress {
  final String locality;
  final String postalCode;
  final String fullAddress;

  const GeoAddress({
    required this.locality,
    required this.postalCode,
    required this.fullAddress,
  });
}

class GeoHelper {
  /// Resolves lat/lng to address details.
  /// 1. Tries native Geocoder first.
  /// 2. If Android throws PlatformException(IO_ERROR, UNAVAILABLE),
  ///    gracefully falls back to OpenStreetMap Nominatim reverse geocode.
  static Future<GeoAddress?> getAddressFromCoordinates(
      double lat, double lng) async {
    // 1. Native geocoder
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 5));
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final postalCode = place.postalCode ?? '';
        final parts = [
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
        ].where((s) => s != null && s.trim().isNotEmpty).toList();
        final locality =
            parts.isNotEmpty ? parts.join(', ') : (place.name ?? '');

        return GeoAddress(
          locality: locality,
          postalCode: postalCode,
          fullAddress: locality,
        );
      }
    } catch (e) {
      debugPrint(
          '\x1B[93m[GeoHelper] Native Android geocoder unavailable ($e). Using HTTP fallback...\x1B[0m');
    }

    // 2. HTTP Fallback (Nominatim OpenStreetMap)
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1');
      final res = await http.get(
        uri,
        headers: {'User-Agent': 'UrbanTutorsPro/1.0 (support@urbantutors.pro)'},
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final postalCode = address['postcode']?.toString() ?? '';
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['suburb'] ??
              address['county'] ??
              '';
          final state = address['state']?.toString() ?? '';
          final road = address['road'] ?? address['neighbourhood'] ?? '';

          final parts = [road, city, state]
              .where((s) => s != null && s.toString().trim().isNotEmpty)
              .toList();
          final locality = parts.isNotEmpty
              ? parts.join(', ')
              : (data['display_name']?.toString() ?? '');

          return GeoAddress(
            locality: locality,
            postalCode: postalCode,
            fullAddress: data['display_name']?.toString() ?? locality,
          );
        }
      }
    } catch (e) {
      debugPrint('[GeoHelper] Fallback geocoding error: $e');
    }

    return null;
  }
}
