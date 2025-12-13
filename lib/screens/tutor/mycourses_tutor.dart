import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/controllers/my_course_controller.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';

class MycoursesTutor extends StatefulWidget {
  const MycoursesTutor({super.key});

  @override
  State<MycoursesTutor> createState() => _CourseTutorState();
}

class _CourseTutorState extends State<MycoursesTutor> {
  late final CoinsController _c;
  late final ProfileUpdateController _p;
  late final MyCourseController _mc;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());

    _p = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());

    _mc = Get.isRegistered<MyCourseController>()
        ? Get.find<MyCourseController>()
        : Get.put(MyCourseController());

    // Defer to next frame to avoid rebuild conflicts from Obx
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _c.refreshAll();
      _p.fetchProfileForStudent();
      _mc.load(); // onInit already does this, but safe if you want a manual refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawer: Tutordrawer(onMenuTap: (label) async {
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
          final loadingCoins = _c.loadingCoins.value || _c.loadingMyCoins.value;
          final wallet = _c.myCoins.value;
          final balanceNum = _toNum(wallet?.available);
          final balanceText = balanceNum.toStringAsFixed(0);

          final prof = _p.studentprofileData.value;
          final name = prof?.studentName?.trim() ?? '';
          final displayName =
              name.isEmpty ? 'Student' : name.split(RegExp(r'\s+')).first;

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
            initial: (displayName.isEmpty ? 'S' : displayName[0].toUpperCase()),
            greeting: "My Courses",
            name: displayName,
            balance: balanceText,
            onCoinTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TutorCoinsScreen()),
              );
            },
          );
        }),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 45),
              onPressed: () => Scaffold.maybeOf(ctx)?.openEndDrawer(),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (_mc.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_mc.error.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 42),
                  const SizedBox(height: 10),
                  Text(_mc.error.value, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _mc.load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  )
                ],
              ),
            ),
          );
        }
        if (_mc.courses.isEmpty) {
          return RefreshIndicator(
            onRefresh: _mc.refreshNow,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                // SizedBox(height: 120),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.menu_book_outlined,
                          size: 64, color: Colors.black26),
                      SizedBox(height: 10),
                      Text('No Any course Purchsed yet',
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _mc.refreshNow,
          child: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              itemCount: _mc.courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final item = _mc.courses[i];
                final opening = _mc.openingCourseId.value == item.courseId;

                final img = _mc.buildImageUrl(item.image!);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: img.isEmpty
                              ? Container(
                                  width: 84,
                                  height: 84,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported),
                                )
                              : Image.network(
                                  img,
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 84,
                                    height: 84,
                                    color: Colors.grey.shade200,
                                    child:
                                        const Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),

                        // Texts
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // title + rating
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.courseName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF222B45),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF222B45),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF6E7A8A),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Actions
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      icon: opening
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.open_in_new),
                                      label:
                                          Text(opening ? 'Opening...' : 'Open'),
                                      onPressed: opening
                                          ? null
                                          : () => _mc.openCourse(item),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _StatusChip(status: item.status),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final int status; // 0|1 maybe (backend field)

  @override
  Widget build(BuildContext context) {
    final active = status == 1 || status == 200;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE8F5E9) : const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? const Color(0xFFB2DFDB) : const Color(0xFFFFE0B2),
        ),
      ),
      child: Text(
        active ? 'Active' : 'Pending',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: active ? const Color(0xFF065F46) : const Color(0xFF92400E),
          fontSize: 12,
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
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
                  border: Border.all(width: 1, color: AppColors.primaryColor),
                ),
                child: Row(
                  children: [
                    Text(
                      balance == "0" ? "Upgrade" : "$balance coins",
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
