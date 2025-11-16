// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:http/http.dart' as http;

// class LocationControlleraa {
//   final String googleKey = "AIzaSyCZwbXh6Ol0QdP10Run1Q22rM7Nk81Nr-0";

//   Future<Map<String, dynamic>> getLocationWithoutGeolocator() async {
//     final controller = WebViewC();
//     final Completer<Map<String, dynamic>> completer = Completer();

//     controller.setJavaScriptMode(JavaScriptMode.unrestricted);

//     controller.addJavaScriptChannel(
//       "locationHandler",
//       onMessageReceived: (message) async {
//         final msg = message.message;

//         if (msg.startsWith("ERROR")) {
//           completer.completeError(msg);
//           return;
//         }

//         final json = jsonDecode(msg);
//         final lat = json["lat"];
//         final lng = json["lng"];

//         final place = await _getPlaceId(lat, lng);

//         completer.complete({
//           "latitude": lat,
//           "longitude": lng,
//           "place_id": place["place_id"],
//           "address": place["formatted_address"],
//         });
//       },
//     );

//     controller.loadFlutterAsset("assets/location.html");

//     return completer.future;
//   }

//   Future<Map<String, dynamic>> _getPlaceId(double lat, double lng) async {
//     final url = Uri.parse(
//         "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleKey");

//     final res = await http.get(url);
//     final data = jsonDecode(res.body);

//     if (data["status"] != "OK") return {};

//     return {
//       "place_id": data["results"][0]["place_id"],
//       "formatted_address": data["results"][0]["formatted_address"],
//     };
//   }
// }
