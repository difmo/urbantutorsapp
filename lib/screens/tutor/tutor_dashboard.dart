import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';
import 'package:urbantutorsapp/models/tutor_lead.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_response_modal.dart';

import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/DashboardHomeTab.dart';
import 'package:urbantutorsapp/screens/tutor/notes_tutor.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_chat_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_courses_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_pyq_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_support_screen.dart';

import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/CustomTeacherNavBar.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  // Controllers
  final TutorLeadsController _leads = Get.put(TutorLeadsController());

  late final CoinsController _coins;
  late final ProfileUpdateController _p;
  String _storedUserName = '';

  // Bottom nav
  int _currentIndex = 0;
  final List<Widget> _screens = [
    DashboardHomeTab(),
    NotesTutor(),
    TutorPyqScreen(),
    TutorCoursesScreen(),
    TutorChatScreen(),
    SupportTutor(),
  ];

  @override
  void initState() {
    super.initState();

    _loadUserName();

    _coins = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());
    _coins.refreshAll();

    _p = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());
    _p.fetchProfileForTutor();

    ever(_p.tutorprofileData, (prof) {
      if (prof == null) return;
      final serverName = prof.teacherName?.trim() ?? '';
      if (serverName.isNotEmpty) {
        StorageService.saveUserName(serverName);
        if (mounted && _storedUserName != serverName) {
          setState(() => _storedUserName = serverName);
        }
      }
    });
  }

  Future<void> _loadUserName() async {
    try {
      final name = await StorageService.getUserName();
      if (name != null &&
          name.trim().isNotEmpty &&
          name.trim().toLowerCase() != 'user' &&
          name.trim().toLowerCase() != 'urban user' &&
          name.trim().toLowerCase() != 'tutor') {
        if (mounted) setState(() => _storedUserName = name.trim());
        final prof = _p.tutorprofileData.value;
        if (prof != null) {
          final tName = prof.teacherName?.trim() ?? '';
          if (tName.isEmpty || tName.toLowerCase() == 'user' || tName.toLowerCase() == 'tutor') {
            final json = prof.toJson();
            json['teacher_name'] = name.trim();
            _p.tutorprofileData.value = TutorProfileData.fromJson(json);
          }
        }
        return;
      }
    } catch (_) {}
  }

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  String _initial(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'T';
    return n.characters.first.toUpperCase();
  }

  String _firstName(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'Tutor';
    final parts = n.split(RegExp(r'\s+'));
    return parts.first;
  }

  String _greet() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
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
      endDrawer: Tutordrawer(), // <- ensure class name
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

          final prof = _p.tutorprofileData.value;
          final profilePicture = prof?.profilePicture?.trim();
          final serverName = prof?.teacherName?.trim() ?? '';
          final cached = StorageService.cachedUserName?.trim() ?? '';

          String rawName = '';
          if (serverName.isNotEmpty) {
            rawName = serverName;
          } else if (_storedUserName.isNotEmpty) {
            rawName = _storedUserName;
          } else if (cached.isNotEmpty) {
            rawName = cached;
          } else {
            rawName = 'User';
          }

          final initial = _initial(rawName);
          final displayName = _firstName(rawName);
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
                child: profilePicture != null && profilePicture.isNotEmpty
                    ? ClipOval(
                        child: FadeInImage.assetNetwork(
                          placeholder:'assets/icons/logogog.jpeg',
                          image: 'https://urbantutors.pro/$profilePicture',
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                        ),
                      )
                    : CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
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
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(width: 2, color: AppColors.primaryColor),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 6),
                        Text(
                          balanceStr == "0" ? "Upgrade" : "Coins: $balanceStr",
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

      body: _screens[_currentIndex],

      bottomNavigationBar: CustomTeacherNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
