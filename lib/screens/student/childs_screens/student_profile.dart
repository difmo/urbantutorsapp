import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/student_profile_edit.dart';

import 'package:urbantutorsapp/theme/theme_constants.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top wave
          ClipPath(
            clipper: TopWaveClipper(),
            child: Container(
              height: 260,
              color: themeColor.withOpacity(0.2),
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Icon(Icons.arrow_back, color: themeColor),
              ),
            ),
          ),

          // Edit Button
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Get.to(() => const StudentProfileScreenEdit()),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Icon(Icons.edit, color: themeColor),
              ),
            ),
          ),

          // Profile content
          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/icons/profile.jpg'),
                ),
                const SizedBox(height: 20),
                _infoTile(Icons.person, "Name", "John Doe"),
                _infoTile(Icons.email, "Email", "john.doe@email.com"),
                _infoTile(Icons.phone, "Phone", "9876543210"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
