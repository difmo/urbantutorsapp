// <keep your existing imports>
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urbantutorsapp/utils/geo_helper.dart';

import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_response_modal.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/tutor/teacher_pending_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_dashboard.dart';
import 'package:urbantutorsapp/screens/welcome/welcome_screen.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/app_log.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class TutorProfileFormScreen extends StatefulWidget {
  const TutorProfileFormScreen({super.key});
  @override
  State<TutorProfileFormScreen> createState() => _TutorProfileFormScreenState();
}

class _TutorProfileFormScreenState extends State<TutorProfileFormScreen> {
  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController localityController = TextEditingController();

  final _qualificationCtrl = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  // Controllers (single, consistent set)
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

  // Multi-select state
  final List<int> _selBoardIds = [];
  final List<int> _selClassIds = [];
  final List<int> _selSubjectIds = [];

  // Other form bits
  String? selectedState;
  String? selectedIdType = 'Aadhar';
  String? selectedIdMode;
  String? selectedIdExperienceInYears;
  String? _profileImageUrl; // from server
  String? _frontIdUrl; // from server
  String? _backIdUrl; // from server
  // Location data
  String? _latitude;
  String? _longitude;
  String? _placeId;

  int? selectedFeeMin; // 100..1000
  int? selectedFeeMax; // 300..3000

  final List<int> minOptions = [for (int v = 100; v <= 1000; v += 100) v];
  final List<int> maxOptionsBase = [for (int v = 300; v <= 3000; v += 100) v];

  /// [v] if it is one of [options], otherwise null. Dropdowns throw when
  /// their value is not among their items, so server values must be checked.
  T? _oneOf<T>(T? v, List<T> options) =>
      (v != null && options.contains(v)) ? v : null;

  String? _normalizeIdType(String? raw) {
    if (raw == null) return null;
    final clean = raw.trim().toLowerCase();
    if (clean == 'voterid' || clean == 'voter id' || clean == 'voter') {
      return 'Voter ID';
    }
    if (clean == 'aadhar') return 'Aadhar';
    if (clean == 'passport') return 'Passport';
    return _oneOf(raw, const ['Aadhar', 'Voter ID', 'Passport']);
  }

  String _toApiIdType(String? idType) {
    if (idType == null || idType.isEmpty) return 'Aadhar';
    final clean = idType.trim().toLowerCase();
    if (clean == 'voter id' || clean == 'voterid' || clean == 'voter') {
      return 'Voter ID';
    }
    if (clean == 'aadhar' || clean == 'aadhaar') return 'Aadhar';
    if (clean == 'passport') return 'Passport';
    return idType.trim();
  }
  // Values accepted by the server (it rejects 'Any').
  static const _modes = <String>['Online', 'Offline', 'Both'];
  String? modeVal;

  // Cached name lookups to prevent missing class/subject names
  final Map<int, String> _knownBoardNames = {};
  final Map<int, String> _knownClassNames = {};
  final Map<int, String> _knownSubjectNames = {};

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

  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  XFile? _frontIdImage;
  XFile? _backIdImage;

  bool _overlayLoading = false;

  // Validation error flags for multi-selects / id images
  bool _boardError = false;
  bool _classError = false;
  bool _subjectError = false;
  bool _profileImageError = false;
  bool _frontIdError = false;
  bool _backIdError = false;

  // GetX workers (dispose later)
  late final Worker _wTutorData;
  late final Worker _wStudentData;
  late final Worker _wRouteOnce;
  late final Worker _wMasterData;
  late final Worker _wIsFetchingClasses;
  late final Worker _wIsFetchingSubjects;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // initial fetches
    _p.fetchProfileForTutor();
    _master.fetchMasterData();

    // react to tutor profile changes
    _wTutorData = ever(_p.tutorprofileData, (teacher) async {
      AppLog.i('[UI] tutorprofileData changed');
      if (!mounted || teacher == null) return;
      nameController.text = teacher.teacherName ?? '';
      emailController.text = teacher.email ?? '';
      localityController.text = teacher.location ?? '';
      pinCodeController.text = teacher.pincode ?? '';

      priceController.text = teacher.minAmount?.toString() ?? '';
      selectedFeeMin = _oneOf(teacher.minAmount?.toInt() ?? 300, minOptions);
      selectedFeeMax = _oneOf(teacher.maxAmount?.toInt() ?? 500, maxOptionsBase);
      selectedIdType = _normalizeIdType(teacher.idType) ?? selectedIdType ?? 'Aadhar';
      // Normalize mode cleanly
      final serverMode = (teacher.mode ?? '').trim();
      final cachedMode = StorageService.cachedTeachingMode;
      final modeToUse = serverMode.isNotEmpty
          ? serverMode
          : (cachedMode != null && cachedMode.trim().isNotEmpty
              ? cachedMode
              : (selectedIdMode ?? 'Online'));
      selectedIdMode = _normalizeMode(modeToUse);

      setState(() {});
    });

    // hydrate from student profile (legacy fields, etc.)
    _wStudentData = ever(_p.tutorprofileData, (_) async => await _hydrate());

    // single routing decision when tutorprofileData first arrives
    _wRouteOnce = once(_p.tutorprofileData, (student) {
      if (!mounted || student == null) return;
      final status = student.profileStatus;
      if (status == 0) {
        // stay here (incomplete)
      } else if (status == 1) {
        Get.offAll(() => const TeacherPendingScreen());
      } else if (status == 2) {
        Get.offAll(() => const TutorDashboard());
      } else {
        Get.offAll(() => const WelcomeScreen());
      }
    });

    // reflect master data changes
    _wMasterData = ever(_master.masterData, (val) {
      final boards = val?.data.boardLead ?? [];
      AppLog.i('[UI] masterData updated, boards=${boards.length}');
      if (!mounted) return;
      setState(() {});
    });

