import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    UpgradeScreen(),
    HistoryScreen(),
    SupportScreen(),
  ];

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
        toolbarHeight: 72,
        titleSpacing: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          // status bar icons visible
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        // 🔹 Gradient only inside the AppBar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: _Header(
          primary: primary,
          accent: accent,
          onCoinTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => CoinsStudent()));
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
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
          child: Stack(
            children: [
              _CurvedGradient(primary: primary, accent: accent),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _QuickStatsRow(primary: primary, accent: accent),
                    const SizedBox(height: 16),
                    _SectionHeader(title: 'Your tools'),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      children: [
                        _FeatureCard(
                          label: 'Notes',
                          icon: Icons.note_alt_outlined,
                          gradient: LinearGradient(colors: [
                            primary.withOpacity(.15),
                            primary.withOpacity(.05)
                          ]),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        NotesScreen(flags: "Note")));
                          },
                        ),
                        _FeatureCard(
                          label: 'PYQ’s',
                          icon: Icons.assignment_turned_in_outlined,
                          gradient: LinearGradient(colors: [
                            accent.withOpacity(.15),
                            accent.withOpacity(.05)
                          ]),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => NotesScreen(flags: "pyq")));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _SectionHeader(title: 'Continue learning'),
                    const SizedBox(height: 12),
                    _BigActionCard(
                      label: 'Courses (PDF)',
                      subtitle: 'Hand-picked PDF content',
                      icon: Icons.picture_as_pdf,
                      gradient: LinearGradient(
                        colors: [accent.withOpacity(.18), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PDFCoursesScreen()));
                      },
                    ),
                    const SizedBox(height: 14),
                    _BigActionCard(
                      label: 'Search Private Tutor Now',
                      subtitle: 'Find expert tutors near you',
                      icon: Icons.search_rounded,
                      gradient: LinearGradient(
                        colors: [primary.withOpacity(.18), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SearchTutorScreen()));
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ---------- Header pieces

class _Header extends StatelessWidget {
  const _Header(
      {required this.primary, required this.accent, required this.onCoinTap});
  final Color primary;
  final Color accent;
  final VoidCallback onCoinTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Gradient ring avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                colors: [primary, accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          padding: const EdgeInsets.all(2),
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Text('S',
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: Colors.black87)),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text('Welcome, Student',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
        ),
        // Coins chip (glass)
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
                  border: Border.all(color: Colors.white.withOpacity(.25)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.monetization_on, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text('200 coins',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
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

class _CurvedGradient extends StatelessWidget {
  const _CurvedGradient({required this.primary, required this.accent});
  final Color primary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BottomCurveClipper(),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path()..lineTo(0, size.height - 50);
    p.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height - 50);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// ---------- Sections & cards

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87));
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.primary, required this.accent});
  final Color primary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 25,
        ),
        _StatChip(
            icon: Icons.chat_bubble_outline,
            label: 'Messages',
            value: '3',
            tint: primary),
        const SizedBox(width: 10),
        _StatChip(
            icon: Icons.verified_user_outlined,
            label: 'Plan',
            value: 'Basic',
            tint: accent),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.tint});
  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6))
          ],
          border: Border.all(color: Colors.black12.withOpacity(.05)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [tint.withOpacity(.15), tint.withOpacity(.05)]),
              ),
              child: Icon(icon, size: 18, color: tint),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black54)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _InkCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient,
          boxShadow: const [
            BoxShadow(
                color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 6))
          ],
          border: Border.all(color: Colors.black12.withOpacity(.04)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
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
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _InkCard(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient,
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 8))
          ],
          border: Border.all(color: Colors.black12.withOpacity(.05)),
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
              child: Icon(icon, size: 26, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.black45),
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
          borderRadius: BorderRadius.circular(16), onTap: onTap, child: child),
    );
  }
}
