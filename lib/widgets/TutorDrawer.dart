import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_profile_screen.dart';
import '../theme/theme_constants.dart';

class TutorDrawer extends StatelessWidget {
  final Function(String label) onMenuTap;
  final String activeLabel; // 👈 NEW: To highlight selected menu

  const TutorDrawer({
    Key? key,
    required this.onMenuTap,
    this.activeLabel = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: primaryColor.withOpacity(0.15),
                        child: const Text(
                          "N",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => const TutorProfileScreen());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
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
                              size: 18,
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
                          'Nikhil Kumar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'nikhil@email.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Drawer Items
            _drawerItem(Icons.dashboard_customize_rounded, 'Dashboard'),
            _drawerItem(Icons.settings, 'Settings'),
            _drawerItem(Icons.info_outline_rounded, 'About Us'),
            _drawerItem(Icons.privacy_tip_rounded, 'Privacy Policy'),
            _drawerItem(Icons.logout, 'Logout', color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String label, {
    Color? color,
  }) {
    final bool isActive = label == activeLabel;
    final Color background =
        isActive ? AppColors.primaryColor.withOpacity(0.08) : Colors.transparent;
    final Color iconColor = color ?? Colors.grey.shade800;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => onMenuTap(label),
        ),
      ),
    );
  }
}
