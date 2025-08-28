import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/controllers/user_profile_response_controller.dart';
import 'package:urbantutorsapp/screens/admin/admin_dashboard.dart';
import 'package:urbantutorsapp/screens/controllers/profile_controller.dart';
import 'package:urbantutorsapp/screens/student/student_dashboard.dart';
import 'package:urbantutorsapp/screens/tutor/pending_page.dart';
import 'package:urbantutorsapp/screens/tutor/profile_form_tutor%20copy.dart';
import 'package:urbantutorsapp/screens/tutor/profile_form_tutor.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_dashboard.dart';
import 'package:urbantutorsapp/screens/welcome/welcome_screen.dart';
import 'package:urbantutorsapp/services/lead_service.dart';
import 'package:urbantutorsapp/shared/default_dashboard.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import '../theme/theme_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  final ProfileUpdateController _profileUpdateController =
      Get.put(ProfileUpdateController());
  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _logoAnimation =
        CurvedAnimation(parent: _logoController, curve: Curves.easeOut);

    _logoController.forward();
    _navigateAfterDelay();
  }

  // Future<bool> isProfileDone() async {
  //   _profileUpdateController.fetchProfileUpdate();

  //   if (_profileUpdateController.profileData.value!.status == "Active") {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 5));

    final token = await TokenStorage.getToken(); // Get token
    // final role = await TokenStorage.getRole();
    final roleId = await TokenStorage.getRoleId();
    print(roleId);
    print("Comes from tutorDashboard");
    if (!mounted) return;

    Widget target;
    final String? profileStatus = await TokenStorage.getIsProfileActive();

    print("profilstatuse");
    print(profileStatus);
    if (token != null) {
      switch (roleId) {
        case '1':
          target = const StudentDashboardScreen();
          break;
        // case '2':
        //   target = false ? TutorDashboard() : profileStatus == "pending" || profileStatus == null
        //       ? ProfileFormScreen()
        //       : TutorDashboard();
        //   break;
        case '2':
          target = const TutorDashboard();
          break;
        case '3':
          target = const AdminDashboard();
          break;
        default:
          target = const DefaultDashboardScreen();
      }
    } else {
      // No token → go to welcome screen
      target = const WelcomeScreen();
    }

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => target));
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, accent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _logoAnimation,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icons/urban.png',
                            width: 80, // same as diameter
                            height: 80,
                            fit: BoxFit
                                .cover, // ensures the image fills the circle
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Urban Tutors',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Empowering Learning Everywhere',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
