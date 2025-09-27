import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';

import 'package:urbantutorsapp/controllers/lead_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';
import 'package:urbantutorsapp/models/lead__model.dart';
import 'package:urbantutorsapp/models/tutor_lead.dart';
import 'package:urbantutorsapp/screens/admin/CreateLeadScreen.dart' as create;
import 'package:urbantutorsapp/screens/admin/LeadDetailsScreen.dart' as details;
import 'package:urbantutorsapp/screens/admin/history_admin.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/DashboardHomeTab.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/AdminDrawer.dart';
import 'package:urbantutorsapp/widgets/CustomFAB.dart';
import '../../theme/theme_constants.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  final List<String> _tabs = const ['All Leads'];

  final LeadController leadController = Get.put(LeadController());
  int _selectedIndex = -1;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      leadController.fetchLeads();
    }
  }

  Future<void> _refreshLeads() => leadController.fetchLeads();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // <-- add
    _tabController.dispose();
    super.dispose();
  }

  late final CoinsController _c;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // <-- add
    leadController.fetchLeads();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());
    _c.refreshAll();

    _coins = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());
    _coins.refreshAll();

    _p = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());
    _p.fetchProfileForStudent();
  }

  // Controllers
  final TutorLeadsController _leads = Get.put(TutorLeadsController());

  late final CoinsController _coins;
  late final ProfileUpdateController _p;

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  String _initial(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'S';
    return n.characters.first.toUpperCase();
  }

  String _firstName(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'Student';
    final parts = n.split(RegExp(r'\s+'));
    return parts.first;
  }

  String _greet() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _handleMenuTap(String label) async {
    Navigator.of(context).pop();
    if (label == 'Logout') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await StorageService.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (_) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigating to $label')),
      );
    }
  }

  bool _isGrabbed(TutorLead e) =>
      _leads.grabbedLeads.any((g) => g.grabLeadId == e.id);

  Future<void> _grabThisLead(TutorLead e) async {
    final msg = await _leads.grabLead(e.id.toString());
    if (!mounted) return;
    if (msg != null) {
      Get.snackbar(
        'Success',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else if (_leads.error.isNotEmpty) {
      Get.snackbar(
        'Error',
        _leads.error.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;
    return Scaffold(
      endDrawer: Admindrawer(onMenuTap: _handleMenuTap), // <- ensure class name
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.transparent,
        toolbarHeight: 75,
        titleSpacing: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Obx(() {
          final loading =
              _coins.loadingCoins.value || _coins.loadingMyCoins.value;
          final wallet = _coins.myCoins.value;
          final balanceStr = _toNum(wallet?.available).toStringAsFixed(0);
          final prof = _p.studentprofileData.value;
          final name = prof?.studentName?.trim();
          final initial = _initial(name);
          final displayName = _firstName(name);
          final greet = _greet();
          if (loading && wallet == null) {
            return const SizedBox(
              height: 24,
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          return Row(
            children: [
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: AppColors.primaryColor),
                  gradient: LinearGradient(
                    colors: [primary, accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 20,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greet,',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TutorCoinsScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(width: 2, color: AppColors.primaryColor),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 6),
                        Text(
                          "Coins: $balanceStr",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          );
        }),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 45),
              onPressed: () => Scaffold.maybeOf(ctx)?.openEndDrawer(),
            ),
          ),
          const SizedBox(height: 8),
        ],
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
                            ? 'No Leads Created'
                            : 'No $label yet',
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "( Kindly, Add Your Leads )",
                        style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.primaryColor,
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
                  print(lead);
                  return GestureDetector(
                    onTap: () => _openDetails(lead),
                    child: _LeadCard(
                      lead: lead,
                      isContacted: true,
                      onContactToggle: () => {},
                      onReadMore: () => _openDetails(lead),
                    ),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              elevation: 10,
              color: Colors.white.withOpacity(.92),
              child: SizedBox(
                height: 68,
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        icon: FontAwesomeIcons.house,
                        label: 'Home',
                        selected: _selectedIndex == 2,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedIndex = 2);
                        },
                      ),
                    ),

                    // Gap for center FAB
                    const SizedBox(width: 56),

                    // Right item
                    Expanded(
                      child: _NavItem(
                        icon: Icons.history,
                        label: 'Report',
                        selected: _selectedIndex == 0,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedIndex = 0);

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => HistoryAdmin()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDetails(StudentLead lead) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => details.LeadDetailsScreen(enquiry: lead),
      ),
    );
    if (!mounted) return;
    await _refreshLeads(); // <- refresh after return
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = Colors.lightGreen;
    final inactive = const Color(0xFF9AA1A6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48), // preferred height
        child: Center(
          // If a parent ever squeezes it (like 20px), this scales down
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: selected ? active : inactive),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.black87 : inactive,
                  ),
                ),
                const SizedBox(height: 4),
                if (selected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration:
                        BoxDecoration(color: active, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({
    required this.lead,
    required this.isContacted,
    required this.onContactToggle,
    required this.onReadMore,
  });

  final StudentLead lead;
  final bool isContacted;
  final VoidCallback? onContactToggle; // null => disabled
  final VoidCallback onReadMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: AppColors.primaryColor),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Lead No: ',
                      style: const TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${lead.id}",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                Text(
                  lead.createdAt != null ? _fmtDate(lead.createdAt!) : '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _kv(Icons.school, 'Name', lead.studentName),
            const SizedBox(height: 6),
            _kv(Icons.school, 'Class', lead.courseName),
            const SizedBox(height: 4),
            _kv(Icons.book, 'Subject', lead.subjectName),
            const SizedBox(height: 4),
            _kv(Icons.location_on, 'Location',
                "${lead.location},${lead.state}"),
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Mode + 0/3 pill
                LeadMetaRow(
                  icon: Icons.switch_video, // pick any icon you prefer
                  label: 'Mode',
                  value: lead.mode,
                  iconColor: AppColors.accentColor,
                  trailing: leadCountPill('0/3'),
                ),
                const SizedBox(height: 6),

                // Row 2: Fee + "(Read more)" + right-aligned status
                LeadMetaRow(
                  icon: Icons.attach_money,
                  label: 'Fee',
                  value: "₹${lead.price}/Hr",
                  iconColor: AppColors.accentColor,
                  inlineLinkText: '(Read more)',
                  onInlineLinkTap: onContactToggle,
                  trailing: const Text(
                    'Responded',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _kv(IconData icon, String label, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentColor, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700, // bold label
                    color: AppColors.textColor,
                  ),
                ),
                TextSpan(
                  text: text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400, // normal value
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
