import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/welcome/welcome_screen.dart';
import 'package:urbantutorsapp/utils/home_router.dart';
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

  Future<void> _initTeacherProfile() async {
    await _profileUpdateController.fetchProfileForTutor();
    final status =
        _profileUpdateController.tutorprofileData.value?.profileStatus;
    if (status != null) {
      await StorageService.saveIsProfileStatus(status);
    }
  }

  Future<void> _initStudentProfile() async {
    await _profileUpdateController.fetchProfileForStudent();
    final status =
        _profileUpdateController.studentprofileData.value?.profile_status;
    if (status != null) {
      await StorageService.saveIsProfileStatus(status);
    }
  }

  Future<void> _initAdminProfile() async {
    await _profileUpdateController.fetchProfileForAdmin();
    final status =
        _profileUpdateController.adminProfileData.value?.tutorburoProfileStatus;
    if (status != null) {
      await StorageService.saveIsProfileStatus(status);
    }
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await StorageService.getToken();
    final roleId = await StorageService.getRoleId();
    if (!mounted) return;
    // Refresh the profile status from the server before routing, so a
    // profile approved since the last launch opens the right screen. If the
    // server is slow or unreachable, fall back to the stored status.
    if (token != null) {
      final refresh = switch (roleId) {
        3 => _initStudentProfile(),
        2 => _initTeacherProfile(),
        5 => _initAdminProfile(),
        _ => Future<void>.value(),
      };
      try {
        await refresh.timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('Splash profile refresh failed: $e');
      }
      if (!mounted) return;
    }

    final profileStatus = await StorageService.getIsProfileStatus();
    if (!mounted) return;

    final Widget dashboard = token != null
        ? homeScreenFor(roleId, profileStatus)
        : const WelcomeScreen();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => dashboard));
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
                      color: Colors.white.withValues(alpha: 0.2),
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
