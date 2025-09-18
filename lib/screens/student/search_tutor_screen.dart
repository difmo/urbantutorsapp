import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/lead_create_controller.dart';
import 'package:urbantutorsapp/controllers/pay_course_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/models/lead_create_model_request.dart';

import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/splash_screen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/coins_student.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/app_log.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/StudentDrawer.dart';

class SubjectOption {
  final int id;
  final String name;
  const SubjectOption({required this.id, required this.name});
}

// In your
class SearchTutorScreen extends StatefulWidget {
  const SearchTutorScreen({super.key});

  @override
  State<SearchTutorScreen> createState() => _SearchTutorScreenState();
}

class _SearchTutorScreenState extends State<SearchTutorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final localityCtrl = TextEditingController();

  // Selections
  int? boardId;
  int? classId;
  int? subjectId;
  String? stateVal;
  String? modeVal;

  double _fee = 700;
  bool _submitting = false;

  // GetX controllers
  final MasterDataController _md = Get.find<MasterDataController>();
  final LeadMetaController _lead = Get.find<LeadMetaController>();
  final LocationController _loc = Get.find<LocationController>();
  late final CoinsController _c;
  late final ProfileUpdateController _p;
  final PayCourseController _payCourseController =
      Get.find<PayCourseController>();

  static const _states = <String>[
    'Delhi',
    'Uttar Pradesh',
    'Haryana',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu'
  ];
  static const _modes = <String>['Online', 'Offline', 'Any'];
  static const Color blue = Color(0xFF4A90E2);

  final LeadCreateController _leadCreate =
      Get.isRegistered<LeadCreateController>()
          ? Get.find<LeadCreateController>()
          : Get.put(LeadCreateController());

  // --- lead/user meta ---
  String? leadStatus; // "1" → active/requested, anything else → no request yet
  String? userName;
  String? userPhone;
  bool _loadingUserMeta = true;
  bool get hasActiveLead => leadStatus == "1";

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
        _loadingUserMeta = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        leadStatus = "0";
        userName = "";
        userPhone = "";
        _loadingUserMeta = false;
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

    _loadUserMeta(); // ✅ proper async load of lead status & user info
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    localityCtrl.dispose();
    super.dispose();
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
        borderSide: const BorderSide(color: blue, width: 1.2),
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

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onGetOtp() async {
    FocusScope.of(context).unfocus();

    if (boardId == null) return _toast('Please select a Board');
    if (classId == null) return _toast('Please select a Class');
    if (subjectId == null) return _toast('Please select a Subject');

    final subjectValid = _lead.subjects.any((s) => s.subjectId == subjectId);
    if (!subjectValid) {
      return _toast('Selected subject is not valid for the chosen Board/Class');
    }

    final locText = localityCtrl.text.trim();
    if (locText.isEmpty) return _toast('Please enter your Locality');

    if (modeVal == null) return _toast('Please select Teaching Mode');
    if (stateVal == null) return _toast('Please select State');

    final userId = await StorageService.getUserId();
    if (userId == null) return _toast('User not found. Please login again.');
    final req = LeadCreateRequest(
      name: userName ?? "",
      mobile: userPhone ?? "",
      boardId: boardId!.toString(),
      classId: classId!.toString(),
      subjectId: subjectId!.toString(),
      location: locText,
      state: stateVal ?? '',
      mode: modeVal ?? '',
      fee: _fee.round().toString(),
      userId: userId,
      tutorGender: 'Any',
      maxHits: "",
      supportAgent: '',
      leadId: '',
    );

    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await _leadCreate.createOrUpdateLead(req);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead updated successfully')),
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;

    if (_loadingUserMeta) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F8FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
          // coins
          final loadingCoins = _c.loadingCoins.value || _c.loadingMyCoins.value;
          final wallet = _c.myCoins.value;
          final balanceNum = _toNum(wallet?.available);
          final balanceText = balanceNum.toStringAsFixed(0);

          // profile
          final prof = _p.studentprofileData.value;
          final name = prof?.studentName?.trim();
          final initial = _initial(name);
          final displayName = _firstName(name);

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
            greeting: "Welcome",
            name: displayName,
            balance: balanceText,
            title: "Search a Private Tutor",
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

      // 🔁 BODY switches with leadStatus
      body: hasActiveLead
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Replace this card with your actual list widget
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Requests",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "You already have an active tutor request. We’ll show matching tutors here.",
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // TODO: navigate to your request list screen
                      },
                      child: const Text("View all requests"),
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header line (only for no-active-lead state)
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            TextSpan(text: 'Kindly, Fill the Form to Hire a '),
                            TextSpan(
                              text: 'TUTOR ',
                              style: TextStyle(color: Color(0xFFFF8C00)),
                            ),
                            TextSpan(text: 'Now :'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Board
                      Obx(() {
                        final boards =
                            _md.masterData.value?.data?.boardLead ?? [];
                        return _dropdownDec(
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            value: boardId,
                            icon: const Icon(Icons.expand_more_rounded,
                                color: Color(0xFF9CA3AF)),
                            decoration: _fieldDec('Select Board'),
                            items: boards
                                .map((b) => DropdownMenuItem<int>(
                                      value: (b.boardId is int)
                                          ? b.boardId
                                          : int.tryParse('${b.boardId}'),
                                      child: Text(
                                          b.boardLabel?.toString() ?? '',
                                          overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              AppLog.i('[UI] Board changed → $val');
                              setState(() {
                                boardId = val;
                                classId = null;
                                subjectId = null;
                              });
                              if (val != null) _lead.loadClasses(val);
                            },
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        );
                      }),
                      const SizedBox(height: 10),

                      // Class
                      Obx(() {
                        final classes = _lead.classes;
                        final fetching = _lead.isFetchingClasses.value;
                        return _dropdownDec(
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            value: classId,
                            icon: const Icon(Icons.expand_more_rounded,
                                color: Color(0xFF9CA3AF)),
                            decoration: _fieldDec('Select Class').copyWith(
                              suffixIcon: fetching
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
                            items: classes
                                .map((c) => DropdownMenuItem<int>(
                                      value: c.classId,
                                      child: Text(c.className,
                                          overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (boardId == null)
                                ? null
                                : (val) {
                                    AppLog.i('[UI] Class changed → $val');
                                    setState(() {
                                      classId = val;
                                      subjectId = null;
                                    });
                                    if (val != null && boardId != null) {
                                      _lead.loadSubjects(
                                          classId: val, boardId: boardId!);
                                    }
                                  },
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        );
                      }),
                      const SizedBox(height: 10),

                      // Subject (Autocomplete)
                      Obx(() {
                        final fetching = _lead.isFetchingSubjects.value;
                        final disabled = classId == null || boardId == null;

                        final List<SubjectOption> subjectOptions =
                            _lead.subjects
                                .map<SubjectOption>((s) => SubjectOption(
                                      id: (s.subjectId ?? 0),
                                      name: (s.subjectName ?? '').toString(),
                                    ))
                                .where((o) => o.id != 0 && o.name.isNotEmpty)
                                .toList();

                        return Autocomplete<SubjectOption>(
                          displayStringForOption: (opt) => opt.name,
                          optionsBuilder: (TextEditingValue tev) {
                            if (disabled) {
                              return const Iterable<SubjectOption>.empty();
                            }
                            final q = tev.text.trim().toLowerCase();
                            if (q.isEmpty) return subjectOptions;
                            return subjectOptions
                                .where((o) => o.name.toLowerCase().contains(q));
                          },
                          onSelected: (opt) {
                            setState(() => subjectId = opt.id);
                          },
                          fieldViewBuilder:
                              (context, textCtrl, focusNode, onFieldSubmitted) {
                            textCtrl.addListener(() {
                              if (textCtrl.text.isEmpty && subjectId != null) {
                                setState(() => subjectId = null);
                              }
                            });

                            return TextFormField(
                              controller: textCtrl,
                              focusNode: focusNode,
                              enabled: !disabled,
                              decoration: _fieldDec('Select Subject').copyWith(
                                hintText: 'Search subject',
                                suffixIcon: fetching
                                    ? const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      )
                                    : const Icon(Icons.search,
                                        color: Color(0xFF9CA3AF)),
                              ),
                              validator: (_) =>
                                  subjectId == null ? 'Required' : null,
                              onFieldSubmitted: (_) => onFieldSubmitted(),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(12),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      maxHeight: 260, minWidth: 280),
                                  child: ListView.separated(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    itemCount: options.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final opt = options.elementAt(index);
                                      return ListTile(
                                        dense: true,
                                        title: Text(opt.name,
                                            overflow: TextOverflow.ellipsis),
                                        onTap: () => onSelected(opt),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 10),

                      // Locality (Autocomplete + POST)
                      Obx(() {
                        final loading = _loc.isSearching.value;
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
                            AppLog.i('[UI] Locality selected → $val');
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
                              _loc.onQueryChanged(q); // debounced POST
                            });
                            return TextFormField(
                              controller: textCtrl,
                              focusNode: focusNode,
                              textInputAction: TextInputAction.next,
                              decoration:
                                  _fieldDec('Enter your Locality').copyWith(
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
                                    : const Icon(Icons.location_on_outlined,
                                        color: Color(0xFF9CA3AF)),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Required'
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
                                borderRadius: BorderRadius.circular(10),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: 280,
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 48,
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
                      const SizedBox(height: 10),

                      // State
                      _dropdownDec(
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: stateVal,
                          icon: const Icon(Icons.expand_more_rounded,
                              color: Color(0xFF9CA3AF)),
                          decoration: _fieldDec('Select State'),
                          items: _states
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => setState(() => stateVal = v),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Mode
                      _dropdownDec(
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: modeVal,
                          icon: const Icon(Icons.expand_more_rounded,
                              color: Color(0xFF9CA3AF)),
                          decoration: _fieldDec('Select Mode'),
                          items: _modes
                              .map((m) =>
                                  DropdownMenuItem(value: m, child: Text(m)))
                              .toList(),
                          onChanged: (v) => setState(() => modeVal = v),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Fees slider
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Choose Per Hour Fees :',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4B5563)),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 10),
                                    ),
                                    child: Slider(
                                      value: _fee,
                                      min: 200,
                                      max: 3000,
                                      divisions: 56,
                                      activeColor: blue,
                                      onChanged: (v) =>
                                          setState(() => _fee = v),
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${_fee.round()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 42,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            onPressed: _onGetOtp,
                            child: const Text(
                              'Submit Form',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
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
    required this.title, // ✅ new
  });

  final Color primary;
  final Color accent;
  final VoidCallback onCoinTap;
  final String balance;
  final String initial;
  final String greeting;
  final String name;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title, // ✅ dynamic heading
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
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
                  border: Border.all(width: 1, color: AppColors.primaryColor),
                ),
                child: Row(
                  children: [
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