    _wIsFetchingClasses = ever(_leadMeta.isFetchingClasses, (_) {
      if (mounted) setState(() {});
    });
    _wIsFetchingSubjects = ever(_leadMeta.isFetchingSubjects, (_) {
      if (mounted) setState(() {});
    });
  }

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
    var lists = _listFromTeachingDetails(p?.teachingDetails);
    final cachedTd = await StorageService.getTeachingDetails();
    if (cachedTd != null && cachedTd.isNotEmpty) {
      final cachedLists = _listFromTeachingDetails(cachedTd);
      lists['board_id'] = {...(lists['board_id'] ?? []), ...(cachedLists['board_id'] ?? [])}.toList();
      lists['class_id'] = {...(lists['class_id'] ?? []), ...(cachedLists['class_id'] ?? [])}.toList();
      lists['subject_id'] = {...(lists['subject_id'] ?? []), ...(cachedLists['subject_id'] ?? [])}.toList();
    }
    final cachedNames = await StorageService.getKnownMetaNames();
    _knownBoardNames.addAll(cachedNames['boards'] ?? {});
    _knownClassNames.addAll(cachedNames['classes'] ?? {});
    _knownSubjectNames.addAll(cachedNames['subjects'] ?? {});

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
        for (final c in _leadMeta.classes) {
          if (c.className.isNotEmpty) {
            _knownClassNames[c.classId] = c.className;
          }
        }
      } catch (_) {}
    }

    if (_selBoardIds.isNotEmpty && _selClassIds.isNotEmpty) {
      try {
        await _leadMeta.loadSubjects1(
            selClassIds: _selClassIds, selBoardIds: _selBoardIds);
        for (final s in _leadMeta.subjects) {
          if (s.subjectName.isNotEmpty) {
            _knownSubjectNames[s.subjectId] = s.subjectName;
          }
        }
      } catch (_) {}
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (p != null) {
        selectedFeeMin = _oneOf(p.minAmount?.toInt() ?? 0, minOptions);
        selectedFeeMax = _oneOf(p.maxAmount?.toInt() ?? 0, maxOptionsBase);

        nameController.text = (p.teacherName ?? '').toString().trim();
        emailController.text = (p.email ?? '').toString().trim();
        localityController.text = (p.location ?? '').toString().trim();
        experienceController.text =
            (p.experienceYears?.toString() ?? '').toString();
        _qualificationCtrl.text = (p.remark ?? '').toString();
        String? rawMode = (p.mode ?? '').toString().trim();
        final cachedMode = StorageService.cachedTeachingMode;
        final modeToUse = rawMode.isNotEmpty
            ? rawMode
            : (cachedMode != null && cachedMode.trim().isNotEmpty
                ? cachedMode
                : (selectedIdMode ?? 'Online'));
        final normalizedMode = _normalizeMode(modeToUse);

        _profileImageUrl = _resolveImageUrl(p.profilePicture);
        _frontIdUrl = _resolveImageUrl(p.frontId);
        _backIdUrl = _resolveImageUrl(p.frontBack);
        final rawIdType = p.idType;
        if (rawIdType != null && rawIdType.isNotEmpty) {
          selectedIdType = _normalizeIdType(rawIdType) ?? selectedIdType ?? 'Aadhar';
        }
        selectedIdMode = normalizedMode;
      }
      setState(() {});
    });
  }

  // Capitalize helpers
  String _capitalizeEach(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  @override
  void dispose() {
    // Dispose workers
    _wTutorData.dispose();
    _wStudentData.dispose();
    _wRouteOnce.dispose();
    _wMasterData.dispose();
    _wIsFetchingClasses.dispose();
    _wIsFetchingSubjects.dispose();

    // Dispose controllers
    nameController.dispose();
    emailController.dispose();
    localityController.dispose();
    experienceController.dispose();
    pinCodeController.dispose();
    super.dispose();
  }

  // === Helpers ===
  Future<void> _pickImage(ImageSource source, String type) async {
    final picked = await _picker.pickImage(
      source: source,
      // ID photos are sent as base64 text; keep them small enough for the
      // server's upload limits.
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 70,
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        if (type == "profile") {
          _profileImage = picked;
          _profileImageError = false;
        }
        if (type == "front") {
          _frontIdImage = picked;
          _frontIdError = false;
        }
        if (type == "back") {
          _backIdImage = picked;
          _backIdError = false;
        }
      });
    }
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showPickerOptions(String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () => _pickImage(ImageSource.camera, type),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () => _pickImage(ImageSource.gallery, type),
            ),
            if ((type == "front" &&
                    (_frontIdImage != null ||
                        (_frontIdUrl != null && _frontIdUrl!.isNotEmpty))) ||
                (type == "back" &&
                    (_backIdImage != null ||
                        (_backIdUrl != null && _backIdUrl!.isNotEmpty))) ||
                (type == "profile" &&
                    (_profileImage != null ||
                        (_profileImageUrl != null &&
                            _profileImageUrl!.isNotEmpty))))
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Remove"),
                onTap: () {
                  setState(() {
                    if (type == "front") {
                      _frontIdImage = null;
                      _frontIdUrl = null;
                    }
                    if (type == "back") {
                      _backIdImage = null;
                      _backIdUrl = null;
                    }
                    if (type == "profile") {
                      _profileImage = null;
                      _profileImageUrl = null;
                    }
                  });
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<String?> _fileToBase64(XFile? file) async {
    if (file == null) return null;
    final bytes = await File(file.path).readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    return "data:image/$ext;base64,${base64Encode(bytes)}";
    // If your backend needs raw base64 only, return base64Encode(bytes)
  }

  void _refreshTutorProfile() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TeacherPendingScreen()),
      (route) => false,
    );
    _p.fetchProfileForTutor();
  }

  int? _expToInt(String? v) {
    if (v == null) return null;
    if (v.toLowerCase() == 'fresher') return 0;
    if (v == '10+') return 10;
    return int.tryParse(v);
  }

  // Simple email validator
  bool _isValidEmail(String email) {
    final re = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$");
    return re.hasMatch(email);
  }

  // Get current location
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

      // Show loading indicator
      if (mounted) setState(() => _overlayLoading = true);

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates with resilient HTTP fallback
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
            pinCodeController.text = postalCode;
          }
          _overlayLoading = false;
        });
        Get.snackbar('Success', 'Location retrieved successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100);
      }
    } catch (e) {
      if (mounted) setState(() => _overlayLoading = false);
      Get.snackbar('Error', 'Failed to get location: $e');
    }
  }

  Future<void> onSavePressed() async {
    // Reset image/multi-select error flags before validating
    setState(() {
      _boardError = false;
      _classError = false;
      _subjectError = false;
      _frontIdError = false;
      _backIdError = false;
    });

    // Validate form fields
    final formValid = _formKey.currentState?.validate() ?? false;

    // Validate multi-selects
    final hasBoard = _selBoardIds.isNotEmpty;
    final hasClass = _selClassIds.isNotEmpty;
    final hasSubject = _selSubjectIds.isNotEmpty;

    bool multiSelectsOk = true;
    if (!hasBoard) {
      _boardError = true;
      multiSelectsOk = false;
    }
    if (!hasClass) {
      _classError = true;
      multiSelectsOk = false;
    }
    if (!hasSubject) {
      _subjectError = true;
      multiSelectsOk = false;
    }

    // Validate profile image
    final profileImageOk = _profileImage != null ||
        (_profileImageUrl != null && _profileImageUrl!.isNotEmpty);
    if (!profileImageOk) _profileImageError = true;

    // Validate ID images
    final frontOk = _frontIdImage != null ||
        (_frontIdUrl != null && _frontIdUrl!.isNotEmpty);
    if (!frontOk) _frontIdError = true;

    final backOk = _backIdImage != null ||
        (_backIdUrl != null && _backIdUrl!.isNotEmpty);
    if (!backOk) _backIdError = true;

    setState(() {}); // update UI for errors

    if (!formValid ||
        !multiSelectsOk ||
        !profileImageOk ||
        !frontOk ||
        !backOk) {
      Get.snackbar('Error', 'Please fill all required fields.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _overlayLoading = true);
    try {
      final uidStr = await StorageService.getUserId();
      final userId = int.tryParse('$uidStr') ?? 0;
      print(userId);
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
      final storedPicture = _p.tutorprofileData.value?.profilePicture;
      final storedFront = _p.tutorprofileData.value?.frontId;
      final storedBack = _p.tutorprofileData.value?.frontBack;

      final effProfile = (profileBase64 != null && profileBase64.isNotEmpty)
          ? profileBase64
          : (storedPicture ?? '');
      final effFront = (frontBase64 != null && frontBase64.isNotEmpty)
          ? frontBase64
          : (storedFront ?? '');
      final effBack = (backBase64 != null && backBase64.isNotEmpty)
          ? backBase64
          : (storedBack ?? '');

      final boardIds = _uniqueInts(_selBoardIds);
      final classIds = _uniqueInts(_selClassIds);
      final subjectIds = _uniqueInts(_selSubjectIds);

      // Build subject-to-class and subject-to-board mapping
      final Map<int, Set<int>> subjectToClasses = {};
      final Map<int, Set<int>> subjectToBoards = {};

      for (final s in _leadMeta.subjects) {
        if (s.subjectId > 0) {
          if (s.classId != null && s.classId! > 0) {
            subjectToClasses.putIfAbsent(s.subjectId, () => {}).add(s.classId!);
          }
          if (s.boardId != null && s.boardId! > 0) {
            subjectToBoards.putIfAbsent(s.subjectId, () => {}).add(s.boardId!);
          }
        }
      }

      final existingDetails = [
        ...(_p.tutorprofileData.value?.teachingDetails ?? []),
        ...((await StorageService.getTeachingDetails()) ?? []),
      ];
      for (final td in existingDetails) {
        int? sId, cId, bId;
        if (td is TeachingDetails) {
          sId = td.subjectId;
          cId = td.classId;
          bId = td.boardId;
        } else if (td is Map) {
          sId = td['subject_id'] is int ? td['subject_id'] : int.tryParse(td['subject_id']?.toString() ?? '');
          cId = td['class_id'] is int ? td['class_id'] : int.tryParse(td['class_id']?.toString() ?? '');
          bId = td['board_id'] is int ? td['board_id'] : int.tryParse(td['board_id']?.toString() ?? '');
        }
        if (sId != null && sId > 0) {
          if (cId != null && cId > 0) {
            subjectToClasses.putIfAbsent(sId, () => {}).add(cId);
          }
          if (bId != null && bId > 0) {
            subjectToBoards.putIfAbsent(sId, () => {}).add(bId);
          }
        }
      }

      final List<String> boardNamesList = boardIds.map((b) {
        return (_knownBoardNames[b]?.isNotEmpty == true)
            ? _knownBoardNames[b]!
            : (_master.masterData.value?.data.boardLead.firstWhereOrNull((e) => e.boardId == b)?.boardLabel ?? '');
      }).whereType<String>().where((s) => s.isNotEmpty).toList();

      final List<String> classNamesList = classIds.map((c) {
        return (_knownClassNames[c]?.isNotEmpty == true)
            ? _knownClassNames[c]!
            : (_leadMeta.classes.firstWhereOrNull((e) => e.classId == c)?.className ?? '');
      }).whereType<String>().where((s) => s.isNotEmpty).toList();

      final List<String> subjectNamesList = subjectIds.map((s) {
        final name = (_knownSubjectNames[s]?.isNotEmpty == true)
            ? _knownSubjectNames[s]!
            : (_leadMeta.subjects.firstWhereOrNull((e) => e.subjectId == s)?.subjectName ?? '');
        final clean = name.split(' (').first.trim();
        return clean.isNotEmpty ? clean : name.trim();
      }).where((s) => s.isNotEmpty).toList();

      final boardNamesJoined = boardNamesList.join(', ');
      final classNamesJoined = classNamesList.join(', ');
      final subjectNamesJoined = subjectNamesList.join(', ');
      final boardIdsStr = boardIds.join(',');
      final classIdsStr = classIds.join(',');
      final subjectIdsStr = subjectIds.join(',');

      final List<Map<String, dynamic>> teachingDetailsPayload = [];
      final Set<String> seenDetailCombos = {};

      void addDetail(int bId, int cId, int? sId) {
        final key = '$bId-$cId-${sId ?? 0}';
        if (seenDetailCombos.contains(key)) return;
        seenDetailCombos.add(key);

        final bName = (_knownBoardNames[bId]?.isNotEmpty == true)
            ? _knownBoardNames[bId]!
            : (_master.masterData.value?.data.boardLead.firstWhereOrNull((e) => e.boardId == bId)?.boardLabel ?? '');
        final cName = (_knownClassNames[cId]?.isNotEmpty == true)
            ? _knownClassNames[cId]!
            : (_leadMeta.classes.firstWhereOrNull((e) => e.classId == cId)?.className ?? '');
        String sName = (sId != null && sId > 0)
            ? (_leadMeta.subjects.firstWhereOrNull((e) => e.subjectId == sId)?.subjectName ??
                ((_knownSubjectNames[sId]?.isNotEmpty == true) ? _knownSubjectNames[sId]! : ''))
            : '';
        if (sName.contains(' (')) {
          sName = sName.split(' (').first.trim();
        }

        final Map<String, dynamic> item = {
          "user_id": uidStr,
          "teacher_id": uidStr,
          "tutor_id": uidStr,
          "board_id": bId,
          "boardId": bId,
          "board_name": bName,
          "boardName": bName,
          "board_label": bName,
          "class_id": cId,
          "classId": cId,
          "course_id": cId,
          "courseId": cId,
          "class_name": cName,
          "className": cName,
          "course_name": cName,
          "courseName": cName,
          "status": 1,
          "is_verify": 1,
        };
        if (sId != null && sId > 0) {
          item["subject_id"] = sId;
          item["subjectId"] = sId;
          item["subject_name"] = sName;
          item["subjectName"] = sName;
          item["subjectname"] = sName;
          item["name"] = sName;
          item["all_subjects"] = subjectNamesJoined;
          item["subject_names"] = subjectNamesList;
          item["subject_ids"] = subjectIdsStr;
          item["subjects"] = subjectNamesJoined;
        }
        teachingDetailsPayload.add(item);
      }

      final targetBoards = boardIds.isNotEmpty ? boardIds : [1];
      final targetClasses = classIds.isNotEmpty ? classIds : [0];

      if (subjectIds.isNotEmpty) {
        for (final bId in targetBoards) {
          for (final sId in subjectIds) {
            // Find which class this subject belongs to
            final validClasses = (subjectToClasses[sId]?.isNotEmpty == true)
                ? subjectToClasses[sId]!.where((c) => targetClasses.contains(c)).toList()
                : <int>[];

            final classesToAssign = validClasses.isNotEmpty
                ? validClasses
                : targetClasses;

            for (final cId in classesToAssign) {
              addDetail(bId, cId, sId);
            }
          }

          // Ensure each targetClass has at least one entry
          for (final cId in targetClasses) {
            final hasEntry = teachingDetailsPayload.any(
                (td) => td['board_id'] == bId && td['class_id'] == cId);
            if (!hasEntry) {
              addDetail(bId, cId, null);
            }
          }
        }
      } else {
        for (final bId in targetBoards) {
          for (final cId in targetClasses) {
            addDetail(bId, cId, null);
          }
        }
      }



      final newName = nameController.text.trim();
      final apiIdType = _toApiIdType(selectedIdType);

      final mobileNum = (_p.tutorprofileData.value?.mobile?.isNotEmpty == true)
          ? _p.tutorprofileData.value!.mobile!
          : (await StorageService.getUserPhoneNumber()) ?? '';
      final stateVal = (selectedState != null && selectedState!.isNotEmpty)
          ? selectedState!
          : ((_p.tutorprofileData.value?.state?.isNotEmpty == true)
              ? _p.tutorprofileData.value!.state!
              : 'Delhi');
      final remarkVal = (_p.tutorprofileData.value?.remark?.isNotEmpty == true)
          ? _p.tutorprofileData.value!.remark!
          : 'Certified Tutor';
      final expYears = _expToInt(selectedIdExperienceInYears);
      final isAlreadyVerified = _p.tutorprofileData.value?.profileStatus == 2;
      final targetProfileStatus = isAlreadyVerified ? 2 : 1;
      final targetVerifyStatus = isAlreadyVerified ? 1 : 0;

      final request = {
        "user_id": uidStr,
        "id": uidStr,
        "teacher_id": uidStr,
        "teacher_user_id": uidStr,
        "teacher_name": newName,
        "teacherName": newName,
        "name": newName,
        "full_name": newName,
        "fullName": newName,
        "user_name": newName,
        "userName": newName,
        "tutor_name": newName,
        "email": emailController.text.trim(),
        "mobile": mobileNum,
        "phone": mobileNum,
        "contact": mobileNum,
        "mobile_no": mobileNum,
        "location": localityController.text.trim(),
        "city": localityController.text.trim(),
        "address": localityController.text.trim(),
        "state": stateVal,
        "idType": apiIdType,
        "idtype": apiIdType,
        "id_type": apiIdType,
        "qualification": _qualificationCtrl.text.trim(),
        "highest_qualification": _qualificationCtrl.text.trim(),
        "education": _qualificationCtrl.text.trim(),
        "profile_picture": effProfile,
        "profile_image": effProfile,
        "image": effProfile,
        "photo": effProfile,
        "avatar": effProfile,
        "min_amount": selectedFeeMin ?? 0,
        "max_amount": selectedFeeMax ?? 0,
        "price": (selectedFeeMax ?? 0).toDouble(),
        "fee": (selectedFeeMax ?? 0).toDouble(),
        "fees": (selectedFeeMax ?? 0).toDouble(),
        "hourly_rate": (selectedFeeMax ?? 0).toDouble(),
        "mode": selectedIdMode,
        "teaching_mode": selectedIdMode,
        "teachingMode": selectedIdMode,
        "mode_of_teaching": selectedIdMode,
        "class_mode": selectedIdMode,
        "experience_years": expYears,
        "experience": expYears,
        "experience_year": expYears,
        "year_of_experience": expYears,
        "place_id": _placeId ?? "",
        "latitude": _latitude ?? "",
        "longitude": _longitude ?? "",
        "pincode": pinCodeController.text.trim(),
        // Boards
        "board_id": boardIds,
        "board_ids": boardIdsStr,
        "boards": boardIds,
        "boards_id": boardIds,
        "boardId": boardIds.isNotEmpty ? boardIds.first : null,
        "board": boardNamesJoined,
        "board_name": boardNamesJoined,
        "boardName": boardNamesJoined,
        "board_label": boardNamesJoined,
        "board_names": boardNamesList,
        // Classes / Courses
        "class_id": classIds,
        "class_ids": classIdsStr,
        "classes": classIds,
        "classes_id": classIds,
        "classId": classIds.isNotEmpty ? classIds.first : null,
        "class": classNamesJoined,
        "class_name": classNamesJoined,
        "className": classNamesJoined,
        "class_names": classNamesList,
        "course_id": classIds,
        "course_ids": classIdsStr,
        "courses": classIds,
        "courseId": classIds.isNotEmpty ? classIds.first : null,
        "course": classNamesJoined,
        "course_name": classNamesJoined,
        "courseName": classNamesJoined,
        "course_names": classNamesList,
        // Subjects
        "subject_id": subjectIds,
        "subject_ids": subjectIdsStr,
        "subjects": subjectIds,
        "subjects_id": subjectIds,
        "subjectId": subjectIds.isNotEmpty ? subjectIds.first : null,
        "subject": subjectNamesJoined,
        "subject_name": subjectNamesJoined,
        "subjectName": subjectNamesJoined,
        "subjectname": subjectNamesJoined,
        "subject_names": subjectNamesList,
        "all_subjects": subjectNamesJoined,
        if (subjectIds.isNotEmpty) ...{
          "mostexperiensubjects_id": subjectIds.first,
          "most_experien_subjects_id": subjectIds.first,
          "most_experien_subject": subjectNamesJoined,
          "mostexperiensubject": subjectNamesJoined,
          "most_experien_subjects": subjectNamesJoined,
          "mostexperiensubjects": subjectNamesJoined,
        },
        "teaching_details": teachingDetailsPayload,
        "teaching_details_json": jsonEncode(teachingDetailsPayload),
        "teachingDetails": teachingDetailsPayload,
        "fb_link": _p.tutorprofileData.value?.fbLink ?? '',
        "facebook": _p.tutorprofileData.value?.fbLink ?? '',
        "insta_link": _p.tutorprofileData.value?.instaLink ?? '',
        "instagram": _p.tutorprofileData.value?.instaLink ?? '',
        "wh_link": _p.tutorprofileData.value?.whLink ?? '',
        "whatsapp": _p.tutorprofileData.value?.whLink ?? '',
        "tel_link": _p.tutorprofileData.value?.whLink ?? '',
        "telegram": _p.tutorprofileData.value?.whLink ?? '',
        "remark": remarkVal,
        "about": remarkVal,
        "bio": remarkVal,
        "description": remarkVal,

        // Ensure newly submitted profile goes into under-verification (status 1)
        "profile_status": targetProfileStatus,
        "status": 1,
        "is_verify": targetVerifyStatus,
        "is_verified": targetVerifyStatus,
        "verify": targetVerifyStatus,
        "frontid": effFront,
        "front_id": effFront,
        "id_card": effFront,
        "identity_card": effFront,
        "frontback": effBack,
        "backid": effBack,
        "back_id": effBack,
        "id_back": effBack,
      };

      final ss = await _p.updateTutorProfile(request);
      if (ss) {
        if (newName.isNotEmpty) {
          await StorageService.saveUserName(newName);
        }
        if ((selectedIdMode ?? '').isNotEmpty) {
          await StorageService.saveTeachingMode(selectedIdMode!);
        }
        if (apiIdType.isNotEmpty) {
          await StorageService.saveIdType(apiIdType);
        }
        await StorageService.saveTeachingDetails(teachingDetailsPayload);
        await StorageService.saveKnownMetaNames(
          boards: _knownBoardNames,
          classes: _knownClassNames,
          subjects: _knownSubjectNames,
        );

        final finalStatus = targetProfileStatus;
        await StorageService.saveIsProfileStatus(finalStatus);
        _p.tutorprofileData.value =
            _p.tutorprofileData.value?.copyWith(profileStatus: finalStatus);

        // Auto-refresh profile data from server
        await _p.fetchProfileForTutor();
        _refreshTutorProfile();

        if (finalStatus == 1) {
          // Under verification flow: show popup dialog and navigate to TeacherPendingScreen
          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time_filled_rounded,
                        size: 46,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Your profile is under verification",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Kindly Wait...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Our team will verify your account within 24 hours,\nthen you can start exploring all opportunities.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Get.offAll(() => const TeacherPendingScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          Get.offAll(() => const TeacherPendingScreen());
        } else {
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Get.offAll(() => const TutorDashboard());
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _overlayLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 64,
        centerTitle: false,
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
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Section
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _profileImageError
                                        ? Colors.red.shade400
                                        : primary.withValues(alpha: 0.3),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    final ImageProvider? imgProvider = _profileImage != null
                                        ? FileImage(File(_profileImage!.path))
                                        : (_profileImageUrl != null &&
                                                _profileImageUrl!.isNotEmpty
                                            ? NetworkImage(_profileImageUrl!)
                                            : null);
                                    if (imgProvider != null) {
                                      _showImagePreview(context,
                                          title: 'Profile Photo',
                                          imageProvider: imgProvider);
                                    } else {
                                      _showPickerOptions("profile");
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _profileImage != null
                                        ? FileImage(File(_profileImage!.path))
                                        : (_profileImageUrl != null &&
                                                _profileImageUrl!.isNotEmpty
                                            ? NetworkImage(_profileImageUrl!)
                                                as ImageProvider
                                            : null),
                                    backgroundColor: Colors.grey.shade200,
                                    child: (_profileImage == null &&
                                            (_profileImageUrl == null ||
                                                _profileImageUrl!.isEmpty))
                                        ? Icon(Icons.person,
                                            size: 60,
                                            color: Colors.grey.shade400)
                                        : null,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () => _showPickerOptions("profile"),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [primary, accent],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.camera_alt,
                                        size: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_profileImageError) const SizedBox(height: 8),
                          if (_profileImageError)
                            Text(
                              'Profile photo is required',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Basic Information Section
                    _SectionHeader(
                      icon: Icons.person_outline,
                      title: 'Basic Information',
                      primary: primary,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      onChanged: (val) {
                        final formatted = _capitalizeEach(val);
                        if (formatted != val) {
                          final cursorPos = nameController.selection;
                          nameController.value = TextEditingValue(
                            text: formatted,
                            selection: cursorPos.copyWith(
                              baseOffset: formatted.length,
                              extentOffset: formatted.length,
                            ),
                          );
                        }
                      },
                      onEditingComplete: () {
                        final formatted = _capitalizeEach(nameController.text);
                        nameController.text = formatted;
                      },
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary, width: 2),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email ID",
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary, width: 2),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!_isValidEmail(v.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Location Section
                    _SectionHeader(
                      icon: Icons.location_on_outlined,
                      title: 'Location Details',
                      primary: primary,
                    ),
                    const SizedBox(height: 16),

                    // Locality (Autocomplete fed by server suggestions)
                    Obx(() {
                      final loading = _loc.isSearching.value;
                      final opts = _loc.suggestions;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Autocomplete<String>(
                            optionsBuilder: (TextEditingValue tev) {
                              final q = tev.text.trim();
                              if (q.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return opts;
                            },
                            onSelected: (val) {
                              AppLog.i('[UI] Locality selected → $val');
                              localityController.text = val;
                              _loc.onQueryChanged('');
                            },
                            fieldViewBuilder: (context, textCtrl, focusNode,
                                onFieldSubmitted) {
                              if (textCtrl.text != localityController.text) {
                                textCtrl.text = localityController.text;
                                textCtrl.selection = TextSelection.fromPosition(
                                  TextPosition(offset: textCtrl.text.length),
                                );
                              }
                              textCtrl.addListener(() {
                                final q = textCtrl.text;
                                if (localityController.text != q) {
                                  localityController.text = q;
                                }
                                _loc.onQueryChanged(q);
                              });

                              return TextField(
                                controller: textCtrl,
                                focusNode: focusNode,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  labelText: 'Locality',
                                  hintText: 'Type city/area…',
                                  prefixIcon: const Icon(Icons.location_city),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: primary, width: 2),
                                  ),
                                  suffixIcon: loading
                                      ? const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                        )
                                      : const Icon(Icons.search),
                                ),
                                onSubmitted: (_) => onFieldSubmitted(),
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
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              40,
                                    ),
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
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
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),

                    // Zipcode & Location Button
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: pinCodeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Zipcode",
                              prefixIcon: const Icon(Icons.pin_drop_outlined),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: primary, width: 2),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Zipcode is required';
                              }
                              if (v.trim().length < 6) {
                                return 'Invalid Zipcode';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.my_location, size: 18),
                            label: const Text('Use GPS'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Teaching Details Section
                    _SectionHeader(
                      icon: Icons.school_outlined,
                      title: 'Teaching Details',
                      primary: primary,
                    ),
                    const SizedBox(height: 16),

                    // Boards (multi)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MultiSelectTile(
                            label: 'Boards you Teach',
                            icon: Icons.dashboard_outlined,
                            selectedNames: _labelsFor(
                              _selBoardIds,
                              (_master.masterData.value?.data.boardLead ?? [])
                                  .map((b) => OptionInt(b.boardId, b.boardLabel))
                                  .toList(),
                            ),
                            primary: primary,
                            onTap: () async {
                              final options = (_master
                                          .masterData.value?.data.boardLead ??
                                      [])
                                  .map((b) => OptionInt(b.boardId, b.boardLabel))
                                  .toList();

                              if (!context.mounted) return;

                              final picked = await _showMultiSelect(
                                context,
                                title: 'Select Boards',
                                options: options,
                                initial: _selBoardIds,
                              );
                              if (picked != null) {
                                setState(() {
                                  _selBoardIds
                                    ..clear()
                                    ..addAll(picked);
                                  for (final id in picked) {
                                    final found = options.firstWhereOrNull((b) => b.id == id);
                                    if (found != null && found.label.isNotEmpty) {
                                      _knownBoardNames[id] = found.label;
                                    }
                                  }
                                  _boardError = false;
                                });

                                if (_selBoardIds.isNotEmpty) {
                                  await _leadMeta
                                      .loadClassesForBoards(_selBoardIds);
                                  for (final c in _leadMeta.classes) {
                                    if (c.className.isNotEmpty) {
                                      _knownClassNames[c.classId] = c.className;
                                    }
                                  }
                                  final validClassIds = _leadMeta.classes.map((c) => c.classId).toSet();
                                  _selClassIds.removeWhere((id) => !validClassIds.contains(id));

                                  if (_selClassIds.isNotEmpty) {
                                    await _leadMeta.loadSubjects1(
                                      selBoardIds: _selBoardIds,
                                      selClassIds: _selClassIds,
                                    );
                                    final validSubjectIds = _leadMeta.subjects.map((s) => s.subjectId).toSet();
                                    if (validSubjectIds.isNotEmpty) {
                                      _selSubjectIds.removeWhere((id) => !validSubjectIds.contains(id) && !_knownSubjectNames.containsKey(id));
                                    }
                                  } else {
                                    _selSubjectIds.clear();
                                    _leadMeta.subjects.clear();
                                  }
                                  if (mounted) setState(() {});
                                } else {
                                  _selClassIds.clear();
                                  _selSubjectIds.clear();
                                  _leadMeta.classes.clear();
                                  _leadMeta.subjects.clear();
                                  if (mounted) setState(() {});
                                }
                              }
                            },
                          ),
                          if (_boardError)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Text(
                                'Select at least one board',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Classes (multi)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MultiSelectTile(
                            label: 'Classes you Teach',
                            icon: Icons.class_outlined,
                            selectedNames: _labelsFor(
                              _selClassIds,
                              _leadMeta.classes
                                  .map((c) => OptionInt(c.classId, c.className))
                                  .toList(),
                              fallbackNames: _knownClassNames,
                            ),
                            primary: primary,
                            onTap: () async {
                              if (_selBoardIds.isEmpty) {
                                Get.snackbar(
                                  'Select Board',
                                  'Please select at least one Board first',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }
                              if (_leadMeta.classes.isEmpty) {
                                await _leadMeta.loadClassesForBoards(_selBoardIds);
                              }

                              final optionsMap = <int, OptionInt>{};
                              for (final c in _leadMeta.classes) {
                                optionsMap[c.classId] = OptionInt(c.classId, c.className);
                              }
                              for (final entry in _knownClassNames.entries) {
                                optionsMap.putIfAbsent(entry.key, () => OptionInt(entry.key, entry.value));
                              }
                              final options = optionsMap.values.toList();

                              if (!context.mounted) return;

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
                                  for (final id in picked) {
                                    final found = options.firstWhereOrNull((c) => c.id == id);
                                    if (found != null && found.label.isNotEmpty) {
                                      _knownClassNames[id] = found.label;
                                    }
                                  }
                                  _classError = false;
                                });

                                if (_selBoardIds.isNotEmpty &&
                                    _selClassIds.isNotEmpty) {
                                  await _leadMeta.loadSubjects1(
                                    selBoardIds: _selBoardIds,
                                    selClassIds: _selClassIds,
                                  );
                                  for (final s in _leadMeta.subjects) {
                                    if (s.subjectName.isNotEmpty) {
                                      _knownSubjectNames[s.subjectId] = s.subjectName;
                                    }
                                  }
                                  final validSubjectIds = _leadMeta.subjects.map((s) => s.subjectId).toSet();
                                  if (validSubjectIds.isNotEmpty) {
                                    _selSubjectIds.removeWhere((id) => !validSubjectIds.contains(id) && !_knownSubjectNames.containsKey(id));
                                  }
                                  if (mounted) setState(() {});
                                } else {
                                  _selSubjectIds.clear();
                                  _leadMeta.subjects.clear();
                                  if (mounted) setState(() {});
                                }
                              }
                            },
                          ),
                          if (_classError)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Text('Select at least one class',
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subjects (multi)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MultiSelectTile(
                            label: 'Subjects you Teach',
                            icon: Icons.menu_book_outlined,
                            selectedNames: _labelsFor(
                              _selSubjectIds,
                              _leadMeta.subjects
                                  .map((s) => OptionInt(
                                        s.subjectId,
                                        s.subjectName,
                                      ))
                                  .toList(),
                              fallbackNames: _knownSubjectNames,
                            ),
                            primary: primary,
                            onTap: () async {
                              if (_selBoardIds.isEmpty ||
                                   _selClassIds.isEmpty) {
                                Get.snackbar(
                                  'Select Class',
                                  'Please select Boards and Classes first',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }
                              Get.dialog(
                                const Center(
                                  child: Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(height: 16),
                                          Text('Loading subjects...',
                                              style: TextStyle(fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                barrierDismissible: false,
                              );
                              try {
                                await _leadMeta.loadSubjects1(
                                  selBoardIds: _selBoardIds,
                                  selClassIds: _selClassIds,
                                );
                                for (final s in _leadMeta.subjects) {
                                  if (s.subjectName.isNotEmpty) {
                                    _knownSubjectNames[s.subjectId] = s.subjectName;
                                  }
                                }
                              } finally {
                                if (Get.isDialogOpen == true) {
                                  Get.back();
                                }
                              }

                              final optionsMap = <int, OptionInt>{};
                              for (final s in _leadMeta.subjects) {
                                if (s.subjectName.trim().isEmpty) continue;
                                String label = s.subjectName;
                                if (s.classId != null && s.classId! > 0 && _selClassIds.length > 1) {
                                  final cName = _knownClassNames[s.classId!] ??
                                      _leadMeta.classes.firstWhereOrNull((c) => c.classId == s.classId!)?.className;
                                  if (cName != null && cName.isNotEmpty) {
                                    label = '${s.subjectName} ($cName)';
                                  }
                                }
                                optionsMap[s.subjectId] = OptionInt(s.subjectId, label);
                              }
                              for (final entry in _knownSubjectNames.entries) {
                                if (entry.value.trim().isNotEmpty) {
                                  optionsMap.putIfAbsent(entry.key, () => OptionInt(entry.key, entry.value.trim()));
                                }
                              }
                              final options = optionsMap.values.toList();

                              if (!context.mounted) return;

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
                                  for (final id in picked) {
                                    final found = options.firstWhereOrNull((s) => s.id == id);
                                    if (found != null && found.label.isNotEmpty) {
                                      _knownSubjectNames[id] = found.label;
                                    } else {
                                      final metaFound = _leadMeta.subjects.firstWhereOrNull((s) => s.subjectId == id);
                                      if (metaFound != null && metaFound.subjectName.isNotEmpty) {
                                        _knownSubjectNames[id] = metaFound.subjectName;
                                      }
                                    }
                                  }
                                  _subjectError = false;
                                });
                              }
                            },
                          ),
                          if (_subjectError)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Text('Select at least one subject',
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Qualification & Experience Section
                    _SectionHeader(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Qualification & Experience',
                      primary: primary,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _qualificationCtrl,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: "Qualification",
                        hintText: "e.g., B.Ed, M.Sc, PhD",
                        prefixIcon: const Icon(Icons.school),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary, width: 2),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Qualification is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Experience
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Experience in Years",
                        prefixIcon: const Icon(Icons.work_outline),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary, width: 2),
                        ),
                      ),
                      initialValue: selectedIdExperienceInYears,
                      items: const [
                        "Fresher",
                        "1",
                        "2",
                        "3",
                        "4",
                        "5",
                        "6",
                        "7",
                        "8",
                        "9",
                        "10",
                        "10+"
                      ]
                          .map((id) =>
                              DropdownMenuItem(value: id, child: Text(id)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedIdExperienceInYears = val),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Experience is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.white,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          surface: Colors.white,
                          surfaceContainer: Colors.white,
                          surfaceContainerHighest: Colors.white,
                          surfaceContainerLow: Colors.white,
                          surfaceContainerLowest: Colors.white,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          labelText: "Teaching Mode",
                          prefixIcon: const Icon(Icons.computer_outlined),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                        ),
                        key: ValueKey('mode_$selectedIdMode'),
                        value: _modes.contains(selectedIdMode) ? selectedIdMode : null,
                        items: _modes
                            .map((id) =>
                                DropdownMenuItem(value: id, child: Text(id == 'Both' ? 'Both (Online & Offline)' : id)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedIdMode = val),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Mode is required';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Fee Range Section
                    _SectionHeader(
                      icon: Icons.currency_rupee,
                      title: 'Fee Range',
                      primary: primary,
                    ),
                    const SizedBox(height: 16),

                    // Fee range
                    Row(
                      children: [
                        // MIN
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: "Minimum Fee",
                              prefixIcon: const Icon(Icons.currency_rupee),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: primary, width: 2),
                              ),
                            ),
                            initialValue: selectedFeeMin,
                            isExpanded: true,
                            items: minOptions
                                .map((v) => DropdownMenuItem(
                                    value: v, child: Text('₹$v/Hr')))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedFeeMin = val;
                                // clamp max >= min & >= 300
                                final clampMinForMax = (val == null)
                                    ? 300
                                    : (val < 300 ? 300 : val);
                                if (selectedFeeMax != null &&
                                    selectedFeeMax! < clampMinForMax) {
                                  selectedFeeMax = clampMinForMax;
                                }
                              });
                            },
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // MAX
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: "Maximum Fee",
                              prefixIcon: const Icon(Icons.currency_rupee),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: primary, width: 2),
                              ),
                            ),
                            initialValue: selectedFeeMax,
                            isExpanded: true,
                            items: maxOptionsBase
                                .where((v) =>
                                    v >=
                                    ((selectedFeeMin == null)
                                        ? 300
                                        : (selectedFeeMin! < 300
                                            ? 300
                                            : selectedFeeMin!)))
                                .map((v) => DropdownMenuItem(
                                    value: v, child: Text('₹$v/Hr')))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedFeeMax = val),
                            validator: (v) {
                              if (v == null) return 'Required';
                              final minAllowed = (selectedFeeMin == null)
                                  ? 300
                                  : (selectedFeeMin! < 300
                                      ? 300
                                      : selectedFeeMin!);
                              if (v < minAllowed) {
                                return 'Must be ≥ ₹$minAllowed';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ID Verification Section
                    _SectionHeader(
                      icon: Icons.badge_outlined,
                      title: 'ID Verification',
                      primary: primary,
                    ),
                    const SizedBox(height: 16),

                    // ID Type
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.white,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          surface: Colors.white,
                          surfaceContainer: Colors.white,
                          surfaceContainerHighest: Colors.white,
                          surfaceContainerLow: Colors.white,
                          surfaceContainerLowest: Colors.white,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          labelText: "ID Type",
                          prefixIcon: const Icon(Icons.badge_outlined),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                        ),
                        key: ValueKey('id_type_$selectedIdType'),
                        initialValue: const ["Aadhar", "Voter ID", "Passport"]
                                .contains(selectedIdType)
                            ? selectedIdType
                            : "Aadhar",
                        items: const ["Aadhar", "Voter ID", "Passport"]
                            .map((id) =>
                                DropdownMenuItem(value: id, child: Text(id)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedIdType = val),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'ID Type is required';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ID images (Front & Back)
                    Row(
                      children: [
                        Expanded(
                          child: _idUploadBox(
                            "Front ID",
                            _frontIdImage,
                            _frontIdUrl,
                            "front",
                            error: _frontIdError,
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
                            error: _backIdError,
                            primary: primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: onSavePressed,
                        icon: const Icon(Icons.check_circle_outline, size: 24),
                        label: const Text(
                          "Save and Proceed",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: primary.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          if (_overlayLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context,
      {required String title, ImageProvider? imageProvider}) {
    if (imageProvider == null) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black87),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _labelsFor(List<int> selectedIds, List<OptionInt> all,
      {Map<int, String>? fallbackNames}) {
    final map = {for (final o in all) o.id: o.label};
    return selectedIds
        .map((id) => map[id] ?? fallbackNames?[id] ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Widget _idUploadBox(
    String label,
    XFile? file,
    String? url,
    String type, {
    bool error = false,
    required Color primary,
  }) {
    final bool hasImage = file != null || (url != null && url.isNotEmpty);
    final ImageProvider? imageProvider = file != null
        ? FileImage(File(file.path))
        : (url != null && url.isNotEmpty ? NetworkImage(url) : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (hasImage && imageProvider != null) {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (ctx) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.visibility_outlined),
                        title: const Text("View Image"),
                        onTap: () {
                          Navigator.pop(ctx);
                          _showImagePreview(context,
                              title: label, imageProvider: imageProvider);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.edit_outlined),
                        title: const Text("Change Image"),
                        onTap: () {
                          Navigator.pop(ctx);
                          _showPickerOptions(type);
                        },
                      ),
                      ListTile(
                        leading:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        title: const Text("Remove"),
                        onTap: () {
                          setState(() {
                            if (type == "front") {
                              _frontIdImage = null;
                              _frontIdUrl = null;
                            }
                            if (type == "back") {
                              _backIdImage = null;
                              _backIdUrl = null;
                            }
                          });
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              _showPickerOptions(type);
            }
          },
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: !hasImage ? Colors.grey.shade50 : null,
              border: !hasImage
                  ? Border.all(
                      color:
                          error ? Colors.red.shade400 : Colors.grey.shade300,
                      width: 2,
                    )
                  : Border.all(
                      color: primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: !hasImage
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 44,
                        color:
                            error ? Colors.red.shade400 : Colors.grey.shade400,
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
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      if (file != null)
                        Image.file(
                          File(file.path),
                          fit: BoxFit.cover,
                        )
                      else if (url != null && url.isNotEmpty)
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image,
                                size: 36, color: Colors.grey),
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
                  ),
          ),
        ),
        if (error)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Upload the $label image',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// Section Header Widget
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.primary,
  });

  final IconData icon;
  final String title;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}

class _MultiSelectTile extends StatelessWidget {
  const _MultiSelectTile({
    required this.label,
    required this.selectedNames,
    required this.onTap,
    required this.icon,
    required this.primary,
  });

  final String label;
  final List<String> selectedNames;
  final VoidCallback onTap;
  final IconData icon;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (selectedNames.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${selectedNames.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey.shade600),
              ],
            ),
            const SizedBox(height: 12),
            if (selectedNames.isEmpty)
              Text(
                'Tap to select',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedNames
                    .map((n) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            n,
                            style: TextStyle(
                              color: primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
}
// test

class OptionInt {
  final int id;
  final String label;
  const OptionInt(this.id, this.label);
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
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Check if all items are selected
            final allSelected = options.isNotEmpty &&
                options.every((o) => chosen.contains(o.id));

            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
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

                // Select All checkbox
                CheckboxListTile(
                  dense: true,
                  title: const Text(
                    'Select All',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  value: allSelected,
                  onChanged: (v) {
                    setSheetState(() {
                      if (v == true) {
                        // Select all
                        chosen.clear();
                        chosen.addAll(options.map((o) => o.id));
                      } else {
                        // Deselect all
                        chosen.clear();
                      }
                    });
                  },
                ),
                const Divider(height: 1),

                Expanded(
                  child: ListView.builder(
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
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}
