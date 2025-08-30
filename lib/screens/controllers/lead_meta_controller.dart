import 'package:get/get.dart';
import 'package:urbantutorsapp/services/lead_meta_service.dart';

class LeadMetaController extends GetxController {
  final LeadMetaService _service = LeadMetaService();

  final classes = <LeadClass>[].obs;
  final subjects = <LeadSubject>[].obs;
  final chapters = <LeadChapter>[].obs;
  final chapterDetails = <ChapterDetail>[].obs;

  final isFetchingClasses = false.obs;
  final isFetchingSubjects = false.obs;
  final isFetchingChapters = false.obs;
  final isFetchingChapterDetails = false.obs;
  final error = ''.obs;

  Future<void> loadClasses(int boardId) async {
    try {
      error.value = '';
      isFetchingClasses.value = true;
      classes.clear();
      subjects.clear();
      classes.assignAll(await _service.getClassesByBoard(boardId));
      print('Fetched classes: ${classes.toList()}');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isFetchingClasses.value = false;
    }
  }

  Future<void> loadSubjects(
      {required int classId, required int boardId}) async {
    try {
      error.value = '';
      isFetchingSubjects.value = true;
      subjects.clear();
      subjects.assignAll(await _service.getSubjectsByClassAndBoard(
          classId: classId, boardId: boardId));
      print('Fetched subjects: ${subjects.toList()}');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isFetchingSubjects.value = false;
    }
  }

  Future<void> loadChapters(
      {required int subjectId, required String type}) async {
    try {
      error.value = '';
      isFetchingChapters.value = true;
      chapters.clear();
      chapters.assignAll(await _service.getChaptersBySubject(
          subjectId: subjectId, type: type));
      print('Fetched chapters: ${chapters.toList()}');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isFetchingChapters.value = false;
    }
  }

  Future<void> loadChaptersDetails(
      {required int chapterId, required String type}) async {
    try {
      error.value = '';
      isFetchingChapterDetails.value = true;
      chapterDetails.clear();
      final details =
          await _service.getChapterDetails(chapterId: chapterId, type: type);
      chapterDetails.assignAll(details is Iterable<ChapterDetail>
          ? (details as Iterable<ChapterDetail>)
          : [details as ChapterDetail]);
      print('Fetched chapter details: ${chapterDetails.toList()}');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isFetchingChapterDetails.value = false;
    }
  }
}
