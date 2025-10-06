import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';

class ReviewTutor extends StatefulWidget {
  const ReviewTutor({super.key});
  @override
  State<ReviewTutor> createState() => _FeedbackStudentState();
}

class _FeedbackStudentState extends State<ReviewTutor> {
  // Controllers / State
  final _descCtrl = TextEditingController();

  // GetX controllers
  late final CoinsController _c;
  late final ProfileUpdateController _p;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // User meta (for header / drawer behavior)
  String? leadStatus; // "1" => active
  String? userName;
  String? userPhone;
  bool _loadingUserMeta = true;

  // Rating / Media
  int _rating = 0;
  bool _posting = false;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = []; // max 6
  XFile? _video; // optional single short video

  // ---------- lifecycle ----------
  @override
  void initState() {
    super.initState();

    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());

    WidgetsBinding.instance.addPostFrameCallback((_) => _c.refreshAll());

    _p = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());
    _p.fetchProfileForStudent();

    _loadUserMeta();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  // ---------- helpers ----------
  Future<void> _loadUserMeta() async {
    try {
      final s = await StorageService.getUserLeadStatus();
      final n = await StorageService.getUserName();
      final p = await StorageService.getUserPhoneNumber();
      if (!mounted) return;
      setState(() {
        leadStatus = s ?? "0";
        userName = n ?? "";
        userPhone = p ?? "";
        _loadingUserMeta = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        leadStatus = "0";
        userName = "";
        userPhone = "";
        _loadingUserMeta = false;
      });
    }
  }

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  // ---------- UI bits ----------
  Widget _star(int idx) => InkWell(
        onTap: () => setState(() => _rating = idx),
        child: Icon(
          idx <= _rating ? Icons.star : Icons.star_border_rounded,
          color: const Color(0xFFFFC107),
          size: 38,
        ),
      );

  void _showPickMediaSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose photos'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickMultiImage(imageQuality: 85);
                if (picked.isNotEmpty) {
                  setState(() {
                    final remain = 6 - _images.length;
                    _images.addAll(picked.take(remain));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Choose a video'),
              onTap: () async {
                Navigator.pop(context);
                final v = await _picker.pickVideo(
                  source: ImageSource.gallery,
                  maxDuration: const Duration(minutes: 2),
                );
                if (v != null) setState(() => _video = v);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final shot = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                );
                if (shot != null && _images.length < 6) {
                  setState(() => _images.add(shot));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int i) => setState(() => _images.removeAt(i));
  void _removeVideo() => setState(() => _video = null);

  // ---------- submit ----------
  Future<void> _postReview() async {
    if (_rating == 0) {
      Get.snackbar('Missing rating', 'Please rate from 1 to 5 stars',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_descCtrl.text.trim().length < 10) {
      Get.snackbar('Add details', 'Please write at least 10 characters',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _posting = true);
    try {
      final uidStr = await StorageService.getUserId();
      final userId = int.tryParse('$uidStr') ?? 0;

      final map = <String, dynamic>{
        'user_id': userId,
        'rating': _rating,
        'title': '',
        'review': _descCtrl.text.trim(),
      };

      final files = <MultipartFile>[];
      for (final img in _images) {
        files.add(await MultipartFile.fromFile(img.path, filename: img.name));
      }
      if (_video != null) {
        files.add(
            await MultipartFile.fromFile(_video!.path, filename: _video!.name));
      }

      // If your backend expects a different key (e.g., "images[]" & "video"),
      // adjust here. Using media[] is common for multiple uploads.
      if (files.isNotEmpty) map['media[]'] = files;

      // TODO: change endpoint to your real route
      // await ApiService.post(Uri.parse("api/feedback"),map,null);
      Get.snackbar('Thanks!', 'Your review was posted.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      // reset UI
      setState(() {
        _rating = 0;
        _images.clear();
        _video = null;
        _posting = false;
      });
      _descCtrl.clear();
      // Optionally pop: if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _posting = false);
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }

  // ---------- build ----------
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
              name.isEmpty ? 'Tutor' : name.split(RegExp(r'\s+')).first;

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
            initial: (displayName.isEmpty ? 'T' : displayName[0].toUpperCase()),
            greeting: "Write a review",
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ⭐⭐⭐⭐⭐
              Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Text(
                      _rating == 0 ? '0/5' : '$_rating/5',
                      key: ValueKey(_rating),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _rating == 0 ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  ...List.generate(5, (i) => _star(i + 1)),
                  const SizedBox(width: 10),
                ],
              ),

              const SizedBox(height: 16),

              // Big text area like Google review
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1F1F1F)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextFormField(
                  controller: _descCtrl,
                  minLines: 5,
                  maxLines: 10,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText:
                        'Nice work culture and very supportive team members…',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                ),
              ),

              const SizedBox(height: 12),

              // // Add photos & videos tray
              // InkWell(
              //   onTap: _showPickMediaSheet,
              //   borderRadius: BorderRadius.circular(12),
              //   child: Container(
              //     height: 54,
              //     decoration: BoxDecoration(
              //       color: Theme.of(context).brightness == Brightness.dark
              //           ? const Color(0xFF252A34)
              //           : const Color(0xFFEFF2F7),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     padding: const EdgeInsets.symmetric(horizontal: 14),
              //     child: Row(
              //       children: const [
              //         Icon(Icons.add_photo_alternate_outlined),
              //         SizedBox(width: 10),
              //         Text('Add photos & videos',
              //             style: TextStyle(
              //                 fontSize: 15, fontWeight: FontWeight.w600)),
              //       ],
              //     ),
              //   ),
              // ),

              // // Thumbnails
              if (_images.isNotEmpty || _video != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (int i = 0; i < _images.length; i++)
                      _Thumb(
                          path: _images[i].path,
                          onRemove: () => _removeImage(i)),
                    if (_video != null)
                      _VideoThumb(path: _video!.path, onRemove: _removeVideo),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Cancel / Post
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _posting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _posting ? null : _postReview,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _posting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Post'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Header ----------------
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

// ---------------- Thumbnails ----------------
class _Thumb extends StatelessWidget {
  const _Thumb({required this.path, required this.onRemove});
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(path),
            width: 90,
            height: 90,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.6),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoThumb extends StatelessWidget {
  const _VideoThumb({required this.path, required this.onRemove});
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black12,
            border: Border.all(color: Colors.black12),
          ),
          child: const Center(
            child: Icon(Icons.play_circle_filled, size: 38),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.6),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
