import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/pay_course_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class TutorCoursesScreen extends StatefulWidget {
  const TutorCoursesScreen({super.key});

  @override
  State<TutorCoursesScreen> createState() => _TutorCoursesScreenState();
}

class _TutorCoursesScreenState extends State<TutorCoursesScreen> {
  late final CoinsController _c;
  late final ProfileUpdateController _p;
  late final PayCourseController _pay;

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

    _pay = Get.isRegistered<PayCourseController>()
        ? Get.find<PayCourseController>()
        : Get.put(PayCourseController());

    // Defer Rx actions to next frame (avoid setState during build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _c.refreshAll();
      _p.fetchProfileForStudent();
      _pay.load(); // already called in onInit, but safe here too
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      key: _scaffoldKey,
     
      body: Obx(() {
        if (_pay.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_pay.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 32),
                const SizedBox(height: 8),
                Text(_pay.error.value, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _pay.load,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (_pay.courses.isEmpty) {
          return const Center(child: Text('No courses available'));
        }

        return RefreshIndicator(
          onRefresh: _pay.refreshNow,
          child: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: _pay.courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = _pay.courses[i];
                final buying = _pay.purchasingCourseId.value == item.id;
                final opening = _pay.openingCourseId.value == item.id;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    border: Border.all(width: 1, color: AppColors.primaryColor),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + rating + coins
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.courseName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF222B45),
                                ),
                              ),
                            ),
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF222B45),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _CoinsChip(coins: item.coins),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6E7A8A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            // PREVIEW
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A90E2),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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
                                    : const Icon(Icons.picture_as_pdf),
                                label: Text(opening ? 'Opening...' : 'Preview'),
                                onPressed: opening
                                    ? null
                                    : () async {
                                        final url = await _pay.getPreviewUrl(item);
                                        if (url == null) return;
                                        await _pay.launchUrlExternal(url);
                                      },
                              ),
                            ),
                            const SizedBox(width: 10),

                            // BUY NOW
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF27AE60),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: buying
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.shopping_cart_checkout),
                                label: Text(buying ? 'Processing...' : 'Buy now'),
                                onPressed: buying ? null : () => _pay.buy(item),
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
          ),
        );
      }),
    );
  }
}

class _CoinsChip extends StatelessWidget {
  const _CoinsChip({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    final isFree = coins <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isFree ? const Color(0xFFE8F5E9) : const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFree ? const Color(0xFFB2DFDB) : const Color(0xFFFFE0B2),
        ),
      ),
      child: Text(
        isFree ? 'Free' : '$coins coins',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isFree ? const Color(0xFF065F46) : const Color(0xFF92400E),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
