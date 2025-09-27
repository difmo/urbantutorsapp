import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/lead_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/models/lead__model.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/coins_student.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/AdminDrawer.dart';

class PromotAdmin extends StatefulWidget {
  const PromotAdmin({Key? key}) : super(key: key);

  @override
  State<PromotAdmin> createState() => _PromotAdminState();
}

class _PromotAdminState extends State<PromotAdmin> {
  final LeadController leadController = Get.put(LeadController());

  /// 🔹 Facebook Share
  void _shareToFacebook(StudentLead lead) {
    final url =
        "https://www.facebook.com/sharer/sharer.php?u=https://urbantutorsapp.com/lead/${lead.id}";
    Share.share(url, subject: "Check this Lead on Facebook!");
  }

  /// 🔹 Instagram Share
  void _shareToInstagram(StudentLead lead) {
    final text = "📢 New Lead Available!\n\nLead No: ${lead.id}\n\n"
        "👉 Download the app: https://play.google.com/store/apps/details?id=pro.urbantutors.app";
    Share.share(text, subject: "Check this Lead on Instagram!");
  }

  /// 🔹 WhatsApp Share
  void _shareToWhatsApp(StudentLead lead) {
    final text = "📢 New Lead Available!\n\nLead No: ${lead.id}\n\n"
        "👉 Download the app: https://play.google.com/store/apps/details?id=pro.urbantutors.app";
    final url = "https://wa.me/?text=${Uri.encodeComponent(text)}";
    Share.share(url, subject: "Share Lead on WhatsApp");
  }

  @override
  void initState() {
    super.initState();
    leadController.fetchLeads(); // ✅ fetch only once
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
  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;
    leadController.fetchLeads();
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
            greeting: "Promote",
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
        child: Obx(() {
          if (leadController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final leads = leadController.studentLeads;
          if (leads.isEmpty) {
            return const Center(
              child: Text(
                "No Leads Available",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }
        
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leads.length,
            itemBuilder: (context, index) {
              final lead = leads[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.primaryColor, width: 1),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Lead No: ${lead.id}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.facebook,
                              color: Colors.blue,
                            ),
                            tooltip: "Facebook",
                            onPressed: () => _shareToFacebook(lead),
                          ),
                          IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.instagram,
                              color: Colors.purple,
                            ),
                            tooltip: "Instagram",
                            onPressed: () => _shareToInstagram(lead),
                          ),
                          IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.green,
                            ),
                            tooltip: "WhatsApp",
                            onPressed: () => _shareToWhatsApp(lead),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
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
