import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/ChatUserListScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/HistoryScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/HomeScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/SupportScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/UpgradeScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/coins_student.dart';
import 'package:urbantutorsapp/screens/student/notes_screen.dart';
import 'package:urbantutorsapp/screens/student/pdf_courses_screen.dart';
import 'package:urbantutorsapp/screens/student/search_tutor_screen.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/CustomStudentNavBar.dart';
import 'package:urbantutorsapp/widgets/StudentDrawer.dart';
import '../../theme/theme_constants.dart';

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
    Upgradescreen(),
    HistoryScreen(),
    SupportScreen(),
  ];

  late final CoinsController _c;
  late final ProfileUpdateController _p; // ⬅️ NEW

  @override
  void initState() {
    super.initState();
    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());
    _c.refreshAll();

    _p = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());
    // Try to ensure profile is present
    _p.fetchProfileForStudent();
  }

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

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawer: StudentDrawer(onMenuTap: (label) async {
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 76,
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
          // coins
          final loadingCoins = _c.loadingCoins.value || _c.loadingMyCoins.value;
          final wallet = _c.myCoins.value;
          final balanceNum = _toNum(wallet?.available);
          final balanceText = balanceNum.toStringAsFixed(0);

          // profile
          final prof = _p.studentprofileData.value;
          final name = prof?.studentName?.trim();
          final initial = _initial(name);
          final greet = _greet();
          final displayName = _firstName(name);

          if (loadingCoins && wallet == null && prof == null) {
            return const SizedBox(
              height: 24,
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          return _Header(
            primary: primary,
            accent: accent,
            initial: initial,
            greeting: "Welcome",
            name: displayName,
            balance: balanceText,
            onCoinTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoinsStudentScreen()),
              );
            },
          );
        }),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 45,
              ),
              onPressed: () => Scaffold.maybeOf(ctx)?.openEndDrawer(),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildPremiumBody(primary, accent),
          _screens[1],
          _screens[2],
          _screens[3],
          _screens[4],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
          ],
        ),
        child: CustomStudentNavBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }

  Widget _buildPremiumBody(Color primary, Color accent) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1, // <-- makes the cards shorter
                  children: [
                    _FeatureCard(
                      label: 'Notes',
                      height: 90, // reduced height
                      icon: Icons.note_alt_outlined,
                      gradient: LinearGradient(
                        colors: [accent.withOpacity(.18), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotesScreen(flags: "Note")),
                        );
                      },
                    ),
                    _FeatureCard(
                      label: 'PYQ’s',
                      height: 90, // reduced height
                      icon: Icons.assignment_turned_in_outlined,
                      gradient: LinearGradient(
                        colors: [accent.withOpacity(.18), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotesScreen(flags: "pyq")),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _BigActionCard(
                  label: 'Courses (PDF).',
                  subtitle:
                      'Kindly Purchase the most Valuable and Popular PDF Courses.',
                  icon: Icon(Icons.picture_as_pdf),
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(.18), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PDFCoursesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _BigActionCard(
                  label: 'Search a Private Tutor Now.',
                  subtitle:
                      'Find  Expert Private Tutor (Online/Offline) for any Subject withhin few Minutes.',
                  icon: Icon(Icons.search_rounded),
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(.18), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SearchTutorScreen()),
                    );
                  },
                ),
                const SizedBox(height: 8),
//  Icons.search_rounded
                _BigActionCard(
                  label: 'Get Addmision Assistance.',
                  subtitle:
                      'Get Support & Guidance at Each and Every Steps of your Life and Career.',
                  icon: Container(
                    child: Image(
                      image: AssetImage('assets/icons/logogog.jpeg'),
                      height: 176,
                      width: 176,
                    ),
                  ),
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(.18), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (_) => const SearchTutorScreen()),
                    // );
                  },
                ),
                const SizedBox(height: 8),
                _BigActionCard(
                  label: 'Chess:The Brain Booster Wager.',
                  subtitle: 'The Gymnasium of the Genius Brain.',
                  icon: Container(
                    child: Image(
                      image: AssetImage('assets/icons/chess.png'),
                      height: 176,
                      width: 176,
                    ),
                  ),
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(.18), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Coming Soon!"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.primary,
    required this.accent,
    required this.onCoinTap,
    required this.balance,
    required this.initial,
    required this.greeting,
    required this.name,
  });

  final Color primary;
  final Color accent;
  final VoidCallback onCoinTap;
  final String balance;

  final String initial;
  final String greeting;
  final String name;
  String _capFirst(String s) {
    final t = s.trim();
    if (t.isEmpty) return '';
    return t[0].toUpperCase() + t.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 8,
        ),
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primary, accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(width: 1, color: AppColors.primaryColor)),
          padding: const EdgeInsets.all(2),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Text(
              initial,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  )),
              const SizedBox(height: 2),
              Text(
                _capFirst(name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onCoinTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(22),
                    border:
                        Border.all(width: 1, color: AppColors.primaryColor)),
                child: Row(
                  children: [
                    // const Icon(Icons.monetization_on,
                    //     size: 16, color: Colors.white),
                    const SizedBox(width: 6),

                    Text(
                      '${balance == "0" ? "Upgrade" : "$balance coins"} ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.height = 120, // default height
  });
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _InkCard(
      onTap: onTap,
      child: Container(
        height: height, // use height here
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient,
          boxShadow: const [
            BoxShadow(
                color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 6))
          ],
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: AppColors.primaryColor),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor)),
          ],
        ),
      ),
    );
  }
}

class _BigActionCard extends StatelessWidget {
  const _BigActionCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final Widget icon;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _InkCard(
      onTap: onTap,
      child: Container(
        height: 100,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient,
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 8))
          ],
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(.06),
                    Colors.white.withOpacity(.5)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: icon,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: label == "Search a Private Tutor Now."
                              ? Colors.red
                              : AppColors.primaryColor)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }
}

class _InkCard extends StatelessWidget {
  const _InkCard({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: child,
      ),
    );
  }
}
