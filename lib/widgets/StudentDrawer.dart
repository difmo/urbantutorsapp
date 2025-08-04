import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/student_profile.dart';
import '../theme/theme_constants.dart';

class StudentDrawer extends StatefulWidget {
  final Function(String label) onMenuTap;

  const StudentDrawer({super.key, required this.onMenuTap});

  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> {
  String selectedLabel = 'Settings'; // Default selected menu

  void handleTap(String label) {
    setState(() {
      selectedLabel = label;
    });
    widget.onMenuTap(label);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: const Text(
                          "S",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => const StudentProfileScreen());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
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
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shaurabh Kumar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'shaurabh@email.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Navigation Items
            _drawerItem(Icons.settings, 'Settings'),
            _drawerItem(Icons.info_outline, 'About Us'),
            _drawerItem(Icons.logout, 'Logout', color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, {Color? color}) {
    final bool isSelected = selectedLabel == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: color ?? Colors.grey.shade800),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: color ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => handleTap(label),
        ),
      ),
    );
  }
}
