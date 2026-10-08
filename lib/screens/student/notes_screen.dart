import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/lead_create_controller.dart';
import 'package:urbantutorsapp/controllers/notes_controller.dart';
import 'package:urbantutorsapp/controllers/pay_course_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/student/ChapterDetailsScreen.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/coins_student.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/app_log.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import 'package:urbantutorsapp/widgets/StudentDrawer.dart';

class NotesScreen extends StatefulWidget {
  final String? flags;
  const NotesScreen({super.key, this.flags});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final localityCtrl = TextEditingController();

  // Selections
  int? boardId;
  int? classId;
  int? subjectId;
  int? chapterId;
  String? stateVal;
  String? modeVal;

  final double _fee = 700;

  // GetX controllers
  final MasterDataController _md = Get.find<MasterDataController>();
  final NotesController _notesController = Get.put(NotesController());

  final bool _submitting = false;

  // GetX controllers
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

  bool _isGeneric(String? s) {
    if (s == null) return true;
    final t = s.trim().toLowerCase();
    return t.isEmpty ||
        t == 'user' ||
        t == 'student' ||
        t == 'urban user' ||
        t == 'tutor';
  }

  String _resolveName(String? serverName) {
    final s = (serverName ?? '').trim();
    final cached = StorageService.cachedUserName?.trim() ?? '';
    if (!_isGeneric(s)) return s;
    if (!_isGeneric(cached)) return cached;
    return 'Student';
  }

  String _initial(String? name) {
    final n = _resolveName(name);
    return n.characters.first.toUpperCase();
  }

  String _firstName(String? name) {
    final n = _resolveName(name);
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
        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.2),
      ),
    );
  }

  ThemeData? _themeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeData = Theme.of(context);
  }

  Widget _dropdownDec(Widget child) {
    final theme = _themeData ?? ThemeData.light();
    return Theme(
      data: theme.copyWith(
        canvasColor: Colors.white,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: child,
    );
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF4A90E2);
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      endDrawer: StudentDrawer(),
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
            name: widget.flags == "Note" ? 'Notes' : 'PYQ’s',
            balance: balanceText,
            title: widget.flags == "Note" ? 'Notes' : 'PYQ’s',
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  /// Board
                  Obx(() {
                    final noteBoards = _md.masterData.value?.data.boardNotePyq ?? [];
                    final leadBoards = _md.masterData.value?.data.boardLead ?? [];
                    final boards = noteBoards.isNotEmpty ? noteBoards : leadBoards;
                    final selVal = (boardId != null &&
                            boards.any((b) => b.boardId == boardId))
                        ? boardId
                        : null;
                    return _dropdownDec(
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: selVal,
                        decoration: _fieldDec('Select Board'),
                        items: boards
                            .map((b) => DropdownMenuItem<int>(
                                  value: b.boardId,
                                  child: Text(b.boardLabel,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) {
                          AppLog.i('[UI] Board changed → $val');
                          setState(() {
                            boardId = val;
                            classId = null;
                            subjectId = null;
                            chapterId = null;
                          });

                          if (val != null) {
                            _notesController.fetchClasses(
                                boardId: val, type: widget.flags);
                          }
                        },
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    );
                  }),
                  const SizedBox(height: 10),

                  /// Class
                  Obx(() {
                    final classes = _notesController.classes;
                    final fetching = _notesController.loadingClasses.value;
                    final selVal = (classId != null &&
                            classes.any((c) => c.class_id == classId))
                        ? classId
                        : null;
                    return _dropdownDec(
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: selVal,
                        decoration: _fieldDec(boardId == null
                                ? 'Select Class'
                                : (fetching ? 'Loading Classes...' : 'Select Class'))
                            .copyWith(
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
                                  value: c.class_id,
                                  child: Text(c.ClassName,
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
                                  chapterId = null;
                                });
                                if (val != null && boardId != null) {
                                  _notesController.fetchSubjects(
                                    boardId: boardId!,
                                    classId: val,
                                    type: widget.flags,
                                  );
                                }
                              },
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    );
                  }),
                  const SizedBox(height: 10),

                  /// Subject
                  Obx(() {
                    final subjects = _notesController.subjects;
                    final fetching = _notesController.loadingSubjects.value;
                    final selVal = (subjectId != null &&
                            subjects.any((s) => s.subjectId == subjectId))
                        ? subjectId
                        : null;
                    return _dropdownDec(
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: selVal,
                        decoration: _fieldDec(classId == null
                                ? 'Select Subject'
                                : (fetching ? 'Loading Subjects...' : 'Select Subject'))
                            .copyWith(
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
                        items: subjects
                            .map((s) => DropdownMenuItem<int>(
                                  value: s.subjectId,
                                  child: Text(s.subjectName,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (classId == null)
                            ? null
                            : (val) {
                                AppLog.i('[UI] Subject changed → $val');
                                setState(() {
                                  subjectId = val;
                                  chapterId = null;
                                });
                                if (val != null) {
                                  _notesController.fetchChapters(
                                    subjectId: val,
                                    boardId: boardId,
                                    classId: classId,
                                    type: widget.flags,
                                  );
                                }
                              },
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    );
                  }),
                  const SizedBox(height: 10),

                  /// Chapter
                  Obx(() {
                    final chapters = _notesController.chapters;
                    final fetching = _notesController.loadingChapters.value;
                    final selVal = (chapterId != null &&
                            chapters.any((c) => c.chapterId == chapterId))
                        ? chapterId
                        : null;
                    final hint = subjectId == null
                        ? 'Select Chapter'
                        : (fetching
                            ? 'Loading Chapters...'
                            : (chapters.isEmpty
                                ? 'No chapters found for this subject'
                                : 'Select Chapter'));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _dropdownDec(
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            value: selVal,
                            decoration: _fieldDec(hint).copyWith(
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
                            items: chapters
                                .map((c) => DropdownMenuItem<int>(
                                      value: c.chapterId,
                                      child: Text(c.chapterName,
                                          overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (subjectId == null || chapters.isEmpty)
                                ? null
                                : (val) {
                                    AppLog.i('[UI] Chapter changed → $val');
                                    setState(() => chapterId = val);

                                    if (val != null) {
                                      _notesController.fetchChapterDetails(
                                          chapterId: val, type: widget.flags);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChapterDetailsScreen(
                                            chapterId: val,
                                            type: widget.flags,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            validator: (v) =>
                                (chapters.isNotEmpty && v == null) ? 'Required' : null,
                          ),
                        ),
                        if (subjectId != null && !fetching && chapters.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 6, left: 4),
                            child: Text(
                              'Chapters will appear as soon as uploaded to backend',
                              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 10),
                ],
              ),
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
                  color: Colors.white.withValues(alpha: .18),
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
