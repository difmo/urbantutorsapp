import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart';
import 'package:urbantutors_app/screens/welcome/welcome_screen.dart';
import 'package:urbantutors_app/screens/tutor/support_screen.dart';
import 'package:urbantutors_app/screens/tutor/contacted_leads_screen.dart';
import 'package:urbantutors_app/screens/tutor/tutor_courses_screen.dart';
import 'package:urbantutors_app/screens/tutor/tutor_profile_screen.dart';

class TutorDashboardScreen extends StatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  State<TutorDashboardScreen> createState() => _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends State<TutorDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabBarViews = [
    TabBarView(
      children: [
        _buildLeadsList("Nearby Leads"),
        _buildLeadsList("Enquiry Leads"),
        _buildLeadsList("Contacted Leads"),
      ],
    ),
    const TeacherProfileScreen(), // This is the profile screen
    const CourseListScreen(), // This is the courses screen
    const SimpleTutorChatBot(), // This is the chat bot screen
    const TutorSupportPage(), // This is the support screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static Widget _buildLeadsList(String type) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _leadCard("Math Tuition in Delhi", type),
        const SizedBox(height: 12),
        _leadCard("Physics Class for Class 12", type),
        const SizedBox(height: 12),
        _leadCard("Home Tutor for Grade 5", type),
        const SizedBox(height: 24),
        const Center(child: Icon(Icons.arrow_downward, color: Colors.grey)),
      ],
    );
  }

  static Widget _leadCard(String title, String category) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.school, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF29A745)),
                child: Text(
                  'Urban Tutors Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('T', style: TextStyle(color: primaryColor)),
              ),
              const SizedBox(width: 12),
              const Text('Urban Tutors', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('Coins', style: TextStyle(fontSize: 12, color: Colors.white)),
                  Text('(Upgrade)', style: TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.account_circle),
            ],
          ),
          bottom: _selectedIndex == 0
              ? const TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: "Nearby"),
                    Tab(text: "Enquiry"),
                    Tab(text: "Contacted"),
                  ],
                )
              : null,
        ),
        body: _tabBarViews[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
          ],
        ),
      ),
    );
  }
}
