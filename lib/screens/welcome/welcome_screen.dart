import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../auth/role_intro_screen.dart';
import '../../theme/theme_constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void navigateToNext(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoleIntroScreen(role: role)),
    );
  }

  Widget _roleButton(
      BuildContext context, String label, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => navigateToNext(context, label),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.26,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, size: 28, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      body: Stack(
        children: [
          // Background splash
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withOpacity(0.3), primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    // Animated logo
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1000),
                      builder: (_, op, ch) => Opacity(opacity: op, child: ch),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: FaIcon(FontAwesomeIcons.school,
                              size: 50, color: primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title with shimmer
                    TweenAnimationBuilder<Offset>(
                      tween:
                          Tween(begin: const Offset(0, 0.3), end: Offset.zero),
                      duration: const Duration(milliseconds: 800),
                      builder: (_, offset, child) => Transform.translate(
                          offset: offset * 60, child: child),
                      child: Text(
                        'Welcome to Urban Tutors',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Are you a?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 24),
                    ),
                    const SizedBox(height: 40),
                    // Role buttons in a vertical column with staggered animation
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _roleButton(context, 'Admin',
                            FontAwesomeIcons.userShield, primary),
                        const SizedBox(height: 16),
                        _roleButton(
                            context, 'Tutor', FontAwesomeIcons.userTie, accent),
                        const SizedBox(height: 16),
                        _roleButton(
                            context,
                            'Student',
                            FontAwesomeIcons.userGraduate,
                            Colors.deepPurpleAccent),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'By continuing, you agree to our Terms & Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white70.withOpacity(0.9), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
