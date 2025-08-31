import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/admin/admin_dashboard.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/student/student_dashboard.dart';
import 'package:urbantutorsapp/screens/student/student_profile_form.dart';
import 'package:urbantutorsapp/screens/tutor/pending_page.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_profile_form.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_dashboard.dart';
import 'package:urbantutorsapp/screens/welcome/welcome_screen.dart';
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
  final MasterDataController _masterDataController =
      Get.put(MasterDataController());
  @override
  void initState() {
    super.initState();
    _masterDataController.fetchMasterData();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );

    _logoController.forward();
    _navigateAfterDelay();
  }

  Future<void> _initProfile() async {
    await _profileUpdateController.fetchProfileForTutor();

    if (_profileUpdateController
            .tutorprofileData.value?.mostExperienceSubjectName !=
        null) {
      print("running init profile ");
      StorageService.saveIsProfileStatus("completed");
    }
  }

  Future<bool> isProfiledataEmpty() async {
    await _profileUpdateController.fetchProfileForStudent();
    if (_profileUpdateController.studentprofileData.value!.boardName!.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await StorageService.getToken();
    final roleId = await StorageService.getRoleId();
    print("Role Id from splash screen  $roleId");
    print("Comes from splash screen");
    if (!mounted) return;
    if (roleId == 2) {
      _initProfile();
    }

    Widget target;
    final String? profileStatus = await StorageService.getIsProfileStatus();

    print("profilstatuse");
    print(profileStatus);
    if (token != null) {
      switch (roleId) {
        case '3':
          target = isProfiledataEmpty() == true || profileStatus == "completed"
              ? StudentDashboardScreen()
              : StudentProfileFormScreen();
          break;
        case '2':
          target = profileStatus == null || profileStatus == "pending"
              ? profileStatus == "pending"
                  ? PendingPage()
                  : TutorProfileFormScreen()
              : TutorDashboard();
          break;
        case '5':
          target = const AdminDashboard();
          break;
        default:
          target = const DefaultDashboardScreen();
      }
    } else {
      // No token → go to welcome screen
      target = const TutorDashboard();
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
