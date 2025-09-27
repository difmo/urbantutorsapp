import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _NotificationStudentState();
}

class _NotificationStudentState extends State<AdminSupportScreen> {
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

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return SafeArea(
      child: Scaffold(
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
            final loadingCoins =
                _c.loadingCoins.value || _c.loadingMyCoins.value;
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
              initial:
                  (displayName.isEmpty ? 'S' : displayName[0].toUpperCase()),
              greeting: "Get Support",
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
        body: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Need Assistance, We're here to help !",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                " Connect us through  below options below ...",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _contactOption(
                      icon: Icons.chat,
                      title: "Live Chat",
                      subtitle: "Get instant support",
                      onTap: () {
                        // TODO: open your in-app chat screen
                      },
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _contactOption(
                      icon: Icons.email_outlined,
                      title: "Email Us",
                      subtitle: "support@urbantutors.pro",
                      onTap: () => {
                        // launchUrl(Uri.parse('mailto:support@urbantutors.com')),
                      },
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              // _contactOption(
              //   icon: Icons.phone,
              //   title: "Call Us",
              //   subtitle: "+91 95826 99555",
              //   onTap: () {},
              //   color: Colors.green,
              // ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              // FAQ Section
              const Text(
                "Frequently Asked Questions...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _faqItem("How can I upgrade my plan?"),
              _faqItem("Where can I access my course notes?"),
              _faqItem("How do I connect with a private tutor?"),
              _faqItem("What payment methods are accepted?"),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              // Submit a Query
              const Text(
                "Submit Your Queries here...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Type your issue or question here...",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Submit", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            gradient: LinearGradient(
              colors: [AppColors.accentColor.withOpacity(.18), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(width: 1, color: AppColors.primaryColor)),
        padding: const EdgeInsets.all(2),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12)),
              Text(subtitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12)),
              SizedBox(
                height: 8,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _faqItem(String question) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.help_outline, color: Colors.blueGrey),
      title: Text(question),
      onTap: () {},
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.primary,
    required this.accent,
    required this.onCoinTap,
    required this.balance,
    required this.initial, // ⬅️ NEW
    required this.greeting, // ⬅️ NEW
    required this.name, // ⬅️ NEW
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
        // Avatar with gradient ring

        const SizedBox(width: 12),

        // Greeting + name (ellipsized)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Get Support",
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

        // Coins chip
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
