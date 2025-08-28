// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/user_profile_response_model.dart';

// class UserProfileResponseController {


//   /// Fetch profile (GET)
//   Future<UserProfileResponseModel?> getUserProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse(baseUrl),
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//           // "Authorization": "Bearer YOUR_TOKEN", // if needed
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return UserProfileResponseModel.fromJson(data);
//       } else {
//         print("❌ Error: ${response.statusCode} - ${response.body}");
//         return null;
//       }
//     } catch (e) {
//       print("❌ Exception in getUserProfile: $e");
//       return null;
//     }
//   }

//   /// Update profile (PUT/POST depending on backend)
//   Future<UserProfileResponseModel?> updateProfile(
//       Map<String, dynamic> updateData) async {
//     try {
//       final response = await http.put(
//         Uri.parse(baseUrl),
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//           // "Authorization": "Bearer YOUR_TOKEN", // if needed
//         },
//         body: jsonEncode(updateData),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return UserProfileResponseModel.fromJson(data);
//       } else {
//         print("❌ Error: ${response.statusCode} - ${response.body}");
//         return null;
//       }
//     } catch (e) {
//       print("❌ Exception in updateProfile: $e");
//       return null;
//     }
//   }
// }
