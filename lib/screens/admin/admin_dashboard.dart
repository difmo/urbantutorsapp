import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/lead_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';

import 'package:urbantutorsapp/models/lead__model.dart';
import 'package:urbantutorsapp/models/tutor_lead.dart';

import 'package:urbantutorsapp/screens/admin/CreateLeadScreen.dart' as create;
import 'package:urbantutorsapp/screens/admin/LeadDetailsScreen.dart' as details;
import 'package:urbantutorsapp/screens/admin/add_tutor_admin.dart';
import 'package:urbantutorsapp/screens/admin/history_admin.dart';
import 'package:urbantutorsapp/screens/admin/promot_admin.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';

import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/AdminDrawer.dart';
import '../../theme/theme_constants.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;

  // Tab labels
  final List<String> _tabs = const [
    'All Posted Leads',
    'Grabed Leads',
    'Declined Leads',
  ];

  final LeadController leadController = Get.put(LeadController());
  final TutorLeadsController _leads = Get.put(TutorLeadsController());

  late final CoinsController _coins;
  late final ProfileUpdateController _p;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    leadController.fetchLeads();

    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(() => setState(() {}));

    _coins = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());
    _coins.refreshAll();

    _p = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());
    _p.fetchProfileForStudent();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      leadController.fetchLeads();
    }
  }

  Future<void> _refreshLeads() => leadController.fetchLeads();

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawer: Admindrawer(onMenuTap: (label) async {
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
            MaterialPageRoute(builder: (context) => const SplashScreen()),
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
        elevation: 0, // cleaner edge; we'll draw our own line
        backgroundColor: Colors.transparent,
        toolbarHeight: 88,
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
                  radius: 18,
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
              const SizedBox(width: 10),
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
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TutorCoinsScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 2, color: AppColors.primaryColor),
                  ),
                  child: Text(
                    "Coins: $balanceStr",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(38),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                height: 2,
                thickness: 1,
                color: Colors.white.withOpacity(0.28),
              ),
              TabBar(
                tabAlignment: TabAlignment.center,
                controller: _tabController,
                isScrollable: true,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                padding: EdgeInsets.zero,
                indicatorPadding: EdgeInsets.zero,
                // visual tweaks
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 2,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                // (Optional) slightly smaller text to visually reduce height
                labelStyle: const TextStyle(fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                tabs: _tabs
                    .map(
                      (t) => Center(
                        child:
                            Text(t, maxLines: 1, overflow: TextOverflow.fade),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
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
        children: _tabs.asMap().entries.map((entry) {
          final tabIndex = entry.key;
          final tabLabel = entry.value;

          return RefreshIndicator(
            onRefresh: _refreshLeads,
            child: Obx(() {
              if (leadController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final all = leadController.studentLeads;

              // Filter
              late final List<StudentLead> filtered;
              if (tabIndex == 1) {
                filtered = all.where((l) {
                  final s = (l.status ?? '').toString().toLowerCase();
                  return s.contains('grab') || s == '2' || s == 'grabbed';
                }).toList();
              } else if (tabIndex == 2) {
                filtered = all.where((l) {
                  final s = (l.status ?? '').toString().toLowerCase();
                  return s.contains('declin') || s == '3';
                }).toList();
              } else {
                filtered = all;
              }

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/icons/animation/empty.json',
                        width: 200,
                        repeat: true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tabIndex == 0
                            ? 'No Leads Created'
                            : 'No Leads ${tabLabel.replaceAll("Leads", "").trim()} yet',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "[ Caution : Only Put Genuine  Leads ]",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                margin: EdgeInsets.only(top: 150),
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final lead = filtered[index];
                    return GestureDetector(
                      onTap: () => _openDetails(lead),
                      child: _LeadCard(
                        lead: lead,
                        isContacted: true,
                        onContactToggle: () {},
                        onReadMore: () => _openDetails(lead),
                      ),
                    );
                  },
                ),
              );
            }),
          );
        }).toList(),
      ),

      // bottom nav (trimmed paddings)
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Colors.white.withOpacity(.94),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: FontAwesomeIcons.house,
                    label: 'Home',
                    selected: _selectedIndex == 0,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedIndex = 0);
                    },
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedIndex = 1);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddTutorAdmin()),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Image(
                          image: AssetImage('assets/icons/profile.jpg'),
                          height: 32,
                          width: 32,
                        ),
                        SizedBox(height: 2),
                        Text("Tutor", style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: FontAwesomeIcons.add,
                    label: 'Add Lead',
                    selected: _selectedIndex == 2,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedIndex = 2);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const create.CreateLeadScreen(),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: FontAwesomeIcons.share,
                    label: 'Promot',
                    selected: _selectedIndex == 3,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedIndex = 3);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PromotAdmin(),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.history,
                    label: 'Report',
                    selected: _selectedIndex == 4,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedIndex = 4);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoryAdmin(),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
    await _refreshLeads();
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
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 36),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24, color: selected ? active : inactive),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.black87 : inactive,
                  ),
                ),
                if (selected)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
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
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.primaryColor),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Lead No: ',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("${lead.id}",
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
                Text(
                  lead.createdAt != null ? _fmtDate(lead.createdAt!) : '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _kv(Icons.person, 'Name', lead.studentName),
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
                LeadMetaRow(
                  icon: Icons.switch_video,
                  label: 'Mode',
                  value: lead.mode,
                  iconColor: AppColors.accentColor,
                  trailing: leadCountPill('0/3'),
                ),
                const SizedBox(height: 6),
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
                TextSpan(
                  text: text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
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

class LeadMetaRow extends StatelessWidget {
  const LeadMetaRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.inlineLinkText,
    this.onInlineLinkTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final String? inlineLinkText;
  final VoidCallback? onInlineLinkTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '$label: ',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
              Text(value, style: const TextStyle(color: AppColors.textColor)),
              if (inlineLinkText != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onInlineLinkTap,
                  child: Text(
                    inlineLinkText!,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

Widget leadCountPill(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF2EA1FF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}
