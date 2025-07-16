import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class TutorDrawer extends StatelessWidget {
  final Function(String label) onMenuTap;

  const TutorDrawer({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with profile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
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

            // Drawer options
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

  Widget _drawerItem(IconData icon, String label, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 0.8,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          onTap: () => onMenuTap(label),
        ),
      ),
    );
  }
}
