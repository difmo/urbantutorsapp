import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_profile_request_modal.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart'
    show LeadMetaController;
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/tutor/teacher_pending_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_dashboard.dart';
import 'package:urbantutorsapp/screens/welcome/welcome_screen.dart';
import 'package:urbantutorsapp/utils/app_log.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class AdminProfileForm extends StatefulWidget {
  const AdminProfileForm({super.key});

  @override
  State<AdminProfileForm> createState() => _AdminProfileFormState();
}

class _AdminProfileFormState extends State<AdminProfileForm> {
  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  // External controllers
  final LocationController _locationController = Get.find<LocationController>();
  final ProfileUpdateController profileUpdateController =
      Get.put(ProfileUpdateController());
  final MasterDataController _masterDataController =
      Get.put(MasterDataController());
  final LeadMetaController _leadMetaController = Get.put(LeadMetaController());

  // IDs kept as int? for API
  int? selectedBoardId;
  int? selectedClassId;
  int? selectedSubjectId;

  String? selectedState;
  String? selectedIdType;

  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  XFile? _frontIdImage;
  XFile? _backIdImage;

  bool _overlayLoading = false;

  // ===== GetX workers we must dispose =====
  late final Worker _wTutorData; // reacts to profile data changes
  late final Worker _wRouteOnce; // navigate once when profile first arrives
  late final Worker _wMasterData; // reflects master data changes
  late final Worker _wIsFetchingClasses;
  late final Worker _wIsFetchingSubjects;

