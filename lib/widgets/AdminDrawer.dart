import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class AdminDrawer extends StatelessWidget {
  final Function(String label) onMenuTap;

  const AdminDrawer({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: primary.withOpacity(0.2),
                    child: const Text(
                      "N",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Nikhil Kumar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'nikhil@email.com',
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

            const SizedBox(height: 20),

            // Drawer Menu
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(Icons.dashboard_customize_rounded, 'Dashboard', primary, accent),
                  const Divider(indent: 20, endIndent: 20),
                  _drawerItem(Icons.settings, 'Settings', primary, accent),
                  _drawerItem(Icons.info_outline_rounded, 'About Us', primary, accent),
                  _drawerItem(Icons.privacy_tip_rounded, 'Privacy Policy', primary, accent),
                  _drawerItem(Icons.logout, 'Logout', primary, accent),
                ],
              ),
            ),

            // Logout button at bottom
            
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, Color primary, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: primary),
        title: Text(
          label,
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => onMenuTap(label),
        hoverColor: accent.withOpacity(0.1),
      ),
    );
  }
}
