import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/admin/admin_profile_edit.dart';
import 'package:urbantutorsapp/screens/controllers/profile_controller.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class AdmitProfile extends StatefulWidget {
  const AdmitProfile({Key? key}) : super(key: key);

  @override
  _AdmitProfileState createState() => _AdmitProfileState();
}

class _AdmitProfileState extends State<AdmitProfile> {
  final TextEditingController nameController =
      TextEditingController(text: "Nikhil Kumar");

  final ProfileController profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    TokenStorage.getToken().then((token) {
      if (token != null) {
        profileController.fetchUserProfile(token);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top Curve
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
              onTap: () {
                Get.back(); // 👈 Go back to previous screen
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

          // Edit Button
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Get.to(() => const AdminProfileEdit());
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

          // Content
          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/icons/profile.jpg'),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoTile(Icons.person, "Name", "Nikhil Kumar"),
                  _buildInfoTile(Icons.apartment, "Department", "Technology"),
                  _buildInfoTile(Icons.phone, "Phone", "+91 9876543210"),
                  _buildInfoTile(Icons.email, "Email", "nikhil@email.com"),
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
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
