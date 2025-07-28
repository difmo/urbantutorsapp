import 'package:flutter/material.dart';
import 'package:urbantutorsapp/screens/auth/login_screen.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/ChatUserListScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/HistoryScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/HomeScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/SupportScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/UpgradeScreen.dart';
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
          await TokenStorage.clearTokenAndRole();
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
          // Navigate to respective screen
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigating to $label')),
          );
        }
      }),
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              child: Text('S', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(width: 12),
            Text('Welcome, Student',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: primaryColor)),
            Spacer(),
            SizedBox(
              width: 8,
            ),
            Container(
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
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: AppColors.primaryColor),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly Progress',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('75% completed',
                          style: TextStyle(color: primaryColor)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 150,
                        child: LinearProgressIndicator(
                            value: 0.75, color: primaryColor),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.bar_chart, color: primaryColor, size: 40),
                ],
              ),
            ),
          ),

          // Grid Features
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
                _featureTile('Assignments', Icons.assignment, primaryColor),
                _featureTile('Schedule', Icons.calendar_today, primaryColor),
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
                    'Courses (PDF)', Icons.picture_as_pdf, accentColor),
                const SizedBox(height: 12),
                _fullWidthTile(
                    'Search Private Tutor', Icons.search, primaryColor),
                const SizedBox(height: 12),
                _fullWidthTile(
                    'Join Live Class', Icons.video_call, primaryColor),
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
          // Navigate to Notes Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotesScreen()),
          );
        }else if (label == 'PYQ’s') {
          // Navigate to PYQ's Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PYQScreen()), // Replace with actual PYQ's screen
          );
        } else if (label == 'Assignments') {
          // Navigate to Assignments Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotesScreen()), // Replace with actual Assignments screen
          );
        } else if (label == 'Schedule') {
          // Navigate to Schedule Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotesScreen()), // Replace with actual Schedule screen
          );
        }
        // Add more conditions for other features if needed
        // Navigate to respective feature screen
    
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

  Widget _fullWidthTile(String label, IconData icon, Color iconColor) {
    return GestureDetector(
      onTap: () {
        if (label == 'Courses (PDF)') {
          // Navigate to PDF Courses Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PDFCoursesScreen()),
          );
        } else if (label == 'Search Private Tutor') {
          // Navigate to Search Tutor Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchTutorScreen()), // Replace with actual Search Tutor screen
          );
        } else if (label == 'Join Live Class') {
          // Navigate to Live Class Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotesScreen()), // Replace with actual Live Class screen
          );
        }
      },
      child: Container(
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
