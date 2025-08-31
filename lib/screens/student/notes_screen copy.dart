import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/utils/app_log.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

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
  String? stateVal;
  String? modeVal;

  double _fee = 700;

  // GetX controllers (already registered in main/initialBinding)
  final MasterDataController _md = Get.find<MasterDataController>();
  final LeadMetaController _lead = Get.find<LeadMetaController>();
  final LocationController _loc = Get.find<LocationController>();

  static const _states = <String>[
    'Delhi',
    'Uttar Pradesh',
    'Haryana',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu'
  ];
  static const _modes = <String>['Online', 'Offline', 'Hybrid'];

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    localityCtrl.dispose();
    super.dispose();
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

  Widget _dropdownDec(Widget child) => Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: child,
      );

  Future<void> _onGetOtp() async {
    if (!_formKey.currentState!.validate()) return;

    AppLog.i('[FORM] Submit → '
        'name=${nameCtrl.text}, '
        'mobile=${mobileCtrl.text}, '
        'board=$boardId, class=$classId, subject=$subjectId, '
        'locality=${localityCtrl.text}, state=$stateVal, mode=$modeVal, '
        'fee=$_fee');

    // TODO: call your OTP API here
    Get.snackbar('OTP', 'We just sent an OTP to ${mobileCtrl.text}');
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF4A90E2);
    const cardPadH = 16.0;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: blue,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header line (exact look)
                    SizedBox(
                      height: 16,
                    ),

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
                                    child: Text(b.boardLabel?.toString() ?? '',
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
                                            strokeWidth: 2)),
                                  )
                                : null,
                          ),
                          items: classes
                              .map((c) => DropdownMenuItem<int>(
                                    value: c.courseId,
                                    child: Text(c.courseName,
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

                    // Subject
                    Obx(() {
                      final subjects = _lead.subjects;
                      final fetching = _lead.isFetchingSubjects.value;
                      return _dropdownDec(
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: subjectId,
                          icon: const Icon(Icons.expand_more_rounded,
                              color: Color(0xFF9CA3AF)),
                          decoration: _fieldDec('Select Subject').copyWith(
                            suffixIcon: fetching
                                ? const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
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
                          onChanged: (classId == null || boardId == null)
                              ? null
                              : (val) {
                                  AppLog.i('[UI] Subject changed → $val');
                                  setState(() => subjectId = val);
                                },
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    // Subject
                    Obx(() {
                      final chapters = _lead.chapters;
                      final fetching = _lead.isFetchingChapters.value;
                      return _dropdownDec(
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: subjectId,
                          icon: const Icon(Icons.expand_more_rounded,
                              color: Color(0xFF9CA3AF)),
                          decoration: _fieldDec('Select chapter').copyWith(
                            suffixIcon: fetching
                                ? const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
                                  )
                                : null,
                          ),
                          items: chapters
                              .map((c) => DropdownMenuItem<int>(
                                    value: c.chapterId,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Open chapter details
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //   builder: (_) => ChapterDetailsScreen(chapter: c),
                                        //   ),
                                        // );
                                      },
                                      child: Text(c.chapterName,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (classId == null || boardId == null)
                              ? null
                              : (val) {
                                  AppLog.i('[UI] Chapter changed → $val');
                                  setState(() => subjectId = val);
                                },
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
