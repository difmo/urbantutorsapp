import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/admin/admin_dashboard.dart';
import 'package:urbantutorsapp/screens/admin/admin_pending_screen.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/screens/welcome/welcome_screen.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/app_log.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class AdminProfileForm extends StatefulWidget {
  const AdminProfileForm({super.key});
  @override
  State<AdminProfileForm> createState() => _TutorProfileFormScreenState();
}

class _TutorProfileFormScreenState extends State<AdminProfileForm> {
  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  // External controllers
  final LocationController _locationController = Get.find<LocationController>();
  final ProfileUpdateController profileUpdateController =
      Get.put(ProfileUpdateController());
  final MasterDataController _masterDataController =
      Get.put(MasterDataController());

  String? selectedState;
  String? selectedIdType;

  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  XFile? _frontIdImage;
  XFile? _backIdImage;

  // Location data
  String? _latitude;
  String? _longitude;
  String? _placeId;

  bool _overlayLoading = false;

  // ===== GetX workers we must dispose=====
  late final Worker _wTutorData;
  late final Worker _wRouteOnce;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    profileUpdateController.fetchProfileForAdmin();
    _masterDataController.fetchMasterData();
    _wTutorData = ever(profileUpdateController.adminProfileData, (student) {
      AppLog.i('[UI] AdminProfileData changed ');

      if (!mounted || student == null) return;
      nameController.text = _capitalizeEach(student.fullName ?? '');
      phoneController.text = _digitsOnly(student.tutorburoMobile?.toString() ??
          student.email?.toString() ??
          '');
      localityController.text = _capitalizeEach(student.location ?? '');
      selectedState = student.state;
      setState(() {});
    });
    // 2) Route ONCE depending on profile_status (do not re-attach on refresh)
    _wRouteOnce = once(profileUpdateController.adminProfileData, (student) {
      if (!mounted || student == null) return;
      final status = student.tutorburoProfileStatus;
      if (status == 1) {
        Get.offAll(() => const AdminProfileForm());
      } else if (status == 2) {
        Get.offAll(() => const AdminDashboard());
      } else if (status == null) {
        Get.offAll(() => const WelcomeScreen());
      }
    });
  }

  @override
  void dispose() {
    _wTutorData.dispose();
    _wRouteOnce.dispose();

    nameController.dispose();
    emailController.dispose();
    localityController.dispose();
    remarkController.dispose();
    priceController.dispose();
    phoneController.dispose();
    pinCodeController.dispose();
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
    _pickImage(ImageSource.camera, type);
  }

  Future<String?> _fileToBase64(XFile? file) async {
    if (file == null) return null;
    final bytes = await File(file.path).readAsBytes();
    return "data:image/${file.path.split('.').last};base64,${base64Encode(bytes)}";
  }

  void _refreshAdminProfile() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => AdminPendingScreen()),
      (route) => false,
    );
    // Only triggers fetch; DOES NOT add any listeners.
    profileUpdateController.fetchProfileForAdmin();
  }

  // Capitalize helpers
  String _capitalizeEach(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _digitsOnly(String s) {
    return s.replaceAll(RegExp(r'[^0-9]'), '');
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
    final userIdStr = await StorageService.getUserId();
    if (userIdStr == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    // Validate phone number: numeric and reasonable length (10+ digits)
    final phoneDigits = _digitsOnly(phoneController.text);
    if (phoneDigits.length < 10) {
      Get.snackbar('Validation',
          'Please enter a valid phone number (at least 10 digits)');
      return;
    }

    if (mounted) setState(() => _overlayLoading = true);
    try {
      // Ensure text fields have capitalized first letters
      final profileBase64 = await _fileToBase64(_profileImage) ?? '';
      final frontBase64 = await _fileToBase64(_frontIdImage) ?? '';
      final backBase64 = await _fileToBase64(_backIdImage) ?? '';

      final req = {
        "user_id": userIdStr,
        "tutor_bureau_name": _capitalizeEach(nameController.text.trim()),
        "tutor_bureau_email": emailController.text.toString().trim(),
        "profile_verify_phone": phoneDigits,
        "location": _capitalizeEach(localityController.text.trim()),
        "state": selectedState ?? "Delhi",
        "idtype": selectedIdType ?? "Aadhar",
        "profile_picture": profileBase64,
        "frontid": frontBase64,
        "backid": backBase64,
        "place_id": _placeId ?? "",
        "latitude": _latitude ?? "",
        "longitude": _longitude ?? "",
        "pincode": pinCodeController.text.trim(),
      };

      await profileUpdateController.updateAdminProfileVerify(req);
      print(" ProfileUpdateThings : $req");
      Get.snackbar('Success', 'Profile updated successfully');
      _refreshAdminProfile();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _overlayLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final boards =
        _masterDataController.masterData.value?.data.boardLead ?? [];
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
          title: Obx(() {
            final prof = profileUpdateController.adminProfileData.value;
            final name = prof?.tutorburoName?.trim() ?? '';
            final displayName = name.isEmpty ? 'Tutor Bureau' : name;
            final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T';
            final profilePic = prof?.profilePicture;

            return _Header(
              primary: primary,
              accent: accent,
              initial: initial,
              greeting: "Welcome",
              name: displayName,
              balance: "", // Balance might not be relevant here or needs to be fetched
              profileImage: profilePic,
              onCoinTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TutorCoinsScreen()),
                );
              },
            );
          })),
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
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.primaryColor, width: 2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(48))),
                            child: CircleAvatar(
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
                              const InputDecoration(labelText: "Bureau Name"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration:
                        const InputDecoration(labelText: "Phone Number"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email ID"),
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
                        localityController.text = _capitalizeEach(val);
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
                          textCapitalization: TextCapitalization.words,
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
                                    title: Text(_capitalizeEach(item)),
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
                  TextField(
                    controller: pinCodeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: "Pincode"),
                  ),
                  const SizedBox(height: 16),

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
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "ID Type"),
                    value: selectedIdType,
                    items: const [
                      "Aadhar",
                      "Voter ID",
                      "Passport",
                    ]
                        .map((id) =>
                            DropdownMenuItem(value: id, child: Text(id)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedIdType = val),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                          child:
                              _idUploadBox("Front ID", _frontIdImage, "front")),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _idUploadBox("Back ID", _backIdImage, "back")),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showPickerOptions(type),
          child: Container(
            width: double.infinity, // fill the Expanded width
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
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
    this.profileImage,
  });

  final Color primary;
  final Color accent;
  final VoidCallback onCoinTap;
  final String balance;

  final String initial;
  final String greeting;
  final String name;
  final String? profileImage;
  String _capFirst(String s) {
    final t = s.trim();
    if (t.isEmpty) return '';
    return t[0].toUpperCase() + t.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 8,
        ),
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primary, accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(width: 1, color: AppColors.primaryColor)),
          padding: const EdgeInsets.all(2),
          child: (profileImage != null && profileImage!.isNotEmpty)
              ? CircleAvatar(
                  radius: 22,
                  backgroundImage: () {
                    final img = profileImage!;
                    if (img.startsWith('http')) {
                      return NetworkImage(img);
                    } else if (img.startsWith('data:')) {
                      return MemoryImage(base64Decode(img.split(',').last));
                    } else {
                      return NetworkImage('https://urbantutors.pro/$img');
                    }
                  }() as ImageProvider,
                )
              : CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 12),

        // Greeting + name (ellipsized)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profile",
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

        // Coins chip
        const SizedBox(width: 8),
      ],
    );
  }
}
