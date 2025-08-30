import 'package:flutter/material.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/ChatUserListScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/HistoryScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/HomeScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/SupportScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/UpgradeScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/coins_student.dart';
import 'package:urbantutorsapp/screens/student/pdf_courses_screen.dart';
import 'package:urbantutorsapp/screens/student/pyq_screen.dart';
import 'package:urbantutorsapp/screens/student/search_tutor_screen.dart';

import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/CustomStudentNavBar.dart';
import 'package:urbantutorsapp/widgets/StudentDrawer.dart';
import '../../theme/theme_constants.dart';
import 'notes_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ChatUserListScreen(),
    UpgradeScreen(),
    HistoryScreen(),
    SupportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return Scaffold(
      endDrawer: StudentDrawer(onMenuTap: (label) async {
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
            MaterialPageRoute(builder: (context) => SplashScreen()),
            (route) => false,
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigating to $label')),
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
            SizedBox(width: 12),
            Text('Welcome, Student',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            Spacer(),
            SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CoinsStudent()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.monetization_on, color: accentColor, size: 10),
                    const SizedBox(width: 6),
                    Text(
                      "200 coins",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardBody(primaryColor, accentColor),
          _screens[1],
          _screens[2],
          _screens[3],
          _screens[4],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: CustomStudentNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }

  Widget _buildDashboardBody(Color primaryColor, Color accentColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Card
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          //   child: Container(
          //     padding: const EdgeInsets.all(16),
          //     decoration: BoxDecoration(
          //       color: accentColor.withOpacity(0.1),
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(color: accentColor),
          //     ),
          //     child: Row(
          //       children: [
          //         Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             const Text('Monthly Progress',
          //                 style: TextStyle(fontWeight: FontWeight.bold)),
          //             const SizedBox(height: 4),
          //             Text('75% completed',
          //                 style: TextStyle(color: primaryColor)),
          //             const SizedBox(height: 8),
          //             SizedBox(
          //               width: 150,
          //               child: LinearProgressIndicator(
          //                   value: 0.75, color: primaryColor),
          //             ),
          //           ],
          //         ),
          //         const Spacer(),
          //         Icon(Icons.bar_chart, color: primaryColor, size: 40),
          //       ],
          //     ),
          //   ),
          // ),

          // Grid Features
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _featureTile('Notes', Icons.note, primaryColor),
                _featureTile('PYQ’s', Icons.assignment_turned_in, primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Full Width Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _fullWidthTile(
                    'Courses (PDF)', Icons.picture_as_pdf, accentColor,
                    height: 130), // 👈 Taller
                const SizedBox(height: 12),
                _fullWidthTile(
                    'Search Private Tutor', Icons.search, primaryColor,
                    height: 130), // 👈 Taller
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureTile(String label, IconData icon, Color iconColor) {
    return GestureDetector(
      onTap: () {
        if (label == 'Notes') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotesScreenStudent()),
          );
        } else if (label == 'PYQ’s') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PyqScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // 🔹 Updated to support custom height
  Widget _fullWidthTile(String label, IconData icon, Color iconColor,
      {double? height}) {
    return GestureDetector(
      onTap: () {
        if (label == 'Courses (PDF)') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PDFCoursesScreen()),
          );
        } else if (label == 'Search Private Tutor') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchTutorScreen()),
          );
        }
      },
      child: Container(
        height: height, // 👈 Apply height only when passed
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
