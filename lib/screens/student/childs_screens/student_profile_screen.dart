// student_profile_screen.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/pay_course_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/coins_student.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/StudentDrawer.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  // Controllers (late because we init in initState)
  late final ProfileUpdateController _p;
  final MasterDataController _master = Get.isRegistered<MasterDataController>()
      ? Get.find<MasterDataController>()
      : Get.put(MasterDataController());

  final LeadMetaController _leadMeta = Get.isRegistered<LeadMetaController>()
      ? Get.find<LeadMetaController>()
      : Get.put(LeadMetaController());

  final LocationController _loc = Get.isRegistered<LocationController>()
      ? Get.find<LocationController>()
      : Get.put(LocationController());

  // Form state
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // Text controllers
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();

  // selects
  int? _boardId;
  int? _classId;

  String? selectedBoardName = "Board";
  String? selectedClassName = 'Class';
  late final CoinsController _c;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  String? _profileImageUrl; // from server

  String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    // TODO: replace with your API base:
    const base = 'https://urbantutors.pro/'; // <-- update this
    return '$base$path';
  }

  @override
  void initState() {
    super.initState();

    // CoinsController
    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());
    WidgetsBinding.instance.addPostFrameCallback((_) => _c.refreshAll());

    // ProfileUpdateController (do NOT fetch twice)
    _p = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());

    // Fetch master data and profile then hydrate (single fetch)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (_master.masterData.value == null) {
          await _master.fetchMasterData();
        }
        if (!_p.isLoading.value) {
          // single fetch after frame
          await _p.fetchProfileForStudent();
        }
        await _hydrate();
      } catch (e, st) {
        debugPrint('init hydrate error: $e\n$st');
      }
    });

    // Re-hydrate whenever the profile RX changes
    ever(_p.studentprofileData, (_) async {
      try {
        await _hydrate();
      } catch (e) {
        debugPrint('ever hydrate error: $e');
      }
    });
  }

  Future<void> _hydrate() async {
    final p = _p.studentprofileData.value;
    if (p == null) {
      // clear fields if no profile
      if (mounted) {
        _nameCtrl.text = '';
        _mobileCtrl.text = '';
        _localityCtrl.text = '';
        _profileImageUrl = null;
        setState(() {
          _boardId = null;
          _classId = null;
        });
      }
      return;
    }

    // populate fields
    _nameCtrl.text = (p.studentName ?? '').trim();
    _mobileCtrl.text = (p.mobile ?? '').trim();
    _localityCtrl.text = p.location ?? '';
    // Image from server
    _profileImageUrl = _resolveImageUrl(p.profile_picture);

    // Safe parsing of dynamic IDs (could be string or int)
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    selectedBoardName = p.boardName;
    selectedClassName = p.courseName;

    // Load classes for the board first, then set class i

    if (!mounted) return;
    setState(() {
      _boardId = p.boardId;
      _classId = p.courseId;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _localityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        if (!mounted) return;
        setState(() => _profileImage = picked);
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Remove"),
                onTap: () {
                  if (mounted) {
                    setState(() => _profileImage = null);
                    Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<String?> _fileToBase64(XFile? file) async {
    if (file == null) return null;
    try {
      final bytes = await File(file.path).readAsBytes();
      final ext = file.path.split('.').last.toLowerCase();
      return "data:image/$ext;base64,${base64Encode(bytes)}";
    } catch (e) {
      debugPrint('fileToBase64 error: $e');
      return null;
    }
  }

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  final PayCourseController _payCourseController =
      Get.find<PayCourseController>();

  static const blue = Color(0xFF4A90E2);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final int _currentIndex = 0;

  ImageProvider? _avatarProvider() {
    if (_profileImage != null) return FileImage(File(_profileImage!.path));
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }
    return null;
  }

  String _initialFromName(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'U';
    return n.characters.first.toUpperCase();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_boardId == null || _classId == null) {
      if (mounted) {
        Get.snackbar('Missing info', 'Please select Board and Class',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
      return;
    }

    if (!mounted) return;
    setState(() => _saving = true);

    try {
      final uidStr = await StorageService.getUserId();
      final userId = int.tryParse('$uidStr') ?? 0;
      if (userId <= 0) {
        if (mounted) {
          Get.snackbar('Error', 'No user id found',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white);
        }
        return;
      }

      // Get location if possible
      String placeId = 'unknown';
      String latitude = '0';
      String longitude = '0';
      try {
        await _loc.getCurrentLocation();
        if (_loc.latitude.value != 0.0 || _loc.longitude.value != 0.0) {
          latitude = _loc.latitude.value.toString();
          longitude = _loc.longitude.value.toString();
        }
        if (_loc.placeId.value.isNotEmpty) {
          placeId = _loc.placeId.value;
        } else if (_localityCtrl.text.trim().isNotEmpty) {
          placeId = _localityCtrl.text.trim();
        }
      } catch (e) {
        debugPrint('getCurrentLocation failed: $e');
        if (_localityCtrl.text.trim().isNotEmpty) {
          placeId = _localityCtrl.text.trim();
        }
      }

      final profileBase64 = await _fileToBase64(_profileImage);

      final req = {
        'user_id': userId,
        'student_name': _nameCtrl.text.trim(),
        'board_id': _boardId,
        'course_id': _classId,
        'price': 800,
        'location': _localityCtrl.text.trim(),
        'state': 'Delhi', // TODO: derive from reverse geocode if required
        'remark': '',
        'profile_picture': profileBase64 ?? '',
        'place_id': placeId,
        'latitude': latitude,
        'longitude': longitude,
      };

      final ok = await _p.updateStudentProfile(req);
      if (ok == true) {
        if (mounted) {
          Get.snackbar('Success', 'Student Profile Updated Successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);
        }

        // re-fetch and re-hydrate
        await _p.fetchProfileForStudent();
        await _hydrate();

        if (mounted) setState(() => _profileImage = null);
      } else {
        if (mounted) {
          Get.snackbar('Error', 'Failed to update profile',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white);
        }
      }
    } catch (e, st) {
      debugPrint('Failed saving profile: $e\n$st');
      if (mounted) {
        Get.snackbar('Error', 'Failed to save: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String label,
      {IconData? icon, Widget? suffixIcon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
          icon != null ? Icon(icon, color: AppColors.primaryColor) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade100,
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
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      backgroundColor: Colors.white,
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
          final loadingCoins = _c.loadingCoins.value || _c.loadingMyCoins.value;
          final wallet = _c.myCoins.value;
          final balanceNum = _toNum(wallet?.available);
          final balanceText = balanceNum.toStringAsFixed(0);

          final prof = _p.studentprofileData.value;
          final name = prof?.studentName?.trim();
          final initial = _initialFromName(name);
          final displayName = (name == null || name.isEmpty)
              ? 'Student'
              : name.split(' ').first;

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
            greeting: "Edit Profile",
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
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check),
            label: const Text('Save Changes'),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (_p.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final prof = _p.studentprofileData.value;
          final noProfileBanner = prof == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'No profile found — please fill the details and save.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                )
              : const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prof == null) noProfileBanner,
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.primaryColor, width: 1),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 44,
                            backgroundImage: _avatarProvider(),
                            backgroundColor: Colors.grey.shade300,
                            child: _avatarProvider() == null
                                ? Text(
                                    _initialFromName(prof?.studentName),
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _showPickerOptions,
                            child: const CircleAvatar(
                              radius: 16,
                              child: Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Basic
                  _sectionCard(
                    title: 'Basic:',
                    children: [
                      _textField('Full Name', _nameCtrl,
                          icon: Icons.person, hint: 'Your name'),
                      _textField('Mobile', _mobileCtrl,
                          icon: Icons.phone,
                          hint: 'Your phone',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ]),
                    ],
                  ),

                  // Academics
                  _sectionCard(
                    title: 'Academics:',
                    children: [
                      // Board
                      Obx(() {
                        final boards =
                            _master.masterData.value?.data.boardLead ?? [];
                        return DropdownButtonFormField<int>(
                          value: _boardId,
                          isExpanded: true,
                          decoration:
                              _dec(selectedBoardName!, icon: Icons.school),
                          items: boards
                              .map((b) => DropdownMenuItem<int>(
                                    value: b.boardId,
                                    child: Text(b.boardLabel ?? ''),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _boardId = val;
                              _classId = null;
                            });
                            if (val != null) _leadMeta.loadClasses(val);
                          },
                          validator: (v) =>
                              v == null ? 'Please select board' : null,
                        );
                      }),
                      const SizedBox(height: 12),

                      // Class
                      Obx(() {
                        final classes = _leadMeta.classes;
                        final busy = _leadMeta.isFetchingClasses.value;
                        return DropdownButtonFormField<int>(
                          value: _classId,
                          isExpanded: true,
                          decoration: _dec(selectedClassName!,
                              icon: Icons.menu_book,
                              suffixIcon: busy
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    )
                                  : null),
                          items: classes
                              .map((c) => DropdownMenuItem<int>(
                                    value: c.classId,
                                    child: Text(c.className),
                                  ))
                              .toList(),
                          onChanged: (_boardId == null)
                              ? null
                              : (val) => setState(() => _classId = val),
                          validator: (v) =>
                              v == null ? 'Please select class' : null,
                        );
                      }),
                    ],
                  ),

                  // Location
                  _sectionCard(
                    title: 'Location:',
                    children: [
                      Obx(() {
                        final searching = _loc.isSearching.value;
                        final opts = _loc.suggestions;
                        return Autocomplete<String>(
                          optionsBuilder: (TextEditingValue tev) {
                            final q = tev.text.trim();
                            if (q.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            return opts;
                          },
                          onSelected: (val) {
                            _localityCtrl.text = val;
                            _loc.onQueryChanged('');
                          },
                          fieldViewBuilder:
                              (context, textCtrl, focusNode, onFieldSubmitted) {
                            if (textCtrl.text != _localityCtrl.text) {
                              textCtrl.text = _localityCtrl.text;
                              textCtrl.selection = TextSelection.fromPosition(
                                TextPosition(offset: textCtrl.text.length),
                              );
                            }
                            textCtrl.addListener(() {
                              final q = textCtrl.text;
                              if (_localityCtrl.text != q) {
                                _localityCtrl.text = q;
                                _loc.onQueryChanged(q);
                              }
                            });

                            return TextFormField(
                              controller: textCtrl,
                              focusNode: focusNode,
                              decoration: _dec(
                                'Locality',
                                icon: Icons.location_on_outlined,
                                suffixIcon: searching
                                    ? const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter locality'
                                  : null,
                              onFieldSubmitted: (_) => onFieldSubmitted(),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // UI helpers
  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController c, {
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: _dec(label, icon: icon, hint: hint),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
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
  String _capFirst(String s) {
    final t = s.trim();
    if (t.isEmpty) return '';
    return t[0].toUpperCase() + t.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        const SizedBox(width: 12),
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
