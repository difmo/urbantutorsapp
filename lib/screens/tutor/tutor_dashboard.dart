import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/DashboardHomeTab.dart';
import 'package:urbantutorsapp/screens/tutor/notes_tutor.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_chat_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_courses_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_pyq_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_support_screen.dart';
import 'package:urbantutorsapp/widgets/CustomTeacherNavBar.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  final TutorLeadsController _leads = Get.put(TutorLeadsController());

  RangeValues _currentRangeValues = const RangeValues(1, 10);
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardHomeTab(),
    const NotesTutor(),
    const TutorPYQScreen(),
    CoursesScreen(),
    const TutorChatScreen(),
    const TutorSupportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
          endDrawer: TutorDrawer(onMenuTap: (label) async {
            if (label == 'Logout') {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              await prefs.remove('user_name');
              await prefs.remove('user_phone');
              await prefs.remove('user_role');
              await StorageService.clearTokenAndRole();
              await StorageService.clear();

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
                (route) => false,
              );
            }
          }),
          appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              elevation: 2,
              toolbarHeight: 75,
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primaryColor, accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 24,
                      child: Text(
                        'S',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Welcome, Tutor',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TutorCoinsScreen()));
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.monetization_on,
                                color: accentColor, size: 14),
                            const SizedBox(width: 6),
                            const Text(
                              "200 coins",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              )),
          body: _screens[_currentIndex], // ✅ show selected screen
          bottomNavigationBar: CustomTeacherNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          )),
    );
  }
}
