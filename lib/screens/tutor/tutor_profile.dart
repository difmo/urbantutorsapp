import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:urbantutorsapp/widgets/TutorDrawer.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/tutor/teacher_pending_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_response_modal.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urbantutorsapp/utils/geo_helper.dart';

import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/coins_student.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

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
  String? _lastSavedName;
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

  /// [v] if it is one of [options], otherwise null. Dropdowns throw when
  /// their value is not among their items, so server values must be checked.
  T? _oneOf<T>(T? v, List<T> options) =>
      (v != null && options.contains(v)) ? v : null;

  int? selectedFeeMin; // 100..1000
  int? selectedFeeMax; // 300..3000

  // Multi-select state
  final List<int> _selBoardIds = [];
  final List<int> _selClassIds = [];
  final List<int> _selSubjectIds = [];

  // Cached name lookups from tutor profile to prevent missing names / '#$id'
  final Map<int, String> _knownBoardNames = {};
  final Map<int, String> _knownClassNames = {};
  final Map<int, String> _knownSubjectNames = {};

  // Mode & State
  // Values accepted by the server (it rejects 'Any').
  static const _modes = <String>['Online', 'Offline', 'Both'];
  String? modeVal;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  String? _profileImageUrl; // from server

  // ID verification state
  static const _idTypes = ['Aadhar', 'Voter ID', 'Passport'];
  String? selectedIdType = 'Aadhar';
  XFile? _frontIdImage;
  String? _frontIdUrl;
  XFile? _backIdImage;
  String? _backIdUrl;

  // Location
  String? _latitude;
  String? _longitude;
  String? _placeId;
  bool _locLoading = false;

  // Misc
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Worker> _workers = [];

  @override
  void initState() {
    super.initState();

    final cachedMode = StorageService.cachedTeachingMode;
    if (cachedMode != null && cachedMode.trim().isNotEmpty) {
      modeVal = _normalizeMode(cachedMode);
    }

    final cachedIdType = StorageService.cachedIdType;
    if (cachedIdType != null && cachedIdType.trim().isNotEmpty) {
      selectedIdType = _normalizeIdType(cachedIdType) ?? 'Aadhar';
    }

    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());
    WidgetsBinding.instance.addPostFrameCallback((_) => _c.refreshAll());

    // fetch master data and profile
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _master.fetchMasterData();
      await _p.fetchProfileForTutor();
      if (mounted) await _hydrate();
    });

    // Hydrate whenever profile or master data changes
    _workers.add(everAll([_p.tutorprofileData, _master.masterData], (_) async {
      if (_master.masterData.value != null && mounted) {
        await _hydrate();
      }
    }));

    // React to LeadMetaController classes and subjects updates
    _workers.add(ever(_leadMeta.classes, (_) {
      if (mounted) setState(() {});
    }));
    _workers.add(ever(_leadMeta.subjects, (_) {
      if (mounted) setState(() {});
    }));
    _workers.add(ever(_leadMeta.isFetchingClasses, (_) {
      if (mounted) setState(() {});
    }));
    _workers.add(ever(_leadMeta.isFetchingSubjects, (_) {
      if (mounted) setState(() {});
    }));
  }

  @override
  void dispose() {
    for (final w in _workers) {
      w.dispose();
    }
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
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return 'https://urbantutors.pro/$cleanPath';
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
            if (item.boardId != null) {
              boards.add(item.boardId);
              if (item.boardName != null && item.boardName!.trim().isNotEmpty) {
                _knownBoardNames[item.boardId!] = item.boardName!.trim();
              }
            }
            if (item.classId != null) {
              classes.add(item.classId);
              if (item.className != null && item.className!.trim().isNotEmpty) {
                _knownClassNames[item.classId!] = item.className!.trim();
              }
            }
            if (item.subjectId != null) {
              subjects.add(item.subjectId);
              if (item.subjectName != null && item.subjectName!.trim().isNotEmpty) {
                _knownSubjectNames[item.subjectId!] = item.subjectName!.trim();
              }
            }
            continue;
          }

          if (item is Map<String, dynamic>) {
            final b = item['board_id'];
            final c = item['class_id'];
            final s = item['subject_id'];
            final bName = item['board_name'] ?? item['boardName'] ?? item['board_lable'];
            final cName = item['class_name'] ?? item['className'] ?? item['ClassName'];
            final sName = item['subject_name'] ?? item['subjectname'] ?? item['subjectName'] ?? item['name'];

            if (b != null) {
              final bId = b is int ? b : int.tryParse(b.toString());
              if (bId != null) {
                boards.add(bId);
                if (bName != null && bName.toString().trim().isNotEmpty) {
                  _knownBoardNames[bId] = bName.toString().trim();
                }
              }
            }
            if (c != null) {
              final cId = c is int ? c : int.tryParse(c.toString());
              if (cId != null) {
                classes.add(cId);
                if (cName != null && cName.toString().trim().isNotEmpty) {
                  _knownClassNames[cId] = cName.toString().trim();
                }
              }
            }
            if (s != null) {
              final sId = s is int ? s : int.tryParse(s.toString());
              if (sId != null) {
                subjects.add(sId);
                if (sName != null && sName.toString().trim().isNotEmpty) {
                  _knownSubjectNames[sId] = sName.toString().trim();
                }
              }
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
        await _leadMeta.loadClassesForBoards(_selBoardIds);
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
      selectedFeeMin = _oneOf(p.minAmount?.toInt() ?? 0, minOptions);
      selectedFeeMax = _oneOf(p.maxAmount?.toInt() ?? 0, maxOptionsBase);

      final serverName = (p.teacherName ?? '').toString().trim();
      final cached = StorageService.cachedUserName?.trim();
      bool isGeneric(String? s) =>
          s == null ||
          s.trim().isEmpty ||
          s.trim().toLowerCase() == 'user' ||
          s.trim().toLowerCase() == 'tutor' ||
          s.trim().toLowerCase() == 'urban user';

      final effectiveName = (_lastSavedName != null && !isGeneric(_lastSavedName))
          ? _lastSavedName!
          : (cached != null && !isGeneric(cached)
              ? cached
              : (!isGeneric(serverName) ? serverName : ''));

      if (effectiveName.isNotEmpty) {
        _nameCtrl.text = effectiveName;
      } else {
        StorageService.getUserName().then((stored) {
          if (stored != null && !isGeneric(stored) && mounted) {
            setState(() {
              _nameCtrl.text = stored.trim();
            });
          } else if (serverName.isNotEmpty && !isGeneric(serverName) && mounted) {
            setState(() {
              _nameCtrl.text = serverName;
            });
          }
        });
      }
      _emailCtrl.text = (p.email ?? '').toString().trim();
      _localityCtrl.text = (p.location ?? '').toString().trim();
      _expCtrl.text = (p.experienceYears?.toString() ?? '').toString();
      _qualificationCtrl.text = (p.qualification ?? '').toString();
      _fbPageLinkCtrl.text = (p.fbLink ?? '').toString();
      _instaLinkCtrl.text = (p.instaLink ?? '').toString();
      _teleLinkCtrl.text = (p.whLink ?? '').toString();
      _zipcodeCtrl.text = (p.pincode ?? '').toString();

      String? rawMode = (p.mode ?? '').toString().trim();
      final cachedMode = StorageService.cachedTeachingMode;
      final modeToUse = rawMode.isNotEmpty
          ? rawMode
          : (cachedMode != null && cachedMode.trim().isNotEmpty
              ? cachedMode
              : (modeVal ?? 'Online'));
      final normalizedMode = _normalizeMode(modeToUse);

      _profileImageUrl = _resolveImageUrl(p.profilePicture);
      _frontIdUrl = _resolveImageUrl(p.frontId);
      _backIdUrl = _resolveImageUrl(p.frontBack);
      final cachedIdType = StorageService.cachedIdType;
      selectedIdType = _normalizeIdType(p.idType) ??
          (cachedIdType != null && cachedIdType.isNotEmpty
              ? _normalizeIdType(cachedIdType)
              : 'Aadhar') ??
          'Aadhar';

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

  Future<void> _pickImage(ImageSource source, {String type = 'profile'}) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 70,
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        if (type == 'profile') _profileImage = picked;
        if (type == 'front') _frontIdImage = picked;
        if (type == 'back') _backIdImage = picked;
      });
    }
    if (mounted && Navigator.canPop(context)) Navigator.pop(context);
  }

  void _showPickerOptions({String type = 'profile'}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () => _pickImage(ImageSource.camera, type: type)),
            ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () => _pickImage(ImageSource.gallery, type: type)),
            if ((type == 'profile' && _profileImage != null) ||
                (type == 'front' &&
                    (_frontIdImage != null ||
                        (_frontIdUrl != null && _frontIdUrl!.isNotEmpty))) ||
                (type == 'back' &&
                    (_backIdImage != null ||
                        (_backIdUrl != null && _backIdUrl!.isNotEmpty))))
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Remove"),
                onTap: () {
                  setState(() {
                    if (type == 'profile') _profileImage = null;
                    if (type == 'front') {
                      _frontIdImage = null;
                      _frontIdUrl = null;
                    }
                    if (type == 'back') {
                      _backIdImage = null;
                      _backIdUrl = null;
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

      final geo = await GeoHelper.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final postalCode = geo?.postalCode;

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
    if ((modeVal ?? '').isEmpty) {
      Get.snackbar('Teaching mode', 'Please select a teaching mode.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // Saving sends a verified tutor's profile back for admin verification.
    if (_p.tutorprofileData.value?.profileStatus == 2) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Send for re-verification?'),
          content: const Text(
              'After you save, the admin team will verify your updated profile '
              'again. Until it is approved you will see the verification screen.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('CANCEL')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('SAVE')),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
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
        Get.snackbar('Error', 'No User ID Found',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        return;
      }

      final profileBase64 = await _fileToBase64(_profileImage);
      final frontBase64 = await _fileToBase64(_frontIdImage);
      final backBase64 = await _fileToBase64(_backIdImage);
      final storedFront = _p.tutorprofileData.value?.frontId;
      final storedBack = _p.tutorprofileData.value?.frontBack;
      final effectiveIdType = (selectedIdType != null && selectedIdType!.trim().isNotEmpty)
          ? selectedIdType!.trim()
          : (_normalizeIdType(_p.tutorprofileData.value?.idType) ??
              StorageService.cachedIdType ??
              'Aadhar');
      final apiIdType = _toApiIdType(effectiveIdType);

      final boardIds = _uniqueInts(_selBoardIds);
      final classIds = _uniqueInts(_selClassIds);
      final subjectIds = _uniqueInts(_selSubjectIds);

      final experienceYears = int.tryParse(_expCtrl.text.trim()) ?? 0;

      final newName = _nameCtrl.text.trim();
      _lastSavedName = newName;
      final payload = {
        "user_id": userId,
        "id": userId,
        "teacher_id": userId,
        "teacher_name": newName,
        "teacherName": newName,
        "name": newName,
        "full_name": newName,
        "fullName": newName,
        "user_name": newName,
        "userName": newName,
        "tutor_name": newName,
        "email": _emailCtrl.text.trim(),
        "location": _localityCtrl.text.trim(),
        "pincode": _zipcodeCtrl.text.trim(),
        "qualification": _qualificationCtrl.text.trim(),
        "min_amount": selectedFeeMin ?? 0,
        "max_amount": selectedFeeMax ?? 0,
        "mode": modeVal ?? '',
        "teaching_mode": modeVal ?? '',
        "teachingMode": modeVal ?? '',
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
        "idType": apiIdType,
        "idtype": apiIdType,
        "id_type": apiIdType,
      };
      // New photo → base64; otherwise resend the stored path (the server
      // keeps it). A tutor without any photo sends none.
      final storedPicture = _p.tutorprofileData.value?.profilePicture;
      if (profileBase64 != null) {
        payload["profile_picture"] = profileBase64;
      } else if (storedPicture != null && storedPicture.isNotEmpty) {
        payload["profile_picture"] = storedPicture;
      }

      if (frontBase64 != null) {
        payload["frontid"] = frontBase64;
        payload["front_id"] = frontBase64;
      } else if (_frontIdUrl != null &&
          _frontIdUrl!.isNotEmpty &&
          storedFront != null &&
          storedFront.isNotEmpty) {
        payload["frontid"] = storedFront;
        payload["front_id"] = storedFront;
      }

      if (backBase64 != null) {
        payload["backid"] = backBase64;
        payload["frontback"] = backBase64;
        payload["back_id"] = backBase64;
      } else if (_backIdUrl != null &&
          _backIdUrl!.isNotEmpty &&
          storedBack != null &&
          storedBack.isNotEmpty) {
        payload["backid"] = storedBack;
        payload["frontback"] = storedBack;
        payload["back_id"] = storedBack;
      }

      final ok = await _p.updateTutorProfile(payload);
      // The controller already shows the server's success/failure message.
      if (ok == true) {
        if (newName.isNotEmpty) {
          await StorageService.saveUserName(newName);
        }
        if ((modeVal ?? '').isNotEmpty) {
          await StorageService.saveTeachingMode(modeVal!);
        }
        if (apiIdType.isNotEmpty) {
          await StorageService.saveIdType(apiIdType);
        }
        await _p.fetchProfileForTutor();
        if (_p.tutorprofileData.value?.profileStatus == 1) {
          Get.offAll(() => const TeacherPendingScreen());
          return;
        }
        await _hydrate();
        if (mounted) {
          setState(() {
            _profileImage = null;
            _frontIdImage = null;
            _backIdImage = null;
          });
        }
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
      endDrawer: Tutordrawer(),
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
                      _buildIdentitySection(primary),
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
                const Flexible(
                  child: Text(
                    "Edit Profile",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
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
                  color: Colors.black.withValues(alpha: 0.1),
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
            color: Colors.black.withValues(alpha: 0.05),
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
          fallbackNames: _knownBoardNames,
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
                await _leadMeta.loadClassesForBoards(_selBoardIds);
              }
            }
          },
        ),
        const SizedBox(height: 12),
        _buildMultiSelectTile(
          label: 'Classes',
          selectedIds: _selClassIds,
          options: _classOptions(),
          fallbackNames: _knownClassNames,
          onTap: () async {
            if (_selBoardIds.isEmpty) {
              Get.snackbar('Notice', 'Please select a Board first');
              return;
            }
            if (_leadMeta.classes.isEmpty) {
              await _leadMeta.loadClassesForBoards(_selBoardIds);
            }
            if (!mounted) return;
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
          fallbackNames: _knownSubjectNames,
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
              .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(m == 'Both' ? 'Both (Online & Offline)' : m),
                  ))
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
                color: AppColors.primaryColor.withValues(alpha: 0.1),
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

  Widget _buildIdentitySection(Color primary) {
    return _buildSectionCard(
      title: 'Identity Verification',
      children: [
        _buildDropdown<String>(
          label: 'ID Type',
          value: selectedIdType ?? 'Aadhar',
          items: _idTypes
              .map((id) => DropdownMenuItem(value: id, child: Text(id)))
              .toList(),
          onChanged: (val) => setState(() => selectedIdType = val ?? 'Aadhar'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _idUploadBox(
                "Front ID",
                _frontIdImage,
                _frontIdUrl,
                "front",
                primary: primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _idUploadBox(
                "Back ID",
                _backIdImage,
                _backIdUrl,
                "back",
                primary: primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _idUploadBox(
    String label,
    XFile? file,
    String? networkUrl,
    String type, {
    required Color primary,
  }) {
    final hasFile = file != null;
    final hasNetwork = !hasFile && networkUrl != null && networkUrl.isNotEmpty;
    final hasImage = hasFile || hasNetwork;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showPickerOptions(type: type),
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: hasImage ? Colors.transparent : Colors.grey.shade50,
              border: Border.all(
                color: hasImage
                    ? primary.withValues(alpha: 0.3)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasFile)
                        Image.file(
                          File(file.path),
                          fit: BoxFit.cover,
                        )
                      else
                        Image.network(
                          networkUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image_outlined,
                                    color: Colors.grey.shade400, size: 36),
                                const SizedBox(height: 4),
                                Text('Image not available',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 38,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
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
    TextCapitalization? textCapitalization,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      textCapitalization: textCapitalization ??
          (keyboardType == TextInputType.phone ||
                  keyboardType == TextInputType.number ||
                  keyboardType == TextInputType.emailAddress
              ? TextCapitalization.none
              : TextCapitalization.words),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            icon != null ? Icon(icon, color: Colors.grey.shade600) : null,
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.all(12), child: suffix)
            : null,
        filled: true,
        fillColor: Colors.white,
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
    final hasValue = value != null && items.any((it) => it.value == value);
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        canvasColor: Colors.white,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        colorScheme: theme.colorScheme.copyWith(
          surface: Colors.white,
          surfaceContainer: Colors.white,
          surfaceContainerHighest: Colors.white,
          surfaceContainerLow: Colors.white,
          surfaceContainerLowest: Colors.white,
        ),
      ),
      child: DropdownButtonFormField<T>(
        key: ValueKey('${label}_$value'),
        value: hasValue ? value : null,
        items: items,
        onChanged: onChanged,
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
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
      ),
    );
  }

  Widget _buildMultiSelectTile({
    required String label,
    required List<int> selectedIds,
    required List<OptionInt> options,
    required VoidCallback onTap,
    Map<int, String>? fallbackNames,
  }) {
    final selectedNames = _labelsFor(selectedIds, options, fallbackNames: fallbackNames);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                            color: AppColors.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.primaryColor.withValues(alpha: 0.3)),
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

  String _normalizeMode(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      final cached = StorageService.cachedTeachingMode;
      if (cached != null && cached.trim().isNotEmpty) {
        return _normalizeMode(cached);
      }
      return 'Online';
    }
    final low = raw.trim().toLowerCase();
    if ((low.contains('online') && low.contains('offline')) ||
        low == 'both' ||
        low == 'any' ||
        low.contains('both')) {
      return 'Both';
    }
    if (low.contains('offline')) {
      return 'Offline';
    }
    if (low.contains('online')) {
      return 'Online';
    }
    return 'Online';
  }

  String? _normalizeIdType(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final clean = raw.trim().toLowerCase();
    if (clean == 'voterid' || clean == 'voter id' || clean == 'voter') {
      return 'Voter ID';
    }
    if (clean == 'aadhar' || clean == 'aadhaar') return 'Aadhar';
    if (clean == 'passport') return 'Passport';
    return _oneOf(raw.trim(), _idTypes);
  }

  String _toApiIdType(String? idType) {
    if (idType == null || idType.trim().isEmpty) return 'Aadhar';
    final clean = idType.trim().toLowerCase();
    if (clean == 'voter id' || clean == 'voterid' || clean == 'voter') {
      return 'Voter ID';
    }
    if (clean == 'aadhar' || clean == 'aadhaar') return 'Aadhar';
    if (clean == 'passport') return 'Passport';
    return idType.trim();
  }

  List<OptionInt> _boardOptions() {
    final map = <int, OptionInt>{};
    for (final b in _master.masterData.value?.data.boardLead ?? []) {
      final bid = (b.boardId is int)
          ? b.boardId as int
          : int.tryParse('${b.boardId}') ?? 0;
      if (bid > 0) {
        map[bid] = OptionInt(bid, b.boardLabel ?? '');
      }
    }
    for (final entry in _knownBoardNames.entries) {
      map.putIfAbsent(entry.key, () => OptionInt(entry.key, entry.value));
    }
    return map.values.toList();
  }

  List<OptionInt> _classOptions() {
    final map = <int, OptionInt>{};
    for (final c in _leadMeta.classes) {
      map[c.classId] = OptionInt(c.classId, c.className);
    }
    for (final entry in _knownClassNames.entries) {
      map.putIfAbsent(entry.key, () => OptionInt(entry.key, entry.value));
    }
    return map.values.toList();
  }

  List<OptionInt> _subjectOptions() {
    final map = <int, OptionInt>{};
    for (final s in _leadMeta.subjects) {
      map[s.subjectId] = OptionInt(s.subjectId, s.subjectName);
    }
    for (final entry in _knownSubjectNames.entries) {
      map.putIfAbsent(entry.key, () => OptionInt(entry.key, entry.value));
    }
    return map.values.toList();
  }

  List<String> _labelsFor(List<int> selectedIds, List<OptionInt> all,
      {Map<int, String>? fallbackNames}) {
    final map = {for (final o in all) o.id: o.label};
    return selectedIds
        .map((id) {
          final label = map[id] ?? fallbackNames?[id];
          if (label != null && label.trim().isNotEmpty) return label.trim();
          return '';
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // -------------------- Share Logic --------------------

  Future<String> _publicProfileUrl() async {
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
