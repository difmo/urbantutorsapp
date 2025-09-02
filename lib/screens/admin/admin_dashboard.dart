import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';

import 'package:urbantutorsapp/controllers/lead_controller.dart';
import 'package:urbantutorsapp/screens/admin/CreateLeadScreen.dart' as create;
import 'package:urbantutorsapp/screens/admin/LeadDetailsScreen.dart' as details;
import 'package:urbantutorsapp/screens/admin/history_screen.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
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
  final List<String> _tabs = const ['All Leads', 'Grabbed', 'Declined'];

  final LeadController leadController = Get.put(LeadController());
  int _selectedIndex = -1;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  late final CoinsController _c;
  @override
  void initState() {
    super.initState();
    leadController.fetchLeads();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());

    _c.refreshAll();
  }

  Future<void> _handleMenuTap(String label) async {
    Navigator.of(context).pop();
    if (label == 'Logout') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await StorageService.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (_) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Navigating to $label')));
    }
  }

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: AdminDrawer(onMenuTap: _handleMenuTap),
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 2,
        title: Obx(() {
          final loading = _c.loadingCoins.value || _c.loadingMyCoins.value;
          final wallet = _c.myCoins.value; // Rxn<...> -> nullable model

          // Format safely (int/double/String/null)
          final balanceNum = _toNum(wallet?.available);
          final balanceText = balanceNum.toStringAsFixed(0);

          if (loading && wallet == null) {
            return const SizedBox(
              height: 24,
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          return Row(children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primary, accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: const CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 24,
                child: Text('A',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Welcome, Admin',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TutorCoinsScreen()));
              },
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
                    Text(
                      "$balanceText coins",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ]);
        }),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
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

              final all = leadController.studentLeads;

              // -------- filter per tab (works with numeric or text status) -----
              List filtered;
              if (label == 'Grabbed') {
                filtered = all.where((l) {
                  final s = (l.status ?? '').toString().toLowerCase();
                  return s == 'grabbed' || s == '2';
                }).toList();
              } else if (label == 'Declined') {
                filtered = all.where((l) {
                  final s = (l.status ?? '').toString().toLowerCase();
                  return s == 'declined' || s == '3';
                }).toList();
              } else {
                filtered = all; // All Leads
              }
              // ------------------------------------------------------------------

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/icons/animation/empty.json',
                        width: 220,
                        repeat: true,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        label == 'All Leads'
                            ? 'No leads available'
                            : 'No $label yet',
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final lead = filtered[index];
                  return LeadCardWidget(
                    studentName: lead.studentName ?? '—',
                    mobile: (lead.mobile ?? '').toString(),
                    subject: lead.subjectName ?? '—',
                    classLevel: lead.courseName ?? '—',
                    location: lead.location ?? '—',
                    timing: "NA",
                    coins: lead.price ?? '0',
                    remarks: lead.remark ?? '',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => details.LeadDetailsScreen(lead: lead),
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
            MaterialPageRoute(builder: (_) => const create.CreateLeadScreen()),
          );
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
                icon: Icon(
                  FontAwesomeIcons.house,
                  color: _selectedIndex == 2
                      ? Colors.lightGreen
                      : const Color(0xFFCACFCC),
                ),
                onPressed: () => setState(() => _selectedIndex = 2),
              ),
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.clockRotateLeft,
                  color: _selectedIndex == 0
                      ? Colors.lightGreen
                      : const Color(0xFFCACFCC),
                ),
                onPressed: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminHistoryScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
