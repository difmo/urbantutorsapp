import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_profile_screen_edit.dart';
import '../../theme/theme_constants.dart';

class TutorProfileScreen extends StatelessWidget {
  const TutorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🌊 Top curved background
          ClipPath(
            clipper: TopWaveClipper(),
            child: Container(
              height: 260,
              color: themeColor.withOpacity(0.2),
            ),
          ),

          // 🔙 Back button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back, color: themeColor),
              ),
            ),
          ),

          // ✏️ Edit button
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Get.to(() => TutorProfileScreenEdit());// TODO: Navigate to edit screen
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(Icons.edit, color: themeColor),
              ),
            ),
          ),

          // 🧾 Profile content
          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 👤 Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/icons/profile.jpg'),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 20),

                  _buildInfoTile(Icons.person, "First Name", "Christian"),
                  _buildInfoTile(Icons.person_outline, "Last Name", "Joseph"),
                  _buildInfoTile(Icons.phone, "Phone Number", "+91 987654321"),
                  _buildInfoTile(Icons.email, "Email", "josephc@hotmail.com"),
                  _buildInfoTile(Icons.school, "School", "Halton District School Board"),
                  _buildInfoTile(Icons.menu_book, "Program", "M.B.A"),
                  _buildInfoTile(Icons.book_online, "Subject", "Math"),
                  const SizedBox(height: 16),

                 
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
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

/// 🌊 Wave clipper for curved background
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
