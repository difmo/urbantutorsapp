import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/controllers/lead_controller.dart';
import 'package:urbantutorsapp/screens/admin/CreateLeadScreen.dart';
import 'package:urbantutorsapp/screens/admin/LeadDetailsScreen.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/widgets/AdminDrawer.dart';
import 'package:urbantutorsapp/widgets/CustomFAB.dart';
import 'package:urbantutorsapp/widgets/LeadCardWidget.dart';
import '../../theme/theme_constants.dart';

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

  final LeadController leadController = Get.put(LeadController());

  @override
  void initState() {
    super.initState();
    leadController.fetchLeads(); // fetch on load
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
      await prefs.clear();

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
            onRefresh: () => leadController.fetchLeads(),
            child: Obx(() {
              if (leadController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (leadController.studentLeads.isEmpty) {
                return const Center(child: Text('No leads available.'));
              }

              final leads = leadController.studentLeads;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: leads.length,
                itemBuilder: (context, index) {
                  final lead = leads[index];
                  return LeadCardWidget(
                    studentName: lead.studentName,
                    mobile: lead.mobile.toString(),
                    subject: lead.subjectName,
                    classLevel: lead.courseName,
                    location: lead.location,
                    timing: "NA", // update if timing available
                    coins: lead.price,
                    remarks: lead.remark ?? '',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LeadDetailsScreen(
                            studentName: lead.studentName,
                            mobile: lead.mobile.toString(),
                            subject: lead.subjectName,
                            classLevel: lead.courseName,
                            location: lead.location,
                            timing: "NA",
                            coins: lead.price,
                            remarks: lead.remark ?? '',
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }),
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
