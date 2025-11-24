// <keep your existing imports>
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/tutor/teacher_pending_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
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
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController zipcodeController = TextEditingController();

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
  int? _boardId;
  int? _classId;

  // Other form bits
  String? selectedState;
  String? selectedIdType;
  String? selectedIdMode;
  String? selectedIdExperienceInYears;

  // Location data
  String? _latitude;
  String? _longitude;
  String? _placeId;

  int? selectedFeeMin; // 100..1000
  int? selectedFeeMax; // 300..3000

  final List<int> minOptions = [for (int v = 100; v <= 1000; v += 100) v];
  final List<int> maxOptionsBase = [for (int v = 300; v <= 3000; v += 100) v];

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
    _p.fetchProfileForStudent();
    _master.fetchMasterData();

    // react to tutor profile changes
    _wTutorData = ever(_p.tutorprofileData, (teacher) async {
      AppLog.i('[UI] tutorprofileData changed');
      if (!mounted || teacher == null) return;
      nameController.text = teacher.teacherName ?? '';
      priceController.text = teacher.minAmount?.toString() ?? '';
      selectedFeeMin = teacher.minAmount?.toInt() ?? 0;
      selectedFeeMax = teacher.maxAmount?.toInt() ?? 0;
      localityController.text = teacher.location ?? '';
      selectedState = teacher.state;
      selectedIdType = teacher.idType;
      remarkController.text = teacher.remark ?? '';
      setState(() {});
    });

    // hydrate from student profile (legacy fields, etc.)
    _wStudentData = ever(_p.studentprofileData, (_) async => await _hydrate());

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

  Future<void> _hydrate() async {
    final p = _p.studentprofileData.value;
    if (p == null) return;

    // Basic text fields
    nameController.text = (p.studentName ?? '').trim();
    emailController.text = (p.mobile ?? '').trim();
    localityController.text = p.location ?? '';

    // Legacy IDs (single -> seed multi)
    final nextBoardId =
        (p.boardId is int) ? p.boardId : int.tryParse(p.boardId ?? '');
    final nextClassId =
        (p.courseId is int) ? p.courseId : int.tryParse(p.courseId ?? '');

    if (nextBoardId != null) {
      await _leadMeta.loadClasses(nextBoardId);
    }

    setState(() {
      _boardId = nextBoardId;
      _classId = nextClassId;

      _selBoardIds
        ..clear()
        ..addAll(nextBoardId != null ? [nextBoardId] : const []);
      _selClassIds
        ..clear()
        ..addAll(nextClassId != null ? [nextClassId] : const []);
      _selSubjectIds.clear();
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
    remarkController.dispose();
    priceController.dispose();
    experienceController.dispose();
    zipcodeController.dispose();
    super.dispose();
  }

  // === Helpers ===
  Future<void> _pickImage(ImageSource source, String type) async {
    final picked = await _picker.pickImage(source: source);
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        if (type == "profile") _profileImage = picked;
        if (type == "front") _frontIdImage = picked;
        if (type == "back") _backIdImage = picked;
      });
    }
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showPickerOptions(String type) {
    showModalBottomSheet(
      context: context,
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

      // Get address from coordinates
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
        AppLog.e('Failed to get postal code: $e');
      }

      if (mounted) {
        setState(() {
          _latitude = position.latitude.toString();
          _longitude = position.longitude.toString();
          if (postalCode != null && postalCode.isNotEmpty) {
            zipcodeController.text = postalCode;
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

    // Validate ID images
    final profileImageOk = _profileImage != null;
    final frontOk = _frontIdImage != null;
    final backOk = _backIdImage != null;
    if (!profileImageOk) _profileImageError = true;
    if (!frontOk) _frontIdError = true;
    if (!backOk) _backIdError = true;

    setState(() {}); // update UI for errors

    if (!formValid ||
        !multiSelectsOk ||
        !frontOk ||
        !backOk ||
        !profileImageOk) {
      Get.snackbar('Error', 'Please fill all required fields.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final userIdStr = await StorageService.getUserId();
    if (userIdStr == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    setState(() => _overlayLoading = true);
    try {
      final profileBase64 = await _fileToBase64(_profileImage) ?? '';
      final frontBase64 = await _fileToBase64(_frontIdImage) ?? '';
      final backBase64 = await _fileToBase64(_backIdImage) ?? '';

      final boardIds = List<int>.from(_selBoardIds.where((e) => e > 0).toSet());
      final classIds = List<int>.from(_selClassIds.where((e) => e > 0).toSet());
      final subjectIds =
          List<int>.from(_selSubjectIds.where((e) => e > 0).toSet());

      final request = {
        "user_id": int.parse(userIdStr),
        "email": emailController.text.trim(),
        "location": localityController.text.trim(),
        // "state": selectedState ?? "Uttar Pradesh",
        "state": zipcodeController.text.toString(),
        "idType": selectedIdType ?? "",
        "qualification": remarkController.text.trim().isNotEmpty
            ? remarkController.text.trim()
            : "Not specified",
        "profile_picture": profileBase64,
        "min_amount": selectedFeeMin ?? 0,
        "max_amount": selectedFeeMax ?? 0,
        "price": (selectedFeeMax ?? 0).toDouble(),
        "mode": selectedIdMode,
        "experience_years": _expToInt(selectedIdExperienceInYears),
        "place_id": _placeId ?? "",
        "latitude": _latitude ?? "",
        "longitude": _longitude ?? "",
        "zipcode": zipcodeController.text.trim(),
        "board_id": boardIds,
        "class_id": classIds,
        "subject_id": subjectIds,
        "frontid": frontBase64,
        "backid": backBase64,
      };

      final ss = await _p.updateTutorProfile(request);
      if (ss) {
        Get.snackbar('Success', 'Profile updated successfully');
        _refreshTutorProfile();
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
        title: _Header(
          primary: primary,
          accent: accent,
          initial: "T",
          greeting: "Wallet",
          name: "Tutor",
          balance: "0",
          onCoinTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TutorCoinsScreen()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile image + name
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: _profileImage != null
                                  ? FileImage(File(_profileImage!.path))
                                  : null,
                              backgroundColor: Colors.grey.shade300,
                              child: _profileImage == null
                                  ? const Icon(Icons.person,
                                      size: 50, color: Colors.white)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => _showPickerOptions("profile"),
                                child: const CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.camera_alt,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: nameController,
                            onChanged: (val) {
                              final formatted = _capitalizeEach(val);
                              if (formatted != val) {
                                // prevent endless loop
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
                              final formatted =
                                  _capitalizeEach(nameController.text);
                              nameController.text = formatted;
                            },
                            textCapitalization: TextCapitalization.words,
                            decoration:
                                const InputDecoration(labelText: "Full Name"),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: "Email ID"),
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
                    const SizedBox(height: 16),

                    // Locality (Autocomplete fed by server suggestions)
                    Obx(() {
                      final loading = _loc.isSearching.value;
                      final opts = _loc.suggestions;

                      // We'll show a lightweight validation error below the widget
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
                                decoration: InputDecoration(
                                  labelText: 'Locality',
                                  hintText: 'Type city/area…',
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
                                      : const Icon(Icons.location_on_outlined),
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
                                  borderRadius: BorderRadius.circular(8),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: 280,
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              32,
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
                          const SizedBox(height: 6),
                          // show validation text if locality empty on save
                          Builder(builder: (ctx) {
                            // We show error if user attempted to submit and locality empty.
                            // Because locality isn't a FormField, we rely on overall validation in onSavePressed
                            // The actual error message is controlled via setState when submit is attempted.
                            return SizedBox.shrink();
                          }),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),

                    // Zipcode & Location Button
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: zipcodeController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Zipcode"),
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
                        IconButton(
                          onPressed: _getCurrentLocation,
                          icon:
                              const Icon(Icons.my_location, color: Colors.blue),
                          tooltip: 'Get Current Location',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // State
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "State"),
                      value: selectedState,
                      items: const [
                        "Andhra Pradesh",
                        "Arunachal Pradesh",
                        "Assam",
                        "Bihar",
                        "Chhattisgarh",
                        "Goa",
                        "Gujarat",
                        "Haryana",
                        "Himachal Pradesh",
                        "Jharkhand",
                        "Karnataka",
                        "Kerala",
                        "Madhya Pradesh",
                        "Maharashtra",
                        "Manipur",
                        "Meghalaya",
                        "Mizoram",
                        "Nagaland",
                        "Odisha",
                        "Punjab",
                        "Rajasthan",
                        "Sikkim",
                        "Tamil Nadu",
                        "Telangana",
                        "Tripura",
                        "Uttar Pradesh",
                        "Uttarakhand",
                        "West Bengal",
                        "Delhi"
                      ]
                          .map((st) =>
                              DropdownMenuItem(value: st, child: Text(st)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedState = val),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'State is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Boards (multi)
                    SizedBox(
                      width: 700,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MultiSelectTile(
                            label: 'Boards you Teach:',
                            selectedNames: _labelsFor(
                              _selBoardIds,
                              (_master.masterData.value?.data.boardLead ?? [])
                                  .map((b) => OptionInt(
                                        (b.boardId is int)
                                            ? b.boardId
                                            : int.tryParse('${b.boardId}') ?? 0,
                                        b.boardLabel ?? '',
                                      ))
                                  .toList(),
                            ),
                            onTap: () async {
                              final options = (_master
                                          .masterData.value?.data.boardLead ??
                                      [])
                                  .map((b) => OptionInt(
                                        (b.boardId is int)
                                            ? b.boardId
                                            : int.tryParse('${b.boardId}') ?? 0,
                                        b.boardLabel ?? '',
                                      ))
                                  .toList();

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
                                  _selClassIds.clear();
                                  _selSubjectIds.clear();
                                  _boardError = false;
                                  _classError = false;
                                  _subjectError = false;
                                });

                                if (_selBoardIds.isNotEmpty) {
                                  await _leadMeta
                                      .loadClasses(_selBoardIds.first);
                                }
                              }
                            },
                          ),
                          if (_boardError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
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
                    const SizedBox(height: 10),
// Classes (multi)
                    SizedBox(
                      width: 600,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MultiSelectTile(
                            label: 'Classes you Teach:',
                            selectedNames: _labelsFor(
                              _selClassIds,
                              _leadMeta.classes
                                  .map((c) => OptionInt(c.classId, c.className))
                                  .toList(),
                            ),
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
                                  _classError = false;
                                  _subjectError = false;
                                });

                                if (_selBoardIds.isNotEmpty &&
                                    _selClassIds.isNotEmpty) {
                                  await _leadMeta.loadSubjects1(
                                    selBoardIds: _selBoardIds,
                                    selClassIds: _selClassIds,
                                  );
                                }
                              }
                            },
                          ),
                          if (_classError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text('Select at least one class',
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subjects (multi)
                    SizedBox(
                      width: 600,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MultiSelectTile(
                            label: 'Subjects you Teach:',
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
                              if (_selBoardIds.isEmpty ||
                                  _selClassIds.isEmpty) {
                                Get.snackbar(
                                  'Select Class',
                                  'Please select Boards and Classes first',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }
                              if (_leadMeta.subjects.isEmpty) {
                                await _leadMeta.loadSubjects1(
                                  selBoardIds: _selBoardIds,
                                  selClassIds: _selClassIds,
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
                                  _subjectError = false;
                                });
                              }
                            },
                          ),
                          if (_subjectError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text('Select at least one subject',
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Experience
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: "Experience in Years"),
                      value: selectedIdExperienceInYears,
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

                    // Modes
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: "Select Modes"),
                      value: selectedIdMode,
                      items: const ["Online", "Offline", "Both"]
                          .map((id) =>
                              DropdownMenuItem(value: id, child: Text(id)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedIdMode = val),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Mode is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Fee range
                    Row(
                      children: [
                        // MIN
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                                labelText: "Select Fee Range (min)"),
                            value: selectedFeeMin,
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
                        const SizedBox(width: 20),
                        // MAX
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                                labelText: "Select Fee Range (max)"),
                            value: selectedFeeMax,
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

                    const SizedBox(height: 16),

                    // ID Type
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "ID Type"),
                      value: selectedIdType,
                      items: const ["Aadhar", "Voter ID", "Passport"]
                          .map((id) =>
                              DropdownMenuItem(value: id, child: Text(id)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedIdType = val),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'ID Type is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ID images
                    Row(
                      children: [
                        Expanded(
                          child: _idUploadBox(
                              "Front ID", _frontIdImage, "front",
                              error: _frontIdError),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _idUploadBox("Back ID", _backIdImage, "back",
                              error: _backIdError),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: ElevatedButton(
                        onPressed: onSavePressed,
                        child: const Text("Save and Proceed"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_overlayLoading)
            Container(
              color: Colors.black.withOpacity(0.25),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  List<String> _labelsFor(List<int> selectedIds, List<OptionInt> all) {
    final map = {for (final o in all) o.id: o.label};
    return selectedIds.map((id) => map[id]).whereType<String>().toList();
  }

  Widget _idUploadBox(String label, XFile? file, String type,
      {bool error = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showPickerOptions(type),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                  color: error ? Colors.red.shade700 : Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: file == null
                ? const Center(
                    child: Icon(Icons.image, size: 40, color: Colors.black54),
                  )
                : Image.file(File(file.path), fit: BoxFit.cover),
          ),
        ),
        if (error)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Upload the $label image',
                style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
          ),
      ],
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Profile",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
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
        width: double.infinity,
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
