import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'package:url_launcher/url_launcher.dart';

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
  final _expCtrl = TextEditingController(); // NEW: experience years
  final _qualificationCtrl = TextEditingController();
  final _fbPageLinkCtrl = TextEditingController();
  final _instaLinkCtrl = TextEditingController();
  final _teleLinkCtrl = TextEditingController();

  // Multi-select state (NEW)
  final List<int> _selBoardIds = [];
  final List<int> _selClassIds = [];
  final List<int> _selSubjectIds = [];
  final locCtrl = Get.put(LocationController());
  // Mode
  static const _modes = <String>['Online', 'Offline', 'Any'];
  String? modeVal;
  String? stateVal;
  static const _states = <String>[
    'Delhi',
    'Uttar Pradesh',
    'Haryana',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu'
  ];
  // Image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  String? _profileImageUrl; // from server
  // Misc
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();

    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());
    WidgetsBinding.instance.addPostFrameCallback((_) => _c.refreshAll());
    _master.fetchMasterData();
    _p.fetchProfileForTutor();
    locCtrl.getCurrentLocation();
    // Hydrate whenever any of these change AND master data exists
    everAll([_p.tutorprofileData, _master.masterData], (_) async {
      if (_master.masterData.value != null) {
        await _hydrate(); // will pick the best available profile
      }
    });
  }

  String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    // ✅ fix the missing slash and point to your real host if different
    final imageUrl = 'https://urbantutors.pro/$path';
    print("imageurl : $imageUrl");
    return imageUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _localityCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  Future<void> _hydrate() async {
    final p = _p.tutorprofileData.value;
    if (p == null) return;

    // Prepare values (no setState / controller updates yet)
    final name = (p.teacherName ?? '').trim();
    final mobile = (p.mobile ?? '').trim();
    final email = (p.email ?? '').trim();
    final state = p.state ?? '';
    final location = p.location ?? '';
    final profilePicture = _resolveImageUrl(p.profilePicture);
    final teachingDetails = p.teachingDetails;

    // Schedule the UI mutation after the current build/frame finishes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // text controllers
      _nameCtrl.text = name;
      // _emailCtrl.text = mobile;
      _emailCtrl.text = email;
      _localityCtrl.text = location;
      // image url
      _profileImageUrl = profilePicture;
      stateVal = state;

      // STEP 1: Extract IDs automatically from teachingDetails
      if (teachingDetails.isNotEmpty) {
        for (var item in teachingDetails) {
          if (item.boardId != null) _selBoardIds.add(item.boardId!);
          if (item.classId != null) _selClassIds.add(item.classId!);
          if (item.subjectId != null) _selSubjectIds.add(item.subjectId!);
        }
      }

      print("✅ Selected Board IDs: $_selBoardIds");
      print("✅ Selected Class IDs: $_selClassIds");
      print("✅ Selected Subject IDs: $_selSubjectIds");

      setState(() {});
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

  // -------------------- Save --------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selBoardIds.isEmpty ||
        _selClassIds.isEmpty ||
        _selSubjectIds.isEmpty) {
      Get.snackbar('Missing info', 'Please select Boards, Classes and Subjects',
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
      final experienceYears = int.tryParse(_expCtrl.text.trim()) ?? 0;
      print('Lat: ${locCtrl.latitude.value}');
      print('Lng: ${locCtrl.longitude.value}');
      print('Place ID: ${locCtrl.placeId.value}');
      print('Address: ${locCtrl.address.value}');

      final request = {
        "user_id": userId,
        "email": _emailCtrl.text.toString(),
        "location": _localityCtrl.text.trim(),
        "state": stateVal,
        "remark": experienceYears,
        "profile_picture": profileBase64 ?? '',
        "latitude": locCtrl.latitude.value,
        "longitude": locCtrl.longitude.value,
        "place_id": locCtrl.placeId.value,
        "board_id": _selBoardIds,
        "class_id": _selClassIds,
        "subject_id": _selSubjectIds,
        "qualification": _qualificationCtrl.text.toString(),
        "fb_link": _fbPageLinkCtrl.text.trim(),
        "insta_link": _instaLinkCtrl.text.trim(),
        "tel_link": _teleLinkCtrl.text.trim(),
      };

      final ok = await _p.updateTutorProfile(request);
      if (ok) {
        Get.snackbar('Success', 'Profile Updated Successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);

        await _p.fetchProfileForStudent();
        await _hydrate();
        setState(() => _profileImage = null);
      }
    } catch (e) {
      debugPrint('Failed $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // -------------------- UI helpers --------------------

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

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
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
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: _dec(label, icon: icon, hint: hint),
        validator: validator ??
            (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }

  List<String> _labelsFor(List<int> selectedIds, List<OptionInt> all) {
    final map = {for (final o in all) o.id: o.label};
    return selectedIds.map((id) => map[id]).whereType<String>().toList();
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
// --- replace your current bottomNavigationBar with this ---
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Save Changes
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 10),

            // Share Profile
            SizedBox(
              height: 48,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                child: OutlinedButton.icon(
                  onPressed: _shareProfile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: BorderSide(color: AppColors.primaryColor, width: 1.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('Share Your Profile'),
                ),
              ),
            ),
          ],
        ),
      ),

      body: Obx(() {
        final loading =
            _p.isLoading.value && _p.studentprofileData.value == null;
        if (loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final prof = _p.studentprofileData.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Center(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.primaryColor, width: 1),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              backgroundImage: _avatarProvider(),
                              backgroundColor: Colors.grey.shade300,
                              child: _avatarProvider() == null
                                  ? Text(
                                      ((prof?.studentName ?? 'U').trim().isEmpty
                                          ? 'U'
                                          : prof!.studentName!
                                              .trim()
                                              .characters
                                              .first
                                              .toUpperCase()),
                                      style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -6,
                          right: -6,
                          child: InkWell(
                            onTap: _showPickerOptions,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryColor,
                              child: const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Basic
                _sectionCard(
                  title: 'Basic:',
                  children: [
                    _textField('Full Name', _nameCtrl,
                        icon: Icons.person, hint: 'Your name'),
                    SizedBox(
                      width: 16,
                    ),
                    _textField(
                      'Email',
                      _emailCtrl,
                      icon: Icons.email,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),

                // Professional (multi-selects + experience)
                _sectionCard(
                  title: 'Professional:',
                  children: [
                    // Boards (multi)
                    SizedBox(
                      width: 600,
                      child: _MultiSelectTile(
                        label: 'Boards you Teach : ',
                        selectedNames: _labelsFor(
                          _selBoardIds,
                          (_master.masterData.value?.data?.boardLead ?? [])
                              .map((b) => OptionInt(
                                    (b.boardId is int)
                                        ? b.boardId!
                                        : int.tryParse('${b.boardId}') ?? 0,
                                    b.boardLabel ?? '',
                                  ))
                              .toList(),
                        ),
                        onTap: () async {
                          final options =
                              (_master.masterData.value?.data?.boardLead ?? [])
                                  .map((b) => OptionInt(
                                        (b.boardId is int)
                                            ? b.boardId!
                                            : int.tryParse('${b.boardId}') ?? 0,
                                        b.boardLabel ?? '',
                                      ))
                                  .toList();

                          final picked = await _showMultiSelect(
                            context,
                            title: 'Select Boards : ',
                            options: options,
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
                    ),

                    // Classes (multi)
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: SizedBox(
                        width: 600,
                        child: _MultiSelectTile(
                          label: 'Classes you Teach : ',
                          selectedNames: _labelsFor(
                            _selClassIds,
                            _leadMeta.classes
                                .map((c) => OptionInt(c.classId, c.className))
                                .toList(),
                          ),
                          onTap: () async {
                            if (_selBoardIds.isEmpty) {
                              Get.snackbar('Select Board',
                                  'Please select at least one Board first',
                                  snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            if (_leadMeta.classes.isEmpty) {
                              await _leadMeta.loadClasses(_selBoardIds.first);
                            }

                            final options = _leadMeta.classes
                                .map((c) => OptionInt(c.classId, c.className))
                                .toList();

                            final picked = await _showMultiSelect(
                              context,
                              title: 'Select Classes',
                              options: options,
                              initial: _selClassIds,
                            );
                            if (picked != null) {
                              setState(() {
                                _selClassIds
                                  ..clear()
                                  ..addAll(picked);
                                _selSubjectIds.clear();
                              });

                              if (_selBoardIds.isNotEmpty &&
                                  _selClassIds.isNotEmpty) {
                                await _leadMeta.loadSubjects(
                                  classId: _selClassIds.first,
                                  boardId: _selBoardIds.first,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),

                    // Subjects (multi)
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: SizedBox(
                        width: 600,
                        child: _MultiSelectTile(
                          label: 'Subjects you Teach : ',
                          selectedNames: _labelsFor(
                            _selSubjectIds,
                            _leadMeta.subjects
                                .map((s) => OptionInt(
                                      s.subjectId ?? 0,
                                      (s.subjectName ?? '').toString(),
                                    ))
                                .toList(),
                          ),
                          onTap: () async {
                            if (_selBoardIds.isEmpty || _selClassIds.isEmpty) {
                              Get.snackbar('Select Class',
                                  'Please select Boards and Classes first',
                                  snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            if (_leadMeta.subjects.isEmpty) {
                              await _leadMeta.loadSubjects(
                                classId: _selClassIds.first,
                                boardId: _selBoardIds.first,
                              );
                            }

                            final options = _leadMeta.subjects
                                .map((s) => OptionInt(
                                      s.subjectId ?? 0,
                                      (s.subjectName ?? '').toString(),
                                    ))
                                .toList();

                            final picked = await _showMultiSelect(
                              context,
                              title: 'Select Subjects',
                              options: options,
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
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    _textField(
                      'Qualification : ',
                      _qualificationCtrl,
                      icon: Icons.book,
                      hint: 'Qualification : ',
                    ),

                    SizedBox(
                      height: 16,
                    ),

                    // Experience (years)
                    _textField(
                      'Experience (years) : ',
                      _expCtrl,
                      icon: Icons.work_outline,
                      hint: 'e.g. 3',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),

                // Mode
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: modeVal,
                    decoration: _dec('Select Mode', icon: Icons.swap_calls),
                    items: _modes
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => modeVal = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
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
                          if (q.isEmpty) return const Iterable<String>.empty();
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

                // State
                Container(
                  padding: EdgeInsets.all(8),
                  child: _dropdownDec(
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: stateVal,
                      icon: const Icon(Icons.expand_more_rounded,
                          color: Color(0xFF9CA3AF)),
                      decoration: _fieldDec('Select State'),
                      items: _states
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => stateVal = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      _textField(
                        'Facebook Page Link',
                        _fbPageLinkCtrl,
                        icon: Icons.facebook,
                        hint: 'Facebook Page Link',
                      ),
                      _textField(
                        'Instagram Page Link',
                        _instaLinkCtrl,
                        icon: Icons.face,
                        hint: 'Insta Link',
                      ),
                      _textField(
                        'Whatsapp Community / Group Link',
                        _teleLinkCtrl,
                        icon: Icons.telegram,
                        hint: 'Whatsapp  Link',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  List<OptionInt> _boardOptions() =>
      (_master.masterData.value?.data?.boardLead ?? [])
          .map((b) => OptionInt(
                (b.boardId is int)
                    ? b.boardId!
                    : int.tryParse('${b.boardId}') ?? 0,
                b.boardLabel ?? '',
              ))
          .toList();

  List<OptionInt> _classOptions() =>
      _leadMeta.classes.map((c) => OptionInt(c.classId, c.className)).toList();

  List<OptionInt> _subjectOptions() => _leadMeta.subjects
      .map((s) => OptionInt(s.subjectId ?? 0, (s.subjectName ?? '').toString()))
      .toList();

  String _comma(List<String> items) => items.isEmpty ? '-' : items.join(', ');

  List<String> _labelsForIds(List<int> ids, List<OptionInt> pool) {
    final map = {for (final o in pool) o.id: o.label};
    return ids.map((id) => map[id] ?? '#$id').toList();
  }

  Future<String> _buildShareMessage() async {
    final url = await _publicProfileUrl();
    final name =
        _nameCtrl.text.trim().isEmpty ? 'Tutor' : _nameCtrl.text.trim();
    final boards = _labelsForIds(_selBoardIds, _boardOptions());
    final classes = _labelsForIds(_selClassIds, _classOptions());
    final subjects = _labelsForIds(_selSubjectIds, _subjectOptions());

    final qual = _qualificationCtrl.text.trim();
    final exp = _expCtrl.text.trim();
    final loc = _localityCtrl.text.trim();

    final lines = <String>[
      'Tutor’s @ www.urbantutors.pro',
      'Name : $name',
      'Boards: ${_comma(boards)}',
      'Classes: ${_comma(classes)}',
      'Subjects: ${_comma(subjects)}',
      'Qualification: ${qual.isNotEmpty ? qual : "Test"}',
      'Experience: ${exp.isNotEmpty ? "${exp} years" : "test"}',
      if (loc.isNotEmpty || stateVal != null)
        'Location: $loc${stateVal != null && stateVal!.isNotEmpty ? ', $stateVal' : ''}',
      if (modeVal != null) 'Mode: $modeVal',
      if (_fbPageLinkCtrl.text.trim().isNotEmpty)
        'Facebook: ${_fbPageLinkCtrl.text.trim()}',
      if (_instaLinkCtrl.text.trim().isNotEmpty)
        'Instagram: ${_instaLinkCtrl.text.trim()}',
      if (_teleLinkCtrl.text.trim().isNotEmpty)
        'WhatsApp/Telegram: ${_teleLinkCtrl.text.trim()}',
      '',
      'Kindly, View My Profile @ $url',
    ];

    return lines.join('\n');
  }

  Future<String> _publicProfileUrl() async {
    final uid = await StorageService.getUserId();
    // TODO: replace with your actual public URL pattern
    return 'https://urbantutors.app/profile/$uid';
  }

  Future<void> _shareGeneric() async {
    final text = await _buildShareMessage();

    // If a local avatar is chosen, attach it; some apps may show only image.
    if (_profileImage != null) {
      await Share.shareXFiles(
        [XFile(_profileImage!.path)],
        text: text,
        subject: 'My Tutor Profile',
      );
    } else {
      await Share.share(text, subject: 'My Tutor Profile');
    }
  }

  Future<void> _shareToWhatsApp() async {
    final url = await _publicProfileUrl();
    final text = Uri.encodeComponent('Check out my tutor profile:\n$url');
    final uri = Uri.parse('whatsapp://send?text=$text');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // fallback to generic share
      await _shareGeneric();
    }
  }

  Future<void> _copyLink() async {
    final url = await _publicProfileUrl();
    await Clipboard.setData(ClipboardData(text: url));
    Get.snackbar('Copied', 'Profile link copied to clipboard',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _shareProfile() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.facebook),
              title: const Text('Share to Facebook'),
              onTap: () async {
                Navigator.pop(context);
                await _shareGeneric();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_page_break_rounded),
              title: const Text('Share to Intagram'),
              onTap: () async {
                Navigator.pop(context);
                await _shareGeneric();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share to WhatsApp'),
              onTap: () async {
                Navigator.pop(context);
                await _shareToWhatsApp();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy profile link'),
              onTap: () async {
                Navigator.pop(context);
                await _copyLink();
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 1.2),
      ),
    );
  }

  Widget _dropdownDec(Widget child) => Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: child,
      );
}

// -------------------- Header --------------------

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

// -------------------- Multi-select Helpers --------------------

class OptionInt {
  final int id;
  final String label;
  const OptionInt(this.id, this.label);
}

class _MultiSelectTile extends StatelessWidget {
  const _MultiSelectTile({
    required this.label,
    required this.selectedNames,
    required this.onTap,
  });

  final String label;
  final List<String> selectedNames;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (selectedNames.isEmpty)
              Text('Tap to select',
                  style: TextStyle(color: Colors.grey.shade600))
            else
              Wrap(
                spacing: 6,
                runSpacing: -6,
                children: selectedNames
                    .map((n) => Container(
                          margin: EdgeInsets.all(4),
                          child: Chip(
                            label: Text(n),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(
                                vertical: -4, horizontal: -4),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

Future<List<int>?> _showMultiSelect(
  BuildContext context, {
  required String title,
  required List<OptionInt> options,
  required List<int> initial,
}) async {
  final Set<int> chosen = {...initial};
  return showModalBottomSheet<List<int>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, initial),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, chosen.toList()),
                    child: const Text('APPLY'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StatefulBuilder(
                builder: (context, setSheetState) {
                  return ListView.builder(
                    controller: controller,
                    itemCount: options.length,
                    itemBuilder: (_, i) {
                      final o = options[i];
                      final checked = chosen.contains(o.id);
                      return CheckboxListTile(
                        dense: true,
                        title: Text(o.label, overflow: TextOverflow.ellipsis),
                        value: checked,
                        onChanged: (v) {
                          setSheetState(() {
                            if (v == true) {
                              chosen.add(o.id);
                            } else {
                              chosen.remove(o.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}