  @override
  void initState() {
    super.initState();
    profileUpdateController.fetchProfileForTutor();
    _masterDataController.fetchMasterData();
    profileUpdateController.fetchProfileForStudent();
    _wTutorData = ever(profileUpdateController.tutorprofileData, (student) {
      AppLog.i('[UI] studentprofileData changed');
      if (!mounted || student == null) return;
      nameController.text = student.studentName ?? '';
      emailController.text = student.mobile?.toString() ?? '';
      priceController.text = student.price?.toString() ?? '';
      localityController.text = student.location ?? '';
      selectedState = student.state;
      selectedIdType = student.idType;
      remarkController.text = student.remark ?? '';
      // if (student.frontId != null && student.frontId!.isNotEmpty) {
      //   _frontIdImage = XFile.fromData(
      //     base64Decode(student.frontId!.split(',').last),
      //     name: 'front_id_${student.studentName ?? ""}.jpg',
      //     mimeType: 'image/jpeg',
      //     path: 'https://urbantutors.pro/${student.frontId}',
      //   );
      // }
      // if (student.frontBack != null && student.frontBack!.isNotEmpty) {
      //   _backIdImage = XFile.fromData(
      //     base64Decode(student.frontBack!.split(',').last),
      //     name: 'back_id_${student.studentName ?? ""}.jpg',
      //     mimeType: 'image/jpeg',
      //     path: 'https://urbantutors.pro/${student.frontBack}',
      //   );
      // }
      if (selectedBoardId != null) {
        _leadMetaController.loadClasses(selectedBoardId!);
      }
      setState(() {});
    });

    // 2) Route ONCE depending on profile_status (do not re-attach on refresh)
    _wRouteOnce = once(profileUpdateController.tutorprofileData, (student) {
      if (!mounted || student == null) return;
      final status = student.profile_status;
      // Stay on this screen for status == 0 (form incomplete)
      if (status == 1) {
        Get.offAll(() => const TeacherPendingScreen());
      } else if (status == 2) {
        Get.offAll(() => const TutorDashboard());
      } else if (status == null) {
        Get.offAll(() => const WelcomeScreen());
      }
    });

    // 3) Keep local UI in sync with master data
    _wMasterData = ever(_masterDataController.masterData, (val) {
      final boards = val?.data?.boardLead ?? [];
      AppLog.i('[UI] masterData updated, boards=${boards.length}');
      if (!mounted) return;
      setState(() {});
    });

    // 4) Loading indicators for classes/subjects
    _wIsFetchingClasses = ever(_leadMetaController.isFetchingClasses, (val) {
      AppLog.i('[UI] isFetchingClasses=$val');
      if (!mounted) return;
      setState(() {});
    });
    _wIsFetchingSubjects = ever(_leadMetaController.isFetchingSubjects, (val) {
      AppLog.i('[UI] isFetchingSubjects=$val');
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose workers to avoid setState after dispose
    _wTutorData.dispose();
    _wRouteOnce.dispose();
    _wMasterData.dispose();
    _wIsFetchingClasses.dispose();
    _wIsFetchingSubjects.dispose();

    // Dispose text controllers
    nameController.dispose();
    emailController.dispose();
    localityController.dispose();
    remarkController.dispose();
    priceController.dispose();
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
    return "data:image/${file.path.split('.').last};base64,${base64Encode(bytes)}";
  }

  void _refreshTutorProfile() {
    // Only triggers fetch; DOES NOT add any listeners.
    profileUpdateController.fetchProfileForTutor();
  }

  Future<void> onSavePressed() async {
    final userIdStr = await StorageService.getUserId();
    if (userIdStr == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    // Basic guards
    if (selectedBoardId == null) {
      Get.snackbar('Missing info', 'Please select a Board');
      return;
    }
    if (selectedClassId == null) {
      Get.snackbar('Missing info', 'Please select a Class');
      return;
    }
    if (selectedSubjectId == null) {
      Get.snackbar('Missing info', 'Please select a Subject');
      return;
    }

    if (mounted) setState(() => _overlayLoading = true);
    try {
      final profileBase64 = await _fileToBase64(_profileImage) ?? '';
      final frontBase64 = await _fileToBase64(_frontIdImage) ?? '';
      final backBase64 = await _fileToBase64(_backIdImage) ?? '';

      final request = TutorProfileUpdateRequest(
        userId: int.parse(userIdStr),
        boardId: selectedBoardId!,
        courseId: selectedClassId!,
        subjectId: selectedSubjectId!,
        price: double.tryParse(priceController.text.trim())
                ?.clamp(0, double.infinity) ??
            0.0,
        location: localityController.text.trim(),
        state: selectedState ?? "",
        idType: selectedIdType ?? "",
        remark: remarkController.text.trim(),
        profilePicture: profileBase64,
        frontId: frontBase64,
        frontBack: backBase64,
        mostExperienSubjectsId: 1,
      );

      await profileUpdateController.updateProfileForTutor(request);
      Get.snackbar('Success', 'Profile updated successfully');
      _refreshTutorProfile();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _overlayLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final boards =
        _masterDataController.masterData.value?.data?.boardLead ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                        child: TextField(
                          controller: nameController,
                          decoration:
                              const InputDecoration(labelText: "Full Name"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: emailController,
                    decoration:
                        const InputDecoration(labelText: "Email / Mobile"),
                  ),
                  const SizedBox(height: 16),

                  // Locality (Autocomplete fed by server suggestions)
                  Obx(() {
                    final loading = _locationController.isSearching.value;
                    final opts =
                        _locationController.suggestions; // RxList<String>

                    return Autocomplete<String>(
                      optionsBuilder: (TextEditingValue tev) {
                        final q = tev.text.trim();
                        if (q.isEmpty) return const Iterable<String>.empty();
                        return opts; // controller already filtered
                      },
                      onSelected: (val) {
                        AppLog.i('[UI] Locality selected → $val');
                        localityController.text = val;
                        _locationController.onQueryChanged('');
                      },
                      fieldViewBuilder:
                          (context, textCtrl, focusNode, onFieldSubmitted) {
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
                          _locationController.onQueryChanged(q);
                        });

                        return TextField(
                          controller: textCtrl,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Locality',
                            hintText: 'Type city/area (e.g., lko)…',
                            suffixIcon: loading
                                ? const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
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
                                    MediaQuery.of(context).size.width - 32,
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
                    );
                  }),
                  const SizedBox(height: 16),

                  // Simple debug readouts
                  Obx(() => Text(
                      'Location results: ${_locationController.suggestions.length}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey))),
                  Obx(() => _locationController.error.isNotEmpty
                      ? Text(
                          'Location error: ${_locationController.error.value}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.red))
                      : const SizedBox.shrink()),

                  // Board
                  Obx(() {
                    final boardsRx = _masterDataController
                            .masterData.value?.data?.boardLead ??
                        [];
                    dev.log('[UI] Boards count: ${boardsRx.length}',
                        name: 'StudentProfile');

                    return DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: "Board",
                        suffixIcon: Obx(
                            () => _leadMetaController.isFetchingClasses.value
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
                                  )
                                : const SizedBox.shrink()),
                      ),
                      value: selectedBoardId,
                      items: boardsRx
                          .map((b) => DropdownMenuItem<int>(
                                value: b.boardId,
                                child: Text(b.boardLabel?.toString() ?? ''),
                              ))
                          .toList(),
                      onChanged: (val) {
                        dev.log('[UI] Board changed → $val',
                            name: 'StudentProfile');
                        setState(() {
                          selectedBoardId = val;
                          selectedClassId = null;
                          selectedSubjectId = null;
                        });
                        if (val != null) {
                          _leadMetaController.loadClasses(val);
                        }
                      },
                    );
                  }),

                  const SizedBox(height: 16),

                  // Class
                  Obx(() {
                    final classItems = _leadMetaController.classes;
                    dev.log('[UI] Classes count: ${classItems.length}',
                        name: 'StudentProfile');

                    return DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: "Class",
                        suffixIcon: _leadMetaController.isFetchingClasses.value
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              )
                            : null,
                      ),
                      value: selectedClassId,
                      items: classItems
                          .map((c) => DropdownMenuItem(
                              value: c.courseId, child: Text(c.courseName)))
                          .toList(),
                      onChanged: (selectedBoardId == null)
                          ? null
                          : (val) {
                              dev.log('[UI] Class changed → $val',
                                  name: 'StudentProfile');
                              setState(() {
                                selectedClassId = val;
                                selectedSubjectId = null;
                              });
                              if (val != null && selectedBoardId != null) {
                                _leadMetaController.loadSubjects(
                                    classId: val, boardId: selectedBoardId!);
                              }
                            },
                    );
                  }),

                  const SizedBox(height: 16),

                  // Subject
                  Obx(() {
                    final subjectItems = _leadMetaController.subjects;
                    dev.log('[UI] Subjects count: ${subjectItems.length}',
                        name: 'StudentProfile');
                    return DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: "Subject",
                        suffixIcon: _leadMetaController.isFetchingSubjects.value
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              )
                            : null,
                      ),
                      value: selectedSubjectId,
                      items: subjectItems
                          .map((s) => DropdownMenuItem(
                              value: s.subjectId, child: Text(s.subjectName)))
                          .toList(),
                      onChanged: (selectedClassId == null ||
                              selectedBoardId == null)
                          ? null
                          : (val) => setState(() => selectedSubjectId = val),
                    );
                  }),

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
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: priceController,
                    decoration:
                        const InputDecoration(labelText: "Budget (Price)"),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "ID Type"),
                    value: selectedIdType,
                    items: const ["Aadhar", "PAN", "Voter ID"]
                        .map((id) =>
                            DropdownMenuItem(value: id, child: Text(id)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedIdType = val),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _idUploadBox("Front ID", _frontIdImage, "front"),
                      _idUploadBox("Back ID", _backIdImage, "back"),
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

  Widget _idUploadBox(String label, XFile? file, String type) {
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showPickerOptions(type),
          child: Container(
            width: 120,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: file == null
                ? const Icon(Icons.image, size: 40, color: Colors.black54)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(file.path), fit: BoxFit.cover),
                  ),
          ),
        ),
      ],
    );
  }
}
