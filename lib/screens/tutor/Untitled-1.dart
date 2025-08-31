import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/enquiry_details_page_tutor.dart';
import 'package:urbantutorsapp/screens/tutor/notes_tutor.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_chat_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_courses_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_pyq_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_support_screen.dart';

import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/CustomTeacherNavBar.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';
import '../../theme/theme_constants.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});
  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardHomeTab(),
    const NotePage(),
    const TutorPYQScreen(),
    CoursesScreen(),
    const TutorChatScreen(),
    const TutorSupportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _screens[_currentIndex], // ✅ show selected screen
      bottomNavigationBar: CustomTeacherNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

/// ✅ Extracted Dashboard main tab (Nearby / Enquiry / Contacted)
class DashboardHomeTab extends StatefulWidget {
  const DashboardHomeTab({super.key});

  @override
  State<DashboardHomeTab> createState() => _DashboardHomeTabState();
}

class _DashboardHomeTabState extends State<DashboardHomeTab> {
  RangeValues _currentRangeValues = const RangeValues(1, 10);

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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.accentColor,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.accentColor,
            tabs: [
              Tab(text: "Nearby", icon: Icon(Icons.location_on)),
              Tab(text: "ENQUIRY", icon: Icon(Icons.message)),
              Tab(text: "CONTACTED", icon: Icon(Icons.check_circle)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNearbyTab(),
            _buildEnquiryTab(),
            const Center(child: Text("No Data Available")),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selected Range: ${_currentRangeValues.start.round()} km - ${_currentRangeValues.end.round()} km",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          RangeSlider(
            values: _currentRangeValues,
            min: 1,
            max: 50,
            divisions: 49,
            labels: RangeLabels(
              "${_currentRangeValues.start.round()} km",
              "${_currentRangeValues.end.round()} km",
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
              });
            },
            activeColor: AppColors.accentColor,
            inactiveColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildEnquiryTab() {
    final enquiries = [
      {
        "lead": "489",
        "date": "Aug 26, 2025",
        "class": "12th NIOS",
        "subject": "Biology, English",
        "location": "Pi 2, Greater Noida",
        "mode": "Offline",
        "fee": "₹700/Hrs",
      },
      {
        "lead": "488",
        "date": "Aug 26, 2025",
        "class": "6th CBSE",
        "subject": "All Subjects",
        "location": "Amrapali Dream Valley, Greater Noida",
        "mode": "Offline",
        "fee": "₹6K/Month",
      },
    ];

    return Container(
      color: AppColors.backgroundColor,
      child: ListView.builder(
        itemCount: enquiries.length,
        itemBuilder: (context, index) {
          final item = enquiries[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Lead No: ${item["lead"]}",
                          style: const TextStyle(
                              color: AppColors.accentColor,
                              fontWeight: FontWeight.bold)),
                      Text(item["date"]!,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.school,
                        color: AppColors.accentColor, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text("Class: ${item["class"]}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor))),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.book,
                        color: AppColors.accentColor, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text("Subject: ${item["subject"]}",
                            style:
                                const TextStyle(color: AppColors.textColor))),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on,
                        color: AppColors.accentColor, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text("Location: ${item["location"]}",
                            style:
                                const TextStyle(color: AppColors.textColor))),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.computer,
                        color: AppColors.accentColor, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text("Mode: ${item["mode"]}",
                            style:
                                const TextStyle(color: AppColors.textColor))),
                  ]),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.attach_money,
                          size: 18, color: AppColors.accentColor),
                      const SizedBox(width: 4),
                      Text(item["fee"]!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor)),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LeadDetailPage(enquiry: item),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text("Read More",
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
