import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_courses_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_profile_screen.dart';
import 'package:urbantutorsapp/widgets/CustomTeacherNavBar.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme_constants.dart';

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
        key: _scaffoldKey,
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
              SizedBox(width: 8),
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
            _buildNotesList("My Notes"),
            Center(child: Text("Coming Soon")),
            Center(child: Text("Coming Soon")),
          ],
        ),
        

bottomNavigationBar: CustomTeacherNavBar(
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TutorProfileScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CoursesScreen()),
      );
    }
  },
),

      ),
    );
  }

  Widget _buildNotesList(String title) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _noteCard("Maths Notes - Chapter 1", "https://example.com/math1.pdf"),
        SizedBox(height: 12),
        _noteCard(
            "Physics Notes - Motion", "https://example.com/physics_motion.pdf"),
        SizedBox(height: 12),
        _noteCard(
            "Biology Notes - Cells", "https://example.com/biology_cells.pdf"),
      ],
    );
  }

  Widget _noteCard(String title, String pdfUrl) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.redAccent),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              _openPdf(pdfUrl);
            },
          ),
        ],
      ),
    );
  }

  void _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open PDF')),
      );
    }
  }
}
