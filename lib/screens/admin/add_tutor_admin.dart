import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/coins_student.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/AdminDrawer.dart';

class AddTutorAdmin extends StatefulWidget {
  const AddTutorAdmin({super.key});

  @override
  State<AddTutorAdmin> createState() => _TransactionAdmin();
}

class _TransactionAdmin extends State<AddTutorAdmin> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback submitted")),
    );
    _titleCtrl.clear();
    _descCtrl.clear();
  }

  // Controllers
  final ProfileUpdateController _p = Get.isRegistered<ProfileUpdateController>()
      ? Get.find<ProfileUpdateController>()
      : Get.put(ProfileUpdateController());

  final MasterDataController _master = Get.isRegistered<MasterDataController>()
      ? Get.find<MasterDataController>()
      : Get.put(MasterDataController());

  final LeadMetaController _leadMeta = Get.isRegistered<LeadMetaController>()
      ? Get.find<LeadMetaController>()
      : Get.put(LeadMetaController());

  final LocationController _loc = Get.isRegistered<LocationController>()
      ? Get.find<LocationController>()
      : Get.put(LocationController());

  late final CoinsController _c;

  InputDecoration _dec({
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      counterText: '',
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
    );
  }

  // Misc
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());
    WidgetsBinding.instance.addPostFrameCallback((_) => _c.refreshAll());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_master.masterData.value == null) {
        await _master.fetchMasterData();
      }
      if (_p.studentprofileData.value == null && !_p.isLoading.value) {
        await _p.fetchProfileForStudent();
      }
    });
  }

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  void handleTap(String label, {VoidCallback? onTap}) {
    // setState(() => selectedLabel = label);
    Navigator.pop(context); // close drawer first
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      backgroundColor: Colors.white,
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
          final name =
              prof?.studentName?.trim() ?? prof?.studentName?.trim() ?? '';
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
            greeting: "Add Tutor",
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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Image(
                image: AssetImage('assets/icons/download.png'),
                height: 176,
                width: 176,
              ),
              Text(
                "Kindly, Share this Link with your Tutors. So they can join this Group.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 32,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                child: _drawerItem(
                  Icons.share,
                  'Share Your Link',
                  onTap: _shareApp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _drawerItem(
  IconData icon,
  String label, {
  Color? color,
  VoidCallback? onTap,
}) {
  return Center(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primaryColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: color ?? Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Icon(icon, color: color ?? Colors.white),
            ],
          )),
    ),
  );
}

void _shareApp() {
  const playStoreLink =
      'https://play.google.com/store/apps/details?id=pro.urbantutors.app&pcampaignid=web_share';
  Share.share('Check out Urban Tutors App: $playStoreLink');
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
                    border:
                        Border.all(width: 1, color: AppColors.primaryColor)),
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    Text(
                      "$balance coins",
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

// -------------------- Multi-select Helpers (kept for future use) --------------------
