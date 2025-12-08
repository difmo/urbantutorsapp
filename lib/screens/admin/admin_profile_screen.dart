import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
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
  bool _locLoading = false;

  // Text fields
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _agencyNameCtrl = TextEditingController();
  final _bussinessInYearCtrl = TextEditingController();
  final _fbPageLinkCtrl = TextEditingController();
  final _instaLinkCtrl = TextEditingController();
  final _teleLinkCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();
  final _zipcodeCtrl = TextEditingController();
  final _accountHolderNameCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController(); // renamed
  final _ifscCodeCtrl = TextEditingController();
  final FocusNode _localityFocusNode = FocusNode();

  // Location data
  String? _latitude;
  String? _longitude;
  String? _placeId;

  int? _boardId;
  int? _classId;

  // Multi-select state (kept for future use)
  final List<int> _selBoardIds = [];
  final List<int> _selClassIds = [];
  final List<int> _selSubjectIds = [];

  // Mode / State (kept minimal)
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

  // Image pickers
  final ImagePicker _picker = ImagePicker();

  XFile? _profileImage; // local picked file (profile)
  String? _profileImageUrl; // remote url (profile)

  XFile? _agencyLogo; // local picked file (agency)
  String? _agencyLogoUrl; // remote url (agency)

  // Misc
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PayCourseController _payCourseController =
      Get.isRegistered<PayCourseController>()
          ? Get.find<PayCourseController>()
          : Get.put(PayCourseController());

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
      if (_p.adminProfileData.value == null && !_p.isLoading.value) {
        await _p.fetchProfileForAdmin();
      }
      await _hydrate();
    });

    // Re-hydrate whenever profile changes
    ever(_p.adminProfileData, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _hydrate();
      });
    });
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _agencyNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _localityCtrl.dispose();
    _localityFocusNode.dispose();
    _zipcodeCtrl.dispose();
    _accountHolderNameCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _ifscCodeCtrl.dispose();
    super.dispose();
  }

  // -------------------- Data helpers --------------------

  String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    const base = 'https://urbantutors.pro/'; // TODO: replace with your API host
    return '$base$path';
  }

  Future<void> _hydrate() async {
    final p = _p.adminProfileData.value;
    if (p == null) return;
    print("all Admin Profile Data $p");

    if (!mounted) return;

    // Populate text controllers if server returned values
    setState(() {
      _fullNameCtrl.text = (p.fullName ?? p.tutorburoName ?? '').toString().trim();
      _agencyNameCtrl.text = (p.agencyName ?? '').toString().trim();
      _phoneCtrl.text = (p.phone ?? p.tutorburoMobile ?? '').toString().trim();
      _emailCtrl.text = (p.email ?? '').toString().trim();
      _localityCtrl.text = (p.location ?? '').toString().trim();
      _bussinessInYearCtrl.text = (p.yearInBussiness?.toString() ?? '').trim();
      _fbPageLinkCtrl.text = (p.fbLink ?? '').toString();
      _instaLinkCtrl.text = (p.instaLink ?? '').toString();
      _teleLinkCtrl.text = (p.telLink ?? '').toString();

      _accountHolderNameCtrl.text =
          (p.accountHolderName ?? '').toString().trim();
      _bankNameCtrl.text = (p.bankName ?? '').toString().trim();
      _accountNumberCtrl.text = (p.accountNumber ?? '').toString().trim();
      _ifscCodeCtrl.text = (p.ifscCode ?? '').toString().trim();

      _profileImageUrl = _resolveImageUrl(p.profilePicture);
      _agencyLogoUrl = _resolveImageUrl(p.agencyLogo);

      _latitude = p.latitude;
      _longitude = p.longitude;
      _placeId = p.placeId;
      _zipcodeCtrl.text = (p.pincode ?? '').toString();

      stateVal = (p.state ?? stateVal)?.toString();
      print("Hydrated Location: ${_localityCtrl.text}, Zip: ${_zipcodeCtrl.text}");
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

  // -------------------- Image pickers --------------------

  Future<void> _pickImage(ImageSource source, {required bool isAgency}) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        if (isAgency) {
          _agencyLogo = picked;
        } else {
          _profileImage = picked;
        }
      });
    }
    if (mounted) Navigator.pop(context);
  }

  void _showPickerOptions({required bool isAgency}) {
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
              onTap: () => _pickImage(ImageSource.camera, isAgency: isAgency),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () => _pickImage(ImageSource.gallery, isAgency: isAgency),
            ),
            if ((isAgency ? _agencyLogo : _profileImage) != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Remove"),
                onTap: () {
                  setState(() {
                    if (isAgency) {
                      _agencyLogo = null;
                      _agencyLogoUrl = null;
                    } else {
                      _profileImage = null;
                      _profileImageUrl = null;
                    }
                  });
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  // Providers
  ImageProvider? _profileImageProvider() {
    if (_profileImage != null) return FileImage(File(_profileImage!.path));
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }
    return null;
  }

  ImageProvider? _agencyLogoProvider() {
    if (_agencyLogo != null) return FileImage(File(_agencyLogo!.path));
    if (_agencyLogoUrl != null && _agencyLogoUrl!.isNotEmpty) {
      return NetworkImage(_agencyLogoUrl!);
    }
    return null;
  }

  // Shortcuts for onEdit
  void _showProfilePickerOptions() => _showPickerOptions(isAgency: false);
  void _showAgencyPickerOptions() => _showPickerOptions(isAgency: true);

  // -------------------- Payload builder --------------------

  Future<Map<String, dynamic>> _buildUpdatePayload(int userId) async {
    final profileBase64 = await _fileToBase64(_profileImage);
    final agencyBase64 = await _fileToBase64(_agencyLogo);

    int? profileId;
    final stored = _p.adminProfileData.value;
    if (stored != null) {
      try {
        profileId = stored.tutorburoProfileId;
      } catch (_) {
        profileId = null;
      }
    }

    final Map<String, dynamic> payload = {
      "user_id": userId,
      if (profileId != null) "tutorburo_profile_id": profileId,
      "full_name": _fullNameCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "agency_name": _agencyNameCtrl.text.trim(),
      "year_in_bussiness": _bussinessInYearCtrl.text.trim(),
      "fb_link": _fbPageLinkCtrl.text.trim(),
      "insta_link": _instaLinkCtrl.text.trim(),
      "tel_link": _teleLinkCtrl.text.trim(),
      "location": _localityCtrl.text.trim(),
      "place_id": _placeId ?? "",
      "latitude": _latitude ?? "",
      "longitude": _longitude ?? "",
      "pincode": _zipcodeCtrl.text.trim(),
      "state": stateVal ?? '',
      "account_holder_name": _accountHolderNameCtrl.text.trim(),
      "bank_name": _bankNameCtrl.text.trim(),
      "account_number": _accountNumberCtrl.text.trim(),
      "ifsc_code": _ifscCodeCtrl.text.trim(),
    };

    if (profileBase64 != null) {
      payload['profile_picture'] = profileBase64;
    } else if (stored?.profilePicture != null) {
      payload['profile_picture'] = stored!.profilePicture;
    }

    if (agencyBase64 != null) {
      payload['agency_logo'] = agencyBase64;
    } else if (stored?.agencyLogo != null) {
      payload['agency_logo'] = stored!.agencyLogo;
    }

    return payload;
  }

  // -------------------- Save --------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

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

      final bruaeProfileRequest = await _buildUpdatePayload(userId);

      final ok = await _p.updateAdminProfile(bruaeProfileRequest);
      if (ok == true) {
        await _p.fetchProfileForAdmin();
        await _hydrate();
        setState(() {
          _profileImage = null;
          _agencyLogo = null;
        });
      }
    } catch (e) {
      debugPrint('Failed $e');
      Get.snackbar('Error', 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
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
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        inputFormatters: [
          if (inputFormatters != null) ...inputFormatters,
        ],
        textCapitalization: textCapitalization,
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

          final prof = _p.adminProfileData.value;
          final name = prof?.fullName?.trim() ?? '';
          final displayName =
              name.isEmpty ? 'Admin' : name.split(RegExp(r'\s+')).first;

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
            initial: (displayName.isEmpty ? 'A' : displayName[0].toUpperCase()),
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
      body: Obx(() {
        final loading =
            _p.isLoading.value && _p.adminProfileData.value == null;
        if (loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final prof = _p.adminProfileData.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                // ======= Avatar + Agency Logo =======
                Center(
                  child: SizedBox(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // LEFT: Profile image
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _EditableCircle(
                                      size: 120,
                                      borderColor: AppColors.primaryColor,
                                      image: _profileImageProvider(),
                                      fallbackChild: Text(
                                        (() {
                                          final name =
                                              (prof?.fullName ?? 'A').trim();
                                          return name.isEmpty
                                              ? 'A'
                                              : name.characters.first
                                                  .toUpperCase();
                                        })(),
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onEdit: _showProfilePickerOptions,
                                      showEditBadge: true,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Profile ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 24),

                              // RIGHT: Agency logo
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _EditableCircle(
                                      size: 120,
                                      borderColor: AppColors.primaryColor,
                                      image: _agencyLogoProvider(),
                                      fallbackChild: const Icon(
                                        Icons.apartment_rounded,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                      onEdit: _showAgencyPickerOptions,
                                      showEditBadge: true,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Agency logo',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                // ======= Basic =======
                _sectionCard(
                  title: 'Basic:',
                  children: [
                    _textField('Full Name', _fullNameCtrl,
                        icon: Icons.person,
                        hint: 'Your name',
                        textCapitalization: TextCapitalization.words),
                    _textField(
                      'Phone Number',
                      _phoneCtrl,
                      icon: Icons.call,
                      hint: 'Phone',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          (v == null || !RegExp(r'^\d{10}$').hasMatch(v.trim()))
                              ? 'Enter 10-digit number'
                              : null,
                    ),
                    _textField(
                      'Email',
                      _emailCtrl,
                      icon: Icons.email,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'Required';
                        final ok = RegExp(
                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                            .hasMatch(s);
                        return ok ? null : 'Invalid email';
                      },
                    ),
                  ],
                ),

                // ======= Professional (example extra field) =======
                _sectionCard(
                  title: 'Professional:',
                  children: [
                    _textField(
                      'Agency Name',
                      _agencyNameCtrl,
                      icon: Icons.apartment_rounded,
                      hint: 'Agency / Institute name',
                      textCapitalization: TextCapitalization.words,
                    ),
                    _textField('Years in Bussiness', _bussinessInYearCtrl,
                        icon: Icons.work_history_rounded,
                        hint: 'e.g., 3',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
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

                // ======= Location =======
                _sectionCard(
                  title: 'Location:',
                  children: [
                    Obx(() {
                      final searching = _loc.isSearching.value;
                      final opts = _loc.suggestions;
                      return RawAutocomplete<String>(
                        focusNode: _localityFocusNode,
                        textEditingController: _localityCtrl,
                        optionsBuilder: (TextEditingValue tev) {
                          final q = tev.text.trim();
                          if (q.isEmpty) return const Iterable<String>.empty();
                          _loc.onQueryChanged(q);
                          return opts;
                        },
                        onSelected: (val) {
                          _localityCtrl.text = val;
                          _loc.onQueryChanged('');
                        },
                        fieldViewBuilder:
                            (context, textCtrl, focusNode, onFieldSubmitted) {
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
                        optionsViewBuilder: (context, onSelected, options) {
                          final list = options.toList();
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 280,
                                  maxWidth: MediaQuery.of(context).size.width - 40,
                                ),
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: list.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, i) {
                                    final item = list[i];
                                    return ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.location_on,
                                          size: 20),
                                      title: Text(item),
                                      onTap: () => onSelected(item),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _textField(
                            'Zipcode',
                            _zipcodeCtrl,
                            icon: Icons.pin_drop_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) =>
                                (v != null && v.isNotEmpty && v.length < 6)
                                    ? 'Invalid Zipcode'
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.only(top: 4, bottom: 6),
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _locLoading ? null : _getCurrentLocation,
                              icon: _locLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.my_location, size: 18),
                              label: Text(_locLoading ? '' : 'Use GPS'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ======= Professional (example extra field) =======
                _sectionCard(
                  title: 'Bank Account Details : ',
                  children: [
                    _textField(
                      'Account Holder Name',
                      _accountHolderNameCtrl,
                      icon: Icons.apartment_rounded,
                      hint: 'Account Holder Name',
                      textCapitalization: TextCapitalization.words,
                    ),
                    _textField(
                      'Bank Name',
                      _bankNameCtrl,
                      icon: Icons.apartment_rounded,
                      hint: 'Bank Name',
                      textCapitalization: TextCapitalization.words,
                    ),
                    _textField('Account Number', _accountNumberCtrl,
                        icon: Icons.work_history_rounded,
                        hint: 'Account Number',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                    _textField('IFSC Code', _ifscCodeCtrl,
                        icon: Icons.work_history_rounded,
                        hint: 'IFSC Code',
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                        ]),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
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

class _EditableCircle extends StatelessWidget {
  const _EditableCircle({
    required this.size,
    required this.borderColor,
    required this.onEdit,
    this.image,
    this.fallbackChild,
    this.showEditBadge = true,
  });

  final double size;
  final Color borderColor;
  final ImageProvider? image;
  final Widget? fallbackChild;
  final VoidCallback onEdit;
  final bool showEditBadge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Avatar circle with border
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onEdit,
                  child: CircleAvatar(
                    backgroundImage: image,
                    backgroundColor: Colors.grey.shade300,
                    child: image == null ? fallbackChild : null,
                  ),
                ),
              ),
            ),
          ),
          if (showEditBadge)
            Positioned(
              bottom: 4,
              right: 4,
              child: InkWell(
                onTap: onEdit,
                child: CircleAvatar(
                  radius: size < 80 ? 10 : 14,
                  backgroundColor: AppColors.primaryColor,
                  child: Icon(
                    Icons.camera_alt,
                    size: size < 80 ? 10 : 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
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
                          margin: const EdgeInsets.all(4),
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

/// Custom InputFormatter to force uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
