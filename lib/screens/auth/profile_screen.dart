// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:urbantutorsapp/controllers/user_controller.dart';

// class ProfileScreen extends StatelessWidget {
//   final UserController controller = Get.put(UserController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Profile")),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         }

//         final user = controller.user.value;
//         if (user == null) {
//           return Center(child: Text("No user data found."));
//         }

//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Name: ${user.name}", style: TextStyle(fontSize: 18)),
//               Text("Email: ${user.email}", style: TextStyle(fontSize: 18)),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }

// class Name {
// }
