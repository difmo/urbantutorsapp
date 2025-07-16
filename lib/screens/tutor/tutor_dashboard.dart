import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/widgets/CustomTeacherNavBar.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';
import '../../theme/theme_constants.dart'; // AppColors with primary & accent colors

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
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
            Text('Urban Tutors',
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
        body: TabBarView(
          children: [
            _buildLeadsList("Nearby Leads"),
            _buildLeadsList("Enquiry Leads"),
            _buildLeadsList("Contacted Leads"),
          ],
        ),
        bottomNavigationBar: CustomTeacherNavBar(
          currentIndex: 0,
          onTap: (index) {
            // Handle navigation
          },
        ),
      ),
    );
  }

  Widget _buildLeadsList(String type) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _leadCard("Math Tuition in Delhi", type),
        SizedBox(height: 12),
        _leadCard("Physics Class for Class 12", type),
        SizedBox(height: 12),
        _leadCard("Home Tutor for Grade 5", type),
        SizedBox(height: 24),
        Center(child: Icon(Icons.arrow_downward, color: Colors.grey)),
      ],
    );
  }

  Widget _leadCard(String title, String category) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.school, color: AppColors.primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(category,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
