import 'package:get/get.dart';
import 'package:urbantutorsapp/models/notes_models.dart.dart';
import 'package:urbantutorsapp/services/notes_service.dart';

class NotesController extends GetxController {
  final NotesService _svc = NotesService();

  // Reactive state
  var classes = <NotesClass>[].obs;
  var subjects = <NotesSubject>[].obs;
  var chapters = <NotesChapter>[].obs;
  var chapterDetails = ChapterDetails().obs;

  var loadingClasses = false.obs;
  var loadingSubjects = false.obs;
  var loadingChapters = false.obs;
  var loadingChapterDetails = false.obs;
  final error = ''.obs;

  /// Content type sent to the API: 'Note' (default) or 'pyq'.
  String _type(String? type) =>
      (type == null || type.trim().isEmpty) ? 'Note' : type;

  Future<void> _run(RxBool loading, Future<void> Function() body) async {
    try {
      loading.value = true;
      error.value = '';
      await body();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
  }

  // Fetch Classes
  Future<void> fetchClasses({required int boardId, String? type}) =>
      _run(loadingClasses, () async {
        classes.clear();
        subjects.clear();
        chapters.clear();
        classes.assignAll(
            await _svc.fetchClasses(boardId: boardId, type: _type(type)));
      });

  // Fetch Subjects
  Future<void> fetchSubjects({
    required int boardId,
    required int classId,
    String? type,
  }) =>
      _run(loadingSubjects, () async {
        subjects.clear();
        chapters.clear();
        subjects.assignAll(
            await _svc.fetchSubjects(classId: classId, type: _type(type)));
      });

  // Fetch Chapters
  Future<void> fetchChapters({required int subjectId, String? type}) =>
      _run(loadingChapters, () async {
        chapters.clear();
        chapters.assignAll(
            await _svc.fetchChapters(subjectId: subjectId, type: _type(type)));
      });

  // Fetch Chapter Details
  Future<void> fetchChapterDetails({required int chapterId, String? type}) =>
      _run(loadingChapterDetails, () async {
        chapterDetails.value = await _svc.fetchChapterDetails(
            chapterId: chapterId, type: _type(type));
      });
}
