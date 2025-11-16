// import 'dart:convert';
// // import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;

// class LocationWithPlace {
//   final double latitude;
//   final double longitude;
//   final String? placeId;
//   final String? formattedAddress;

//   LocationWithPlace({
//     required this.latitude,
//     required this.longitude,
//     this.placeId,
//     this.formattedAddress,
//   });

//   @override
//   String toString() =>
//       'lat=$latitude lng=$longitude placeId=$placeId address=$formattedAddress';
// }

// class LocationHelper {
//   // WARNING: don't hardcode API keys in production. Use secure storage or backend proxy.
//   // You provided this key — store it elsewhere in production.
//   static const String googleApiKey = 'AIzaSyCZwbXh6Ol0QdP10Run1Q22rM7Nk81Nr-0';

//   /// Request permission (if needed) and get current position.
//   static Future<Position> _determinePosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw Exception('Location services are disabled.');
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw Exception('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are denied forever, show a dialog to the user.
//       throw Exception(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }

//     // Get the current position (use high accuracy if you need)
//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//       timeLimit: Duration(seconds: 10),
//     );
//   }

//   /// Reverse geocode lat/lng via Google Geocoding API to get place_id and formatted address.
//   static Future<LocationWithPlace> getCurrentLocationWithPlaceId() async {
//     final Position pos = await _determinePosition();
//     final lat = pos.latitude;
//     final lng = pos.longitude;

//     final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
//       'latlng': '$lat,$lng',
//       'key': googleApiKey,
//       // optionally you can set 'result_type' or 'location_type' to filter results
//     });

//     final resp = await http.get(uri).timeout(Duration(seconds: 10));
//     if (resp.statusCode != 200) {
//       throw Exception('Geocoding API error: HTTP ${resp.statusCode}');
//     }

//     final Map<String, dynamic> body = jsonDecode(resp.body);
//     final status = (body['status'] ?? '').toString();
//     if (status != 'OK' && status != 'ZERO_RESULTS') {
//       // Examples: OVER_QUERY_LIMIT, REQUEST_DENIED, INVALID_REQUEST
//       throw Exception('Geocoding API returned status: $status');
//     }

//     String? placeId;
//     String? formattedAddress;

//     final results = body['results'] as List<dynamic>? ?? [];
//     if (results.isNotEmpty) {
//       final first = results.first as Map<String, dynamic>;
//       placeId = first['place_id']?.toString();
//       formattedAddress = first['formatted_address']?.toString();
//     }

//     return LocationWithPlace(
//       latitude: lat,
//       longitude: lng,
//       placeId: placeId,
//       formattedAddress: formattedAddress,
//     );
//   }
// }
