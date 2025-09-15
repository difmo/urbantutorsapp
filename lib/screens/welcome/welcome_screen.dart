import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:urbantutorsapp/screens/auth/role_intro_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme_constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void navigateToNext(BuildContext context, String role, int roleId) async {
    print("roll print ho jaa bhai maan bhi jaa bhai");
    if (role == "Private Tutor") {
      Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => RoleIntroScreen(
                  role: "Private Tutor",
                  roleId: roleId,
                )),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => RoleIntroScreen(
                  role: role,
                  roleId: roleId,
                )),
      );
    }
  }

  /// Reusable Role Button
  Widget _roleButton(BuildContext context, String label, int roleId,
      IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => navigateToNext(context, label, roleId),
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
                offset: const Offset(0, 4),
              ),
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
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    // Logo animation
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
                          radius: 40,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icons/urban.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    TweenAnimationBuilder<Offset>(
                      tween:
                          Tween(begin: const Offset(0, 0.3), end: Offset.zero),
                      duration: const Duration(milliseconds: 800),
                      builder: (_, offset, child) => Transform.translate(
                          offset: offset * 60, child: child),
                      child: const Text(
                        'Welcome to Urban Tutors.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Are you a',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    //Buttons
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _roleButton(
                          context,
                          'Student / Parents',
                          3,
                          FontAwesomeIcons.userGraduate,
                          Colors.deepPurpleAccent,
                        ),
                        const SizedBox(height: 16),
                        _roleButton(
                          context,
                          'Private Tutor',
                          2,
                          FontAwesomeIcons.userTie,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _roleButton(
                          context,
                          'Tutors Bureau',
                          5,
                          FontAwesomeIcons.userShield,
                          primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    GestureDetector(
                      onTap: () async {
                        const url =
                            'https://www.urbantutors.pro/terms-and-conditions';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(
                                text: 'By continuing, you agree to our '),
                            TextSpan(
                              text: 'Terms',
                              style: const TextStyle(
                                color: Color(0xFF1E88E5),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  const url =
                                      'https://www.urbantutors.pro/terms-and-conditions';
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(
                                      Uri.parse(url),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: Color(0xFF1E88E5),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  const url =
                                      'https://www.urbantutors.pro/privacy-policy';
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(
                                      Uri.parse(url),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
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
