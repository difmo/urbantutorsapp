import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const _url = 'https://urbantutors.pro/api/getlocation';

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
    final res = await http.post(
      Uri.parse(_url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'location': query},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Location API failed: ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
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
      throw Exception('Location API failed: ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = (body['data'] as String?) ?? '';
    return _parseOptions(data);
  }
}
