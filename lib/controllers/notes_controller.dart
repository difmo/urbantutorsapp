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

  // Fetch Classes
  Future<void> fetchClasses({required int boardId, String? type}) async {
    try {
      loadingClasses.value = true;
      final result = await _svc.fetchClasses(boardId: boardId, type: type!);
      classes.assignAll(result ?? []);
    } finally {
      loadingClasses.value = false;
    }
  }

  // Fetch Subjects
  Future<void> fetchSubjects({
    required int boardId,
    required int classId, String? type,
  }) async {
    try {
      loadingSubjects.value = true;
      final result = await _svc.fetchSubjects(
        // boardId: boardId,
        classId: classId,
        type: type!,
      );
      subjects.assignAll(result ?? []);
    } finally {
      loadingSubjects.value = false;
    }
  }

  // Fetch Chapters
  Future<void> fetchChapters({required int subjectId, String? type}) async {
    try {
      loadingChapters.value = true;
      final result = await _svc.fetchChapters(subjectId: subjectId, type: type!);
      chapters.assignAll(result ?? []);
    } finally {
      loadingChapters.value = false;
    }
  }

    // Fetch Chapter Details
  Future<void> fetchChapterDetails({required int chapterId, String? type}) async {
    try {
      loadingChapterDetails.value = true;
      final result = await _svc.fetchChapterDetails(chapterId: chapterId, type: type!);
      chapterDetails.value = result;
    } finally {
      loadingChapterDetails.value = false;
    }
  }
}
