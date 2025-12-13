import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_response_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/coins_student.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/StudentDrawer.dart';

class TutorProfile extends StatefulWidget {
  const TutorProfile({super.key});

  @override
  State<TutorProfile> createState() => _TutorProfileState();
}

class _TutorProfileState extends State<TutorProfile> {
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

  // Form state
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // Text fields
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();
  final _expCtrl = TextEditingController(); // experience years
  final _qualificationCtrl = TextEditingController();
  final _fbPageLinkCtrl = TextEditingController();
  final _instaLinkCtrl = TextEditingController();
  final _teleLinkCtrl = TextEditingController();
  final _zipcodeCtrl = TextEditingController();

  // Fee Options
  final List<int> minOptions = [for (int v = 100; v <= 1000; v += 100) v];
  final List<int> maxOptionsBase = [for (int v = 300; v <= 3000; v += 100) v];

  int? selectedFeeMin; // 100..1000
  int? selectedFeeMax; // 300..3000

  // Multi-select state
  final List<int> _selBoardIds = [];
  final List<int> _selClassIds = [];
  final List<int> _selSubjectIds = [];

  // Mode & State
  static const _modes = <String>['Online', 'Offline', 'Any'];
  String? modeVal;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  String? _profileImageUrl; // from server

  // Location
  String? _latitude;
  String? _longitude;
  String? _placeId;
  bool _locLoading = false;

