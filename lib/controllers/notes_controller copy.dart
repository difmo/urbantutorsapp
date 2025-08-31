import 'package:get/get.dart';
import 'package:urbantutorsapp/models/notes_models.dart.dart';
import 'package:urbantutorsapp/services/notes_service.dart';
import 'package:urbantutorsapp/utils/app_log.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart'; // for token, if you use it

class NotesController extends GetxController {
  late final NotesService _svc;

  // selections
  final selectedBoardId = RxnInt();
  final selectedClassId = RxnInt();
  final selectedSubjectId = RxnInt();

  // data lists
  final classes = <NotesClass>[].obs;
  final subjects = <NotesSubject>[].obs;
  final chapters = <NotesChapter>[].obs;

  // loading flags
  final loadingClasses = false.obs;
  final loadingSubjects = false.obs;
  final loadingChapters = false.obs;

  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initService();
  }

  Future<void> _initService() async {
    final token = await StorageService
        .getToken(); // or Get.find<AuthController>().token.value
    _svc = NotesService(token: token);
  }

  // when board changes
  Future<void> setBoard(int boardId) async {
    selectedBoardId.value = boardId;
    selectedClassId.value = null;
    selectedSubjectId.value = null;
    subjects.clear();
    chapters.clear();
    await fetchClasses();
  }

  Future<void> fetchClasses() async {
    final bId = selectedBoardId.value;
    if (bId == null) return;
    loadingClasses.value = true;
    error.value = '';
    try {
      AppLog.i('[NOTES] fetchClasses board=$bId');
      classes.assignAll(await _svc.fetchClasses(boardId: bId, type: 'Note'));
      AppLog.i('[NOTES] classes=${classes.length}');
    } catch (e, st) {
      error.value = e.toString();
      AppLog.e('[NOTES] classes error', error: e, st: st);
    } finally {
      loadingClasses.value = false;
    }
  }

  Future<void> setClass(int classId) async {
    selectedClassId.value = classId;
    selectedSubjectId.value = null;
    chapters.clear();
    await fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    final cId = selectedClassId.value;
    if (cId == null) return;
    loadingSubjects.value = true;
    error.value = '';
    try {
      AppLog.i('[NOTES] fetchSubjects class=$cId');
      subjects.assignAll(await _svc.fetchSubjects(classId: cId, type: 'Note'));
      AppLog.i('[NOTES] subjects=${subjects.length}');
    } catch (e, st) {
      error.value = e.toString();
      AppLog.e('[NOTES] subjects error', error: e, st: st);
    } finally {
      loadingSubjects.value = false;
    }
  }

  Future<void> setSubject(int subjectId) async {
    selectedSubjectId.value = subjectId;
    await fetchChapters();
  }

  Future<void> fetchChapters() async {
    final sId = selectedSubjectId.value;
    if (sId == null) return;
    loadingChapters.value = true;
    error.value = '';
    try {
      print("hsdhjfjksdfns chaperter");
      AppLog.i('[NOTES] fetchChapters subject=$sId');
      chapters
          .assignAll(await _svc.fetchChapters(subjectId: sId, type: 'Note'));
      AppLog.i('[NOTES] chapters=${chapters.length}');
    } catch (e, st) {
      error.value = e.toString();
      AppLog.e('[NOTES] chapters error', error: e, st: st);
    } finally {
      loadingChapters.value = false;
    }
  }

  Future<ChapterDetails> fetchChapterDetails(int chapterId) {
    return _svc.fetchChapterDetails(chapterId: chapterId, type: 'Note');
  }

  onClassChanged(int v) {}
}
