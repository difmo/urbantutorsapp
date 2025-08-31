import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/notes_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
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
  int? chapterId;
  String? stateVal;
  String? modeVal;

  double _fee = 700;

  // GetX controllers
  final MasterDataController _md = Get.find<MasterDataController>();
  final NotesController _notesController = Get.put(NotesController());

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
        'board=$boardId, class=$classId, subject=$subjectId, chapter=$chapterId, '
        'locality=${localityCtrl.text}, state=$stateVal, mode=$modeVal, '
        'fee=$_fee');

    Get.snackbar('OTP', 'We just sent an OTP to ${mobileCtrl.text}');
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF4A90E2);
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  /// Board
                  Obx(() {
                    final boards = _md.masterData.value?.data?.boardLead ?? [];
                    return _dropdownDec(
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: boardId,
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
                            chapterId = null;
                          });
                          if (val != null) {
                            _notesController.fetchClasses(boardId: val);
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
                    return _dropdownDec(
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: classId,
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
                                  value: c.id,
                                  child: Text(c.name,
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
                    return _dropdownDec(
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: subjectId,
                        decoration: _fieldDec('Select Subject').copyWith(
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
                                  value: s.id,
                                  child: Text(s.name,
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
                                      subjectId: val);
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
                    return _dropdownDec(
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: chapterId,
                        decoration: _fieldDec('Select Chapter').copyWith(
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
                                  value: c.id,
                                  child: Text(c.name,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (subjectId == null)
                            ? null
                            : (val) {
                                AppLog.i('[UI] Chapter changed → $val');
                                setState(() => chapterId = val);
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
    );
  }
}
