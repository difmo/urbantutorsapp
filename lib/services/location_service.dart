import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:urbantutorsapp/services/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:urbantutorsapp/utils/api_config.dart';
import 'package:urbantutorsapp/utils/app_logger.dart';

class LocationService {
  static String get _url => ApiConfig.fullGetLocationUrl;

  String _unescape(String s) => s
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");

  List<String> _parseOptions(String htmlOptions) {
    final re = RegExp(r'value="([^"]+)"');
    final seen = <String>{};
    final out = <String>[];
    for (final m in re.allMatches(htmlOptions)) {
      final v = _unescape(m.group(1)!);
      if (seen.add(v)) out.add(v);
    }
    return out;
  }

  /// POST with x-www-form-urlencoded: location=<query>
  Future<List<String>> searchLocations(String query) async {
    final res = await _httpPost(Uri.parse(_url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'location': query},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      AppLogger.apiError(
        'Location search failed with status ${res.statusCode}',
        method: 'POST',
        url: _url,
        statusCode: res.statusCode,
        error: res.body,
      );
      throw ApiException('Location API failed: ${res.statusCode}');
    }
    final body = _decodeJson(res.body) as Map<String, dynamic>;
    final data = (body['data'] as String?) ?? '';
    return _parseOptions(data);
  }

  /// ALT: mimic Postman `form-data` (multipart/form-data)
  Future<List<String>> searchLocationsMultipart(String query) async {
    final req = http.MultipartRequest('POST', Uri.parse(_url))
      ..fields['location'] = query
      ..headers['Accept'] = 'application/json';

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      AppLogger.apiError(
        'Location multipart search failed with status ${res.statusCode}',
        method: 'POST',
        url: _url,
        statusCode: res.statusCode,
        error: res.body,
      );
      throw ApiException('Location API failed: ${res.statusCode}');
    }
    final body = _decodeJson(res.body) as Map<String, dynamic>;
    final data = (body['data'] as String?) ?? '';
    return _parseOptions(data);
  }

  // ---------------- NEW ----------------
  // /// Get device current location
  // Future<Position> getCurrentPosition() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     throw ApiException('Location services are disabled');
  //   }

  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       throw ApiException('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     throw ApiException('Location permissions are permanently denied');
  //   }

  //   return await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  // }

  // /// Reverse-geocode lat/lng to get place_id and formatted address
  // Future<Map<String, String>> reverseGeocode(double lat, double lng) async {
  //   // final placemarks = await geo.placemarkFromCoordinates(lat, lng);
  //   // if (placemarks.isEmpty) return {};

  //   // final place = placemarks.first;
  //   final placeId = '${place.locality}-${place.postalCode}-${place.administrativeArea}';
  //   final formattedAddress =
  //       '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

  //   return {
  //     'place_id': placeId,
  //     'formatted_address': formattedAddress,
  //   };
  // }
}

/// POST with a timeout; maps network failures to readable [ApiException]s.
Future<http.Response> _httpPost(Uri uri,
    {Map<String, String>? headers, Object? body}) async {
  try {
    return await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));
  } on TimeoutException catch (te) {
    AppLogger.apiError(
      'Location API request timeout (20s)',
      method: 'POST',
      url: uri.toString(),
      error: te,
    );
    throw const ApiException(
        'The server is taking too long to respond. Please try again.');
  } on SocketException catch (se) {
    AppLogger.apiError(
      'Location API socket error: No internet connection',
      method: 'POST',
      url: uri.toString(),
      error: se,
    );
    throw const ApiException(
        'No internet connection. Please check your network and try again.');
  }
}

/// Decodes a JSON body, or throws a readable [ApiException].
dynamic _decodeJson(String body) {
  try {
    return jsonDecode(body);
  } on FormatException catch (fe) {
    AppLogger.apiError(
      'Location API returned invalid JSON response',
      error: fe,
    );
    throw const ApiException(
        'Unexpected response from server. Please try again later.');
  }
}
