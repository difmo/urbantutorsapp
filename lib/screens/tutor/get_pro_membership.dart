import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide FormData;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/get_pro_membership_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';

class GetProMembership extends StatefulWidget {
  const GetProMembership({super.key});

  @override
  State<GetProMembership> createState() => _GetProMembershipState();
}

class _GetProMembershipState extends State<GetProMembership> {
  late final CoinsController _c;
  late final ProfileUpdateController _p;
  late final GetProMembershipController _g;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Safe number formatter
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
    _g = Get.isRegistered<GetProMembershipController>()
        ? Get.find<GetProMembershipController>()
        : Get.put(GetProMembershipController());

    // Defer RX-changing work to next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _c.refreshAll();
      _p.fetchProfileForStudent();
      _g.load();
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
            greeting: "Get Pro Membership",
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
        if (_g.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_g.error.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 42),
                  const SizedBox(height: 10),
                  Text(_g.error.value, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _g.load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _g.hasPro.value
                ? _MembershipDetailsCard(details: _g.details, onRefresh: _g.load)
                : _ProUpsell(
                    busy: _g.isPurchasing.value,
                    onBuy: _g.isPurchasing.value ? null : () => _g.buy(subscriptionPlanId: 1),
                  ),
          ),
        );
      }),
    );
  }
}

class _MembershipDetailsCard extends StatelessWidget {
  const _MembershipDetailsCard({required this.details, required this.onRefresh});
  final Map<String, dynamic> details;
  final VoidCallback onRefresh;

  String _s(dynamic v) => (v ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final plan = _s(details['plan_name'] ?? details['subscription_name'] ?? 'Pro Membership');
    final started = _s(details['start_date'] ?? details['created_at'] ?? '');
    final ends = _s(details['end_date'] ?? details['expires_at'] ?? '');
    final status = details['status'];
    final active = (status == 1 || status == '1' || status == true);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Text(plan, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? const Color(0xFF81C784) : const Color(0xFFE57373)),
              ),
              child: Text(active ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: active ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ]),
          const SizedBox(height: 12),
          _row('Start date', started.isEmpty ? '—' : started),
          const SizedBox(height: 6),
          _row('End date', ends.isEmpty ? '—' : ends),
          const SizedBox(height: 6),
          _row('Status code', '$status'),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support: support@urbantutors.pro')),
                  );
                },
                icon: const Icon(Icons.help_outline),
                label: const Text('Support'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text(k, style: const TextStyle(color: Colors.black54))),
        const SizedBox(width: 6),
        Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    );
  }
}

class _ProUpsell extends StatelessWidget {
  const _ProUpsell({required this.onBuy, required this.busy});
  final VoidCallback? onBuy;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Get Pro Membership to unlock:\n• Free chat with students/parents\n• Top listing visibility\n• Visible contact number for one year",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryColor, fontSize: 20),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              width: 340,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: busy
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.workspace_premium),
                label: Text(busy ? 'Processing...' : 'Get Pro Membership Now', style: const TextStyle(fontSize: 18)),
                onPressed: onBuy,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Plan: 1 year (Plan ID: 1)', style: TextStyle(color: Colors.black54)),
          ],
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
                    const SizedBox(width: 6),
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
