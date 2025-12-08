// lib/screens/tutor/create_lead_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';

import 'package:urbantutorsapp/controllers/lead_create_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/models/lead__model.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/models/lead_create_model_request.dart';
import 'package:urbantutorsapp/widgets/AdminDrawer.dart';

class CreateLeadScreen extends StatefulWidget {
  final StudentLead? lead;
  final bool? repost; // <-- if not null, we're editing
  final bool? edit;
  const CreateLeadScreen({super.key, this.lead, this.repost, this.edit});

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  late final CoinsController _c;
  late final ProfileUpdateController _p;
  bool get _isEditing => widget.lead != null && widget.edit!;
  bool get _isRepost => widget.lead != null && widget.repost!;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _zipcodeCtrl = TextEditingController();
  // --- lead/user meta ---
  String? leadStatus; // "1" → active/requested, anything else → no request yet
  String? userName;
  String? userPhone;
  bool get hasActiveLead => leadStatus == "1";
  String? _latitude;
  String? _longitude;
  String? _placeId;
  bool _locLoading = false;
  Future<void> _loadUserMeta() async {
    try {
      final s = await StorageService.getUserLeadStatus(); // returns "0"/"1"?
      final n = await StorageService.getUserName();
      final p = await StorageService.getUserPhoneNumber();
      if (!mounted) return;
      setState(() {
        leadStatus = s ?? "0";
        userName = n ?? "";
        userPhone = p ?? "";
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        leadStatus = "0";
        userName = "";
        userPhone = "";
      });
    }
  }

