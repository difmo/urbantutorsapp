import 'package:flutter/material.dart';
import '../auth/role_intro_screen.dart';
import '../../theme/theme_constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void navigateToNext(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoleIntroScreen(role: role),
      ),
    );
  }

  Widget _roleButton(BuildContext context, String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => navigateToNext(context, label),
      icon: Icon(icon, size: 20),
      label: Text(
        label.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryColor,
                  child: Icon(Icons.school, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 30),

                const Text(
                  'Welcome to Urban Tutors',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Who are you?',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 24),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _roleButton(context, 'admin', Icons.admin_panel_settings),
                    _roleButton(context, 'tutor', Icons.person_outline),
                    _roleButton(context, 'student', Icons.auto_stories),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
