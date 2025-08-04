import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/admin/admit_profile.dart';
import '../theme/theme_constants.dart';

class AdminDrawer extends StatelessWidget {
  final Function(String label) onMenuTap;

  const AdminDrawer({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundImage: AssetImage('assets/icons/profile.jpg'), // Replace with your asset or keep text
                        backgroundColor: Colors.transparent,
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => AdmitProfile());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 3,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nikhil Kumar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: const [
                            Expanded(
                              child: Text(
                                'nikhil@email.com',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Drawer Menu Items
            _drawerItem(Icons.dashboard_customize_rounded, 'Dashboard', isActive: true),
            _drawerItem(Icons.settings, 'Settings'),
            _drawerItem(Icons.info_outline_rounded, 'About Us'),
            _drawerItem(Icons.privacy_tip_rounded, 'Privacy Policy'),
            _drawerItem(Icons.logout, 'Logout', color: Colors.red),
          ],
        ),
      ),
    );
  }

  // Drawer Item with optional active state styling
  Widget _drawerItem(IconData icon, String label, {Color? color, bool isActive = false}) {
    final Color background = isActive ? AppColors.primaryColor.withOpacity(0.08) : Colors.white;
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