  // Misc
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());
    WidgetsBinding.instance.addPostFrameCallback((_) => _c.refreshAll());

    // fetch master data and profile and try to get location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _master.fetchMasterData();
      _p.fetchProfileForTutor();
      try {
        _loc.getCurrentLocation();
      } catch (_) {}
    });

    // Hydrate whenever profile or master data changes
    everAll([_p.tutorprofileData, _master.masterData], (_) async {
      if (_master.masterData.value != null) {
        await _hydrate();
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _localityCtrl.dispose();
    _expCtrl.dispose();
    _qualificationCtrl.dispose();
    _fbPageLinkCtrl.dispose();
    _instaLinkCtrl.dispose();
    _teleLinkCtrl.dispose();
    _zipcodeCtrl.dispose();
    super.dispose();
  }

  // -------------------- Helpers --------------------

  String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return 'https://urbantutors.pro/$path';
  }

  List<int> _uniqueInts(Iterable<int?> items) {
    final s = <int>{};
    for (final i in items) {
      if (i != null && i > 0) s.add(i);
    }
    return s.toList();
  }

  Map<String, List<int>> _listFromTeachingDetails(dynamic teachingDetails) {
    final List<int?> boards = [];
    final List<int?> classes = [];
    final List<int?> subjects = [];

    if (teachingDetails is Iterable) {
      for (final item in teachingDetails) {
        try {
          if (item is TeachingDetails) {
            if (item.boardId != null) boards.add(item.boardId);
            if (item.classId != null) classes.add(item.classId);
            if (item.subjectId != null) subjects.add(item.subjectId);
            continue;
          }

          if (item is Map<String, dynamic>) {
            final b = item['board_id'];
            final c = item['class_id'];
            final s = item['subject_id'];

            if (b != null) {
              boards.add(b is int ? b : int.tryParse(b.toString()));
            }
            if (c != null) {
              classes.add(c is int ? c : int.tryParse(c.toString()));
            }
            if (s != null) {
              subjects.add(s is int ? s : int.tryParse(s.toString()));
            }
            continue;
          }
        } catch (_) {}
      }
    }

    return {
      'board_id': _uniqueInts(boards),
      'class_id': _uniqueInts(classes),
      'subject_id': _uniqueInts(subjects),
    };
  }

  Future<void> _hydrate() async {
    final p = _p.tutorprofileData.value;
    if (p == null) return;

    final lists = _listFromTeachingDetails(p.teachingDetails);

    _selBoardIds
      ..clear()
      ..addAll(lists['board_id'] ?? []);
    _selClassIds
      ..clear()
      ..addAll(lists['class_id'] ?? []);
    _selSubjectIds
      ..clear()
      ..addAll(lists['subject_id'] ?? []);

    if (_selBoardIds.isNotEmpty) {
      try {
        await _leadMeta.loadClasses(_selBoardIds.first);
      } catch (_) {}
    }

    if (_selBoardIds.isNotEmpty && _selClassIds.isNotEmpty) {
      try {
        await _leadMeta.loadSubjects1(
            selClassIds: _selClassIds, selBoardIds: _selBoardIds);
      } catch (_) {}
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      selectedFeeMin = p.minAmount?.toInt() ?? 0;
      selectedFeeMax = p.maxAmount?.toInt() ?? 0;

      _nameCtrl.text = (p.teacherName ?? '').toString().trim();
      _emailCtrl.text = (p.email ?? '').toString().trim();
      _localityCtrl.text = (p.location ?? '').toString().trim();
      _expCtrl.text = (p.experienceYears?.toString() ?? '').toString();
      _qualificationCtrl.text = (p.qualification ?? '').toString();
      _fbPageLinkCtrl.text = (p.fbLink ?? '').toString();
      _instaLinkCtrl.text = (p.instaLink ?? '').toString();
      _teleLinkCtrl.text = (p.whLink ?? '').toString();
      _zipcodeCtrl.text = (p.pincode ?? '').toString();

      String? rawMode = (p.mode ?? '').toString().trim();
      String? normalizedMode;
      if (rawMode.isNotEmpty) {
        final low = rawMode.toLowerCase();
        if (low == 'online') {
          normalizedMode = 'Online';
        } else if (low == 'offline') {
          normalizedMode = 'Offline';
        } else if (low == 'any') {
          normalizedMode = 'Any';
        } else {
          // Try to match case-insensitive
          final match = _modes.firstWhere((m) => m.toLowerCase() == low,
              orElse: () => 'Online');
          normalizedMode = match;
        }
      } else {
        normalizedMode = "Online";
      }

      _profileImageUrl = _resolveImageUrl(p.profilePicture);

      setState(() {
        modeVal = normalizedMode;
      });
    });
  }

  Future<String?> _fileToBase64(XFile? file) async {
    if (file == null) return null;
    final bytes = await File(file.path).readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    return "data:image/$ext;base64,${base64Encode(bytes)}";
  }

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  // -------------------- Image picker --------------------

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _profileImage = picked);
    }
    if (mounted) Navigator.pop(context);
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
                onTap: () => _pickImage(ImageSource.camera)),
            ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () => _pickImage(ImageSource.gallery)),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Remove"),
                onTap: () {
                  setState(() => _profileImage = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _avatarProvider() {
    if (_profileImage != null) return FileImage(File(_profileImage!.path));
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }
    return null;
  }

  // -------------------- Location Logic --------------------
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Error', 'Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Location permissions are permanently denied');
        return;
      }

      if (mounted) setState(() => _locLoading = true);

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String? postalCode;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          postalCode = placemarks.first.postalCode;
        }
      } catch (e) {
        debugPrint('Failed to get postal code: $e');
      }

      if (mounted) {
        setState(() {
          _latitude = position.latitude.toString();
          _longitude = position.longitude.toString();
          if (postalCode != null && postalCode.isNotEmpty) {
            _zipcodeCtrl.text = postalCode;
          }
          _locLoading = false;
        });
        Get.snackbar('Success', 'Location retrieved successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100);
      }
    } catch (e) {
      if (mounted) setState(() => _locLoading = false);
      Get.snackbar('Error', 'Failed to get location: $e');
    }
  }

  // -------------------- Save / Update --------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar('Error', 'Please fill all required fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    setState(() => _saving = true);
    try {
      final uidStr = await StorageService.getUserId();
      final userId = int.tryParse('$uidStr') ?? 0;
      if (userId <= 0) {
        Get.snackbar('Error', 'No user id found',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        return;
      }

      final profileBase64 = await _fileToBase64(_profileImage);

      final boardIds = _uniqueInts(_selBoardIds);
      final classIds = _uniqueInts(_selClassIds);
      final subjectIds = _uniqueInts(_selSubjectIds);

      final experienceYears = int.tryParse(_expCtrl.text.trim()) ?? 0;

      final payload = {
        "user_id": userId,
        "email": _emailCtrl.text.trim(),
        "location": _localityCtrl.text.trim(),
        "pincode": _zipcodeCtrl.text.trim(),
        "qualification": _qualificationCtrl.text.trim(),
        "min_amount": selectedFeeMin ?? 0,
        "max_amount": selectedFeeMax ?? 0,
        "mode": modeVal ?? '',
        "experience_years": experienceYears,
        "place_id": _placeId ?? '',
        "latitude": _latitude ?? '',
        "longitude": _longitude ?? '',
        "board_id": boardIds,
        "class_id": classIds,
        if (subjectIds.isNotEmpty) "subject_id": subjectIds,
        "fb_link": _fbPageLinkCtrl.text.trim(),
        "insta_link": _instaLinkCtrl.text.trim(),
        "wh_link": _teleLinkCtrl.text.trim(),
      };
      if (profileBase64 != null) {
        payload["profile_picture"] = profileBase64;
      }
      if (profileBase64 == null) {
        payload["profile_picture"] = _profileImageUrl!;
      }

      final ok = await _p.updateTutorProfile(payload);
      if (ok == true) {
        Get.snackbar('Success', 'Profile Updated Successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        await _p.fetchProfileForTutor();
        await _hydrate();
        setState(() => _profileImage = null);
      } else {
        Get.snackbar('Error', 'Failed to update profile',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // -------------------- UI Building --------------------

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      key: _scaffoldKey,
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
              const SnackBar(content: Text('Logged out successfully')));
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
              (route) => false);
        }
      }),
      body: Obx(() {
        final loading = _p.isLoading.value && _p.tutorprofileData.value == null;
        if (loading) return const Center(child: CircularProgressIndicator());

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(primary, accent),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildProfileImage(),
                      const SizedBox(height: 24),
                      _buildBasicInfoSection(),
                      const SizedBox(height: 16),
                      _buildProfessionalInfoSection(),
                      const SizedBox(height: 16),
                      _buildLocationSection(),
                      const SizedBox(height: 16),
                      _buildSocialLinksSection(),
                      const SizedBox(height: 32),
                      _buildSaveButton(),
                      const SizedBox(height: 16),
                      _buildShareButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar(Color primary, Color accent) {
    return SliverAppBar(
      expandedHeight: 60.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
          title: Obx(() {
            final wallet = _c.myCoins.value;
            final balanceNum = _toNum(wallet?.available);
            final balanceText = balanceNum.toStringAsFixed(0);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 32),
                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CoinsStudentScreen()));
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "$balanceText Coins",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    final prof = _p.tutorprofileData.value;
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _avatarProvider(),
              backgroundColor: Colors.grey.shade200,
              child: _avatarProvider() == null
                  ? Text(
                      (prof?.teacherName ?? '').trim().isEmpty
                          ? 'T'
                          : (prof?.teacherName ?? 'T')
                              .trim()
                              .characters
                              .first
                              .toUpperCase(),
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor),
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _showPickerOptions,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child:
                    const Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSectionCard(
      title: 'Basic Information',
      children: [
        _buildTextField(
          label: 'Full Name',
          controller: _nameCtrl,
          icon: Icons.person_outline,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Email',
          controller: _emailCtrl,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoSection() {
    return _buildSectionCard(
      title: 'Professional Details',
      children: [
        _buildMultiSelectTile(
          label: 'Boards',
          selectedIds: _selBoardIds,
          options: _boardOptions(),
          onTap: () async {
            final picked = await _showMultiSelect(
              context,
              title: 'Select Boards',
              options: _boardOptions(),
              initial: _selBoardIds,
            );
            if (picked != null) {
              setState(() {
                _selBoardIds
                  ..clear()
                  ..addAll(picked);
                _selClassIds.clear();
                _selSubjectIds.clear();
              });
              if (_selBoardIds.isNotEmpty) {
                await _leadMeta.loadClasses(_selBoardIds.first);
              }
            }
          },
        ),
        const SizedBox(height: 12),
        _buildMultiSelectTile(
          label: 'Classes',
          selectedIds: _selClassIds,
          options: _classOptions(),
          onTap: () async {
            if (_selBoardIds.isEmpty) {
              Get.snackbar('Notice', 'Please select a Board first');
              return;
            }
            if (_leadMeta.classes.isEmpty) {
              await _leadMeta.loadClasses(_selBoardIds.first);
            }
            final picked = await _showMultiSelect(
              context,
              title: 'Select Classes',
              options: _classOptions(),
              initial: _selClassIds,
            );
            if (picked != null) {
              setState(() {
                _selClassIds
                  ..clear()
                  ..addAll(picked);
                _selSubjectIds.clear();
              });
              if (_selBoardIds.isNotEmpty && _selClassIds.isNotEmpty) {
                await _leadMeta.loadSubjects1(
                    selClassIds: _selClassIds, selBoardIds: _selBoardIds);
              }
            }
          },
        ),
        const SizedBox(height: 12),
        _buildMultiSelectTile(
          label: 'Subjects',
          selectedIds: _selSubjectIds,
          options: _subjectOptions(),
          onTap: () async {
            if (_selClassIds.isEmpty) {
              Get.snackbar('Notice', 'Please select Classes first');
              return;
            }
            final picked = await _showMultiSelect(
              context,
              title: 'Select Subjects',
              options: _subjectOptions(),
              initial: _selSubjectIds,
            );
            if (picked != null) {
              setState(() {
                _selSubjectIds
                  ..clear()
                  ..addAll(picked);
              });
            }
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdown<int>(
                label: 'Min Fee',
                value: selectedFeeMin,
                items: minOptions
                    .map((v) =>
                        DropdownMenuItem(value: v, child: Text('₹$v/Hr')))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedFeeMin = val;
                    final clampMinForMax =
                        (val == null) ? 300 : (val < 300 ? 300 : val);
                    if (selectedFeeMax != null &&
                        selectedFeeMax! < clampMinForMax) {
                      selectedFeeMax = clampMinForMax;
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown<int>(
                label: 'Max Fee',
                value: selectedFeeMax,
                items: maxOptionsBase
                    .where((v) =>
                        v >=
                        ((selectedFeeMin == null)
                            ? 300
                            : (selectedFeeMin! < 300 ? 300 : selectedFeeMin!)))
                    .map((v) =>
                        DropdownMenuItem(value: v, child: Text('₹$v/Hr')))
                    .toList(),
                onChanged: (val) => setState(() => selectedFeeMax = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Qualification',
          controller: _qualificationCtrl,
          icon: Icons.school_outlined,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Experience (Years)',
          controller: _expCtrl,
          icon: Icons.work_history_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 12),
        _buildDropdown<String>(
          label: 'Teaching Mode',
          value: modeVal,
          items: _modes
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (v) => setState(() => modeVal = v),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSectionCard(
      title: 'Location Details',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Zipcode',
                controller: _zipcodeCtrl,
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => (v?.length ?? 0) < 6 ? 'Invalid' : null,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _locLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      onPressed: _getCurrentLocation,
                      icon: Icon(Icons.my_location,
                          color: AppColors.primaryColor),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final searching = _loc.isSearching.value;
          final opts = _loc.suggestions;
          return Autocomplete<String>(
            optionsBuilder: (TextEditingValue tev) {
              final q = tev.text.trim();
              if (q.isEmpty) return const Iterable<String>.empty();
              return opts;
            },
            onSelected: (val) {
              _localityCtrl.text = val;
              _loc.onQueryChanged('');
            },
            fieldViewBuilder: (context, textCtrl, focusNode, onFieldSubmitted) {
              if (textCtrl.text != _localityCtrl.text) {
                textCtrl.text = _localityCtrl.text;
                textCtrl.selection = TextSelection.fromPosition(
                    TextPosition(offset: textCtrl.text.length));
              }
              textCtrl.addListener(() {
                final q = textCtrl.text;
                if (_localityCtrl.text != q) {
                  _localityCtrl.text = q;
                  _loc.onQueryChanged(q);
                }
              });
              return _buildTextField(
                label: 'Locality',
                controller: textCtrl,
                focusNode: focusNode,
                icon: Icons.location_on_outlined,
                suffix: searching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
                onSubmitted: (_) => onFieldSubmitted(),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSocialLinksSection() {
    return _buildSectionCard(
      title: 'Social Links',
      children: [
        _buildTextField(
          label: 'Facebook',
          controller: _fbPageLinkCtrl,
          icon: Icons.facebook,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Instagram',
          controller: _instaLinkCtrl,
          icon: Icons.camera_alt_outlined,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'WhatsApp/Telegram',
          controller: _teleLinkCtrl,
          icon: Icons.message_outlined,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: _saving ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _saving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _shareProfile,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: BorderSide(color: AppColors.primaryColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.share),
        label: const Text('Share Profile'),
      ),
    );
  }

  // -------------------- UI Components --------------------

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    Widget? suffix,
    Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            icon != null ? Icon(icon, color: Colors.grey.shade600) : null,
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.all(12), child: suffix)
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildMultiSelectTile({
    required String label,
    required List<int> selectedIds,
    required List<OptionInt> options,
    required VoidCallback onTap,
  }) {
    final selectedNames = _labelsFor(selectedIds, options);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            const SizedBox(height: 8),
            if (selectedNames.isEmpty)
              Text('Tap to select',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedNames
                    .map((n) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.primaryColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            n,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------- Data Helpers --------------------

  List<OptionInt> _boardOptions() =>
      (_master.masterData.value?.data.boardLead ?? [])
          .map((b) => OptionInt(
              (b.boardId is int)
                  ? b.boardId
                  : int.tryParse('${b.boardId}') ?? 0,
              b.boardLabel ?? ''))
          .toList();
  List<OptionInt> _classOptions() =>
      _leadMeta.classes.map((c) => OptionInt(c.classId, c.className)).toList();
  List<OptionInt> _subjectOptions() => _leadMeta.subjects
      .map((s) => OptionInt(s.subjectId ?? 0, (s.subjectName ?? '').toString()))
      .toList();

  List<String> _labelsFor(List<int> selectedIds, List<OptionInt> all) {
    final map = {for (final o in all) o.id: o.label};
    return selectedIds.map((id) => map[id] ?? '#$id').toList();
  }

  // -------------------- Share Logic --------------------

  Future<String> _publicProfileUrl() async {
  final uid = await StorageService.getUserId();
  // Return a deep link / app link for sharing within the mobile app
  return 'https://play.google.com/store/apps/details?id=pro.urbantutors.app';
}

  Future<void> _shareProfile() async {
  // Generate the app deep link for the tutor profile
  final appLink = await _publicProfileUrl();

  // Gather basic info from the form controllers
  final name = _nameCtrl.text.trim().isEmpty ? 'Tutor' : _nameCtrl.text.trim();
  final email = _emailCtrl.text.trim();
  final location = _localityCtrl.text.trim();
  final experience = _expCtrl.text.trim();
  final qualification = _qualificationCtrl.text.trim();
  final fb = _fbPageLinkCtrl.text.trim();
  final insta = _instaLinkCtrl.text.trim();
  final whatsapp = _teleLinkCtrl.text.trim();
  final zipcode = _zipcodeCtrl.text.trim();

  // Fee range
  final feeMin = selectedFeeMin != null ? selectedFeeMin.toString() : '-';
  final feeMax = selectedFeeMax != null ? selectedFeeMax.toString() : '-';

  // Mode (Online/Offline/Any)
  final mode = modeVal ?? 'Online';

  // Boards, Classes, Subjects labels (using helper _labelsFor if available)
  String boards = '';
  String classes = '';
  String subjects = '';
  try {
    boards = _labelsFor(_selBoardIds, _boardOptions()).join(', ');
    classes = _labelsFor(_selClassIds, _classOptions()).join(', ');
    subjects = _labelsFor(_selSubjectIds, _subjectOptions()).join(', ');
  } catch (_) {}

  // Build the share message without the website URL, using the app link instead
  final details = StringBuffer();
  details.writeln('Download the app and check out $name\'s profile on Urban Tutors:');
  details.writeln(appLink);
  details.writeln('');
  details.writeln('👤 Name: $name');
  if (email.isNotEmpty) details.writeln('📧 Email: $email');
  if (location.isNotEmpty) details.writeln('📍 Location: $location');
  if (zipcode.isNotEmpty) details.writeln('🏷️ Zipcode: $zipcode');
  if (experience.isNotEmpty) details.writeln('⏳ Experience: $experience years');
  if (qualification.isNotEmpty) details.writeln('🎓 Qualification: $qualification');
  details.writeln('💼 Mode: $mode');
  details.writeln('💰 Fee: ₹$feeMin - ₹$feeMax');
  if (boards.isNotEmpty) details.writeln('📚 Boards: $boards');
  if (classes.isNotEmpty) details.writeln('🏫 Classes: $classes');
  if (subjects.isNotEmpty) details.writeln('📖 Subjects: $subjects');
  if (fb.isNotEmpty) details.writeln('🔗 Facebook: $fb');
  if (insta.isNotEmpty) details.writeln('📸 Instagram: $insta');
  if (whatsapp.isNotEmpty) details.writeln('💬 WhatsApp/Telegram: $whatsapp');

  await Share.share(details.toString(), subject: 'Tutor Profile');
}
}

// -------------------- Helper Classes --------------------

class OptionInt {
  final int id;
  final String label;
  const OptionInt(this.id, this.label);
}

Future<List<int>?> _showMultiSelect(BuildContext context,
    {required String title,
    required List<OptionInt> options,
    required List<int> initial}) async {
  final Set<int> chosen = {...initial};
  return showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return StatefulBuilder(builder: (context, setSheetState) {
              final allSelected = options.isNotEmpty &&
                  options.every((o) => chosen.contains(o.id));

              return Column(children: [
                const SizedBox(height: 12),
                Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 16),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, initial),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx, chosen.toList()),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Apply')),
                    ])),
                const Divider(),
                CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: const Text('Select All',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  value: allSelected,
                  activeColor: AppColors.primaryColor,
                  onChanged: (v) {
                    setSheetState(() {
                      if (v == true) {
                        chosen.clear();
                        chosen.addAll(options.map((o) => o.id));
                      } else {
                        chosen.clear();
                      }
                    });
                  },
                ),
                Expanded(
                  child: ListView.builder(
                      controller: controller,
                      itemCount: options.length,
                      itemBuilder: (_, i) {
                        final o = options[i];
                        final checked = chosen.contains(o.id);
                        return CheckboxListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            title: Text(o.label),
                            value: checked,
                            activeColor: AppColors.primaryColor,
                            onChanged: (v) {
                              setSheetState(() {
                                if (v == true) {
                                  chosen.add(o.id);
                                } else {
                                  chosen.remove(o.id);
                                }
                              });
                            });
                      }),
                ),
              ]);
            });
          }));
}
