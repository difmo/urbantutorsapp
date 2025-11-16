import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/notes_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/student/ChapterDetailsScreen.dart';
import 'package:urbantutorsapp/utils/app_log.dart';

class TutorPyqScreen extends StatefulWidget {
  final String? flags;
  const TutorPyqScreen({super.key, this.flags});

  @override
  State<TutorPyqScreen> createState() => _TutorPyqScreenState();
}

class _TutorPyqScreenState extends State<TutorPyqScreen> {
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

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF4A90E2);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
                    final boards = _md.masterData.value?.data.boardLead ?? [];
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
                                  child: Text(b.boardLabel.toString() ?? '',
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) {
                          print(val);
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
                                      subjectId: val, type: widget.flags);
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
                                  value: c.chapterId,
                                  child: Text(c.chapterName,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (subjectId == null)
                            ? null
                            : (val) {
                                AppLog.i('[UI] Chapter changed → $val');
                                setState(() => chapterId = val);

                                if (val != null) {
                                  _notesController.fetchChapterDetails(
                                      chapterId: val, type: widget.flags);
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChapterDetailsScreen(
                                      chapterId: val!,
                                    ),
                                  ),
                                );
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
