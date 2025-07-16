import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/screens/admin/CreateLeadScreen.dart';
import 'package:urbantutorsapp/screens/admin/LeadDetailsScreen.dart';
import 'package:urbantutorsapp/widgets/AdminDrawer.dart';
import 'package:urbantutorsapp/widgets/CustomFAB.dart';
import 'package:urbantutorsapp/widgets/LeadCardWidget.dart';
import '../../theme/theme_constants.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TabController _tabController;
  final List<String> _tabs = ['All Leads', 'Grabbed', 'Declined'];

  final List<Map<String, String>> _dummyLeads = List.generate(8, (i) {
    return {
      'studentName': 'Student #${i + 1}',
      'mobile': '98${70000000 + i}',
      'subject': ['Math', 'Science', 'English', 'Physics'][i % 4],
      'classLevel': 'Class ${6 + (i % 7)}',
      'location': ['Delhi', 'Mumbai', 'Bangalore', 'Chennai'][i % 4],
      'timing': '${4 + i % 3}:00 PM',
      'coins': '${20 + i * 5}',
      'remarks': i % 2 == 0 ? 'Requires weekend sessions' : '',
    };
  });

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleMenuTap(String label) async {
    Navigator.of(context).pop();
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
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: AdminDrawer(onMenuTap: _handleMenuTap),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            CircleAvatar(
                backgroundColor: primary,
                child: const Text('A', style: TextStyle(color: Colors.white))),
            const SizedBox(width: 12),
            Text('Admin Panel',
                style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
            const Spacer(),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: accent, size: 16),
                    const SizedBox(width: 4),
                    Text('Stats',
                        style: TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.menu, color: primary),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accent,
          labelColor: primary,
          unselectedLabelColor: Colors.grey,
          tabs: _tabs.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: _tabs.map((label) {
          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _dummyLeads.map((data) {
                return LeadCardWidget(
                  studentName: data['studentName']!,
                  mobile: data['mobile']!,
                  subject: data['subject']!,
                  classLevel: data['classLevel']!,
                  location: data['location']!,
                  timing: data['timing']!,
                  coins: data['coins']!,
                  remarks: data['remarks']!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LeadDetailsScreen(
                          studentName: data['studentName']!,
                          mobile: data['mobile']!,
                          subject: data['subject']!,
                          classLevel: data['classLevel']!,
                          location: data['location']!,
                          timing: data['timing']!,
                          coins: data['coins']!,
                          remarks: data['remarks']!,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CustomFAB(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateLeadScreen()));
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(FontAwesomeIcons.house, color: primary),
                  onPressed: () {}),
              IconButton(
                  icon: Icon(FontAwesomeIcons.clockRotateLeft, color: primary),
                  onPressed: () {})
            ],
          ),
        ),
      ),
    );
  }
}
