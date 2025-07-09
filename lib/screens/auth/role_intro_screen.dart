import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../../theme/theme_constants.dart';

class RoleIntroScreen extends StatelessWidget {
  final String role;

  const RoleIntroScreen({super.key, required this.role});

  IconData getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'tutor':
        return Icons.school;
      case 'student':
        return Icons.auto_stories;
      default:
        return Icons.account_circle;
    }
  }

  Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.primaryColor;
      case 'tutor':
        return AppColors.primaryColor;
      case 'student':
        return AppColors.primaryColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = getRoleColor(role);
    final icon = getRoleIcon(role);

    return Scaffold(
     
      appBar: AppBar(
        backgroundColor: roleColor,
        title: Text('${role[0].toUpperCase()}${role.substring(1)} Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: roleColor.withOpacity(0.2),
              child: Icon(icon, size: 50, color: roleColor),
            ),
            const SizedBox(height: 30),

            Text(
              'Welcome $role!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: roleColor,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Continue as $role to explore the Urban Tutors platform.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen(role: role)),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: roleColor,
                    minimumSize: const Size(130, 48),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen(role: role)),
                    );
                  },
                  icon: const Icon(Icons.app_registration),
                  label: const Text('Register'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(130, 48),
                    side: BorderSide(color: roleColor),
                    foregroundColor: roleColor,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