  // Safe number formatter
  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _c = Get.isRegistered<CoinsController>()
        ? Get.find<CoinsController>()
        : Get.put(CoinsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _c.refreshAll();
    });

    _p = Get.isRegistered<ProfileUpdateController>()
        ? Get.find<ProfileUpdateController>()
        : Get.put(ProfileUpdateController());
    _p.fetchProfileForStudent();

    _loadUserMeta();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_md.masterData.value == null) {
        await _md.fetchMasterData();
      }
      await _hydrateFromLeadIfEditing();
    });
    _getCurrentLocation();
  }

  String _initial(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'S';
    return n.characters.first.toUpperCase();
  }

  String _firstName(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'Student';
    final parts = n.split(RegExp(r'\s+'));
    return parts.first;
  }

  final _formKey = GlobalKey<FormState>();

  // Controllers (use existing instances if registered)
  final LeadCreateController _leadCreate =
      Get.isRegistered<LeadCreateController>()
          ? Get.find<LeadCreateController>()
          : Get.put(LeadCreateController());
  final MasterDataController _md = Get.isRegistered<MasterDataController>()
      ? Get.find<MasterDataController>()
      : Get.put(MasterDataController());
  final LeadMetaController _lead = Get.isRegistered<LeadMetaController>()
      ? Get.find<LeadMetaController>()
      : Get.put(LeadMetaController());
  final LocationController _loc = Get.isRegistered<LocationController>()
      ? Get.find<LocationController>()
      : Get.put(LocationController());

  // Text fields
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final localityCtrl = TextEditingController();
  final timingCtrl = TextEditingController();
  final feeCtrl = TextEditingController();
  final coinsCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();

  // Dropdown values
  int? boardId;
  int? classId;
  int? subjectId;
  String? tutorGender;
  String? maxHits;
  String? teachingMode;
  String? selectedState;
  String? selectedSupportAgent;

  bool _submitting = false;

  static const _modes = <String>['Online', 'Offline', 'Hybrid'];
  static const _genders = <String>['Male', 'Female', 'Other'];
  static const _maxHitsList = <String>['1', '2', '3'];



  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    localityCtrl.dispose();
    timingCtrl.dispose();
    feeCtrl.dispose();
    coinsCtrl.dispose();
    remarksCtrl.dispose();
    _zipcodeCtrl.dispose();
    super.dispose();
  }

  // -------------------- Location Logic --------------------
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Get.snackbar('Error', 'Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Get.snackbar('Error', 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Get.snackbar('Error', 'Location permissions are permanently denied');
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
        // Get.snackbar('Success', 'Location retrieved successfully',
        //     snackPosition: SnackPosition.BOTTOM,
        //     backgroundColor: Colors.green.shade100);
      }
    } catch (e) {
      if (mounted) setState(() => _locLoading = false);
      // Get.snackbar('Error', 'Failed to get location: $e');
    }
  }

  // -------------------- Save / Update --------------------
  // ---------- Helpers for prefill ----------
  String _norm(String? s) => (s ?? '').trim().toLowerCase();

  T? _firstWhereOrNull<T>(Iterable<T> it, bool Function(T) test) {
    for (final e in it) {
      if (test(e)) return e;
    }
    return null;
  }

  Future<void> _hydrateFromLeadIfEditing() async {
    final l = widget.lead;
    if (l == null) return;

    // ---- Simple text fields ----
    nameCtrl.text = (l.studentName ?? '').trim();
    phoneCtrl.text = (l.mobile ?? '').toString().trim();
    localityCtrl.text = (l.location ?? '').trim();
    remarksCtrl.text = (l.remark ?? '').trim();

    // If your payload distinguishes between "fee" and "coins", map accordingly.
    // Here: price = hourly fee, coins = coins needed (fallbacks covered).
    final feeStr = (l.price == null)
        ? ''
        : (l.price is num
            ? (l.price as num).toStringAsFixed(0)
            : l.price.toString());
    final coinsStr = (l.coins.toString().trim().isEmpty)
        ? '300' // sensible default for old leads without coins
        : l.coins.toString().trim();

    feeCtrl.text = feeStr;
    coinsCtrl.text = coinsStr;

    // ---- Selects (mode, state, max hits, gender if you use it) ----
    teachingMode = (l.mode ?? '').trim().isEmpty ? null : l.mode.trim();
    selectedState = (l.state ?? '').trim().isEmpty ? null : l.state.trim();

    // Max hits (lead_count) → your Dropdown needs a string like "1","2","3"
    final leadCountStr = (l.leadCount == null) ? '' : l.leadCount.toString();
    maxHits =
        _maxHitsList.contains(leadCountStr) ? leadCountStr : _maxHitsList.first;

    // If you add a Tutor Gender dropdown later:
    // final g = (l.typeOfTeacher ?? l.tutorGender ?? '').trim();
    // tutorGender = g.isEmpty ? null : g;

    setState(() {}); // reflect the simple fields immediately

    // ---- Resolve Board → Class → Subject by NAME, then set their ids ----
    final boards = _md.masterData.value?.data.boardLead ?? [];
    String norm(String? s) => (s ?? '').trim().toLowerCase();

    final boardMatch = boards.firstWhereOrNull(
      (b) => norm(b.boardLabel.toString()) == norm(l.boardName),
    );

    if (boardMatch != null) {
      boardId = boardMatch.boardId;
      setState(() {}); // show the board instantly
      await _lead.loadClasses(boardId!); // load classes for selected board

      final classMatch = _lead.classes.firstWhereOrNull(
        (c) => norm(c.className) == norm(l.courseName),
      );
      if (classMatch != null) {
        classId = classMatch.classId;
        setState(() {});
        await _lead.loadSubjects(classId: classId!, boardId: boardId!);

        final subjectMatch = _lead.subjects.firstWhereOrNull(
          (s) => norm(s.subjectName) == norm(l.subjectName),
        );
        if (subjectMatch != null) {
          subjectId = subjectMatch.subjectId;
        }
      }
    }

    setState(() {}); // final refresh after async loads
  }
  // ---------- UI helpers ----------

  InputDecoration _dec(String label, {IconData? icon, Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon:
            icon != null ? Icon(icon, color: Colors.grey.shade600) : null,
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

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
      decoration: _dec(label, icon: icon, suffix: suffix),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------- Submit ----------

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (boardId == null) return _toast('Please select a Board');
    if (classId == null) return _toast('Please select a Class');
    if (subjectId == null) return _toast('Please select a Subject');

    final subjectValid = _lead.subjects.any((s) => s.subjectId == subjectId);
    if (!subjectValid) {
      return _toast('Selected subject is not valid for the chosen Board/Class');
    }

    final locText = localityCtrl.text.trim();
    if (locText.isEmpty) return _toast('Please enter your Locality');

    if (teachingMode == null) return _toast('Please select Teaching Mode');
    // if (selectedState == null) return _toast('Please select State');

    final phoneOk = RegExp(r'^\d{10}$').hasMatch(phoneCtrl.text.trim());
    if (!phoneOk) return _toast('Enter a valid 10-digit mobile number');

    final userId = await StorageService.getUserId();
    if (userId == null) return _toast('User not found. Please login again.');

    final req = LeadCreateRequest(
        name: nameCtrl.text.trim().isEmpty ? "Test" : nameCtrl.text.trim(),
        mobile: phoneCtrl.text.trim(),
        boardId: boardId!.toString(),
        classId: classId!.toString(),
        subjectId: subjectId!.toString(),
        location: locText,
        mode: teachingMode ?? '',
        fee: feeCtrl.text.trim(),
        userId: userId,
        tutorGender: tutorGender ?? 'Any',
        maxHits: maxHits ?? '1',
        supportAgent: selectedSupportAgent ?? '',
        leadId: _isEditing ? (widget.lead!.id.toString() ?? '') : '',
        pincode: _zipcodeCtrl.text.toString(),
        latitude: _latitude ?? '0.0',
        longitude: _longitude ?? '0.0',
        coins: coinsCtrl.text.trim(),
        remark: remarksCtrl.text.trim(),
        place_id: _placeId ?? '');

    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final res = await _leadCreate.createOrUpdateLead(req);
      print(res);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawer: Admindrawer(onMenuTap: (label) async {
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
            greeting: "Transactions",
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _sectionTitle('Student Details : '),

                _buildTextField(
                  label: 'Student/Parent Name',
                  controller: nameCtrl,
                  icon: Icons.person_outline,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: 'Mobile Number',
                  controller: phoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  validator: (v) =>
                      (v == null || !RegExp(r'^\d{10}$').hasMatch(v))
                          ? 'Enter 10-digit number'
                          : null,
                ),
                const SizedBox(height: 16),

                // Locality with server-backed autocomplete
                Obx(() {
                  final isLoading = _loc.isSearching.value;
                  final opts = _loc.suggestions;

                  return Autocomplete<String>(
                    optionsBuilder: (TextEditingValue tev) {
                      final q = tev.text.trim();
                      if (q.isEmpty) return const Iterable<String>.empty();
                      return opts;
                    },
                    onSelected: (val) {
                      localityCtrl.text = val;
                      _loc.onQueryChanged('');
                    },
                    fieldViewBuilder:
                        (context, textCtrl, focusNode, onFieldSubmitted) {
                      if (textCtrl.text != localityCtrl.text) {
                        textCtrl.text = localityCtrl.text;
                        textCtrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: textCtrl.text.length),
                        );
                      }
                      textCtrl.addListener(() {
                        final q = textCtrl.text;
                        if (localityCtrl.text != q) {
                          localityCtrl.text = q;
                        }
                        _loc.onQueryChanged(q);
                      });

                      return TextFormField(
                        controller: textCtrl,
                        focusNode: focusNode,
                        decoration: _dec(
                          'Locality',
                          icon: Icons.map_outlined,
                          suffix: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                        onFieldSubmitted: (_) => onFieldSubmitted(),
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
                              maxWidth: MediaQuery.of(context).size.width - 32,
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: list.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) => ListTile(
                                dense: true,
                                title: Text(list[i]),
                                onTap: () => onSelected(list[i]),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 24),

                _sectionTitle('Lead Info : '),

                // BOARD
                Obx(() {
                  final boards = _md.masterData.value?.data.boardLead ?? [];
                  return DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: boardId,
                    decoration: _dec('Board', icon: Icons.school_outlined),
                    items: boards
                        .map((b) => DropdownMenuItem<int>(
                              value: b.boardId,
                              child: Text(b.boardLabel.toString() ?? ''),
                            ))
                        .toList(),
                    onChanged: (val) async {
                      setState(() {
                        boardId = val;
                        classId = null;
                        subjectId = null;
                      });
                      if (val != null) {
                        await _lead.loadClasses(val);
                      }
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  );
                }),
                const SizedBox(height: 16),

                // CLASS
                Obx(() {
                  final classes = _lead.classes;
                  final fetching = _lead.isFetchingClasses.value;
                  return DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: classId,
                    decoration: _dec('Class', icon: Icons.class_outlined,
                        suffix: fetching
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null),
                    items: classes
                        .map((c) => DropdownMenuItem<int>(
                              value: c.classId,
                              child: Text(c.className),
                            ))
                        .toList(),
                    onChanged: (boardId == null)
                        ? null
                        : (val) async {
                            setState(() {
                              classId = val;
                              subjectId = null;
                            });
                            if (val != null && boardId != null) {
                              await _lead.loadSubjects(
                                  classId: val, boardId: boardId!);
                            }
                          },
                    validator: (v) => v == null ? 'Required' : null,
                  );
                }),
                const SizedBox(height: 16),

                // SUBJECT
                Obx(() {
                  final subjects = _lead.subjects;
                  final fetching = _lead.isFetchingSubjects.value;
                  return DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: subjectId,
                    decoration: _dec('Subject', icon: Icons.book_outlined,
                        suffix: fetching
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null),
                    items: subjects
                        .map((s) => DropdownMenuItem<int>(
                              value: s.subjectId,
                              child: Text(s.subjectName),
                            ))
                        .toList(),
                    onChanged: (boardId == null || classId == null)
                        ? null
                        : (val) => setState(() => subjectId = val),
                    validator: (v) => v == null ? 'Required' : null,
                  );
                }),

                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: teachingMode,
                  decoration: _dec('Teaching Mode', icon: Icons.wifi),
                  items: _modes
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => teachingMode = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: 'Zipcode',
                  controller: _zipcodeCtrl,
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v?.length ?? 0) < 6 ? 'Invalid' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: maxHits,
                  decoration: _dec('Max Hits', icon: Icons.touch_app_outlined),
                  items: _maxHitsList
                      .map((max) => DropdownMenuItem(
                          value: max,
                          child: Row(
                            children: [
                              Text(
                                max,
                                textAlign: TextAlign.end,
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                            ],
                          )))
                      .toList(),
                  onChanged: (v) => setState(() => maxHits = v),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Session Info : '),

                const SizedBox(height: 16),

                _buildTextField(
                  label: 'Fee (₹/Hrs)',
                  controller: feeCtrl,
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  label: 'Required Coins',
                  controller: coinsCtrl,
                  icon: Icons.monetization_on_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // only 0-9
                    LengthLimitingTextInputFormatter(3), // up to 3 digits
                    RangeIntFormatter(
                        min: 1, max: 300), // clamp to 1–300 while typing
                  ],
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n < 1 || n > 300) {
                      return 'Enter a value from 1–300';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: remarksCtrl,
                  textAlign: TextAlign.start, // left-align text
                  textAlignVertical:
                      TextAlignVertical.top, // <-- top align vertically
                  minLines: 3,
                  maxLines: 4, // or null to grow freely
                  scrollPadding: EdgeInsets.zero,
                  decoration: _dec(
                    'Any Remark',
                    icon: Icons.note_alt_outlined,
                  ).copyWith(
                    alignLabelWithHint: true, // label sits at the top
                  ),
                ),

                const SizedBox(height: 24),
                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              _isEditing
                                  ? 'Update Lead'
                                  : (_isRepost ? 'Post Lead' : 'Submit Lead'),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );



 
}

class _Header extends StatelessWidget {
  const _Header({
    required this.primary,
    required this.accent,
    required this.onCoinTap,
    required this.balance,
    required this.initial, // ⬅️ NEW
    required this.greeting, // ⬅️ NEW
    required this.name, // ⬅️ NEW
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
        SizedBox(
          width: 8,
        ),
        // Avatar with gradient ring

        const SizedBox(width: 12),

        // Greeting + name (ellipsized)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create New Lead",
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

class RangeIntFormatter extends TextInputFormatter {
  final int min;
  final int max;
  const RangeIntFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final txt = newValue.text;
    if (txt.isEmpty) return newValue; // allow clearing

    final v = int.tryParse(txt);
    if (v == null) {
      return oldValue; // reject non-numeric (shouldn't happen with digitsOnly)
    }

    int clamped = v;
    if (clamped < min) clamped = min;
    if (clamped > max) clamped = max;

    if (clamped.toString() != txt) {
      final t = clamped.toString();
      return TextEditingValue(
        text: t,
        selection: TextSelection.collapsed(offset: t.length),
      );
    }
    return newValue;
  }
}
